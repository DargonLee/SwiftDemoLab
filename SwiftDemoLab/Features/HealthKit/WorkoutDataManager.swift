//
//  WorkoutDataManager.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/4.
//

import HealthKit
import CoreLocation
import SwiftUI

class WorkoutDataManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    
    // 存储获取的跑步数据
    @Published var runningWorkouts: [RunningWorkout] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 请求健康数据权限
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // 检查设备是否支持HealthKit
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "此设备不支持HealthKit"
            completion(false)
            return
        }
        
        // 定义需要读取的数据类型
        var typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]

        if #available(iOS 16.0, *) {
            if let runningSpeed = HKObjectType.quantityType(forIdentifier: .runningSpeed) {
                typesToRead.insert(runningSpeed)
            }
        }
        
        // 请求权限
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "授权失败: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                if success {
                    completion(true)
                } else {
                    self?.errorMessage = "用户拒绝访问健康数据"
                    completion(false)
                }
            }
        }
    }
    
    // 获取所有跑步类型的健身记录
    func fetchRunningWorkouts() {
        isLoading = true
        runningWorkouts.removeAll()
        
        // 创建跑步类型谓词
        let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
        
        // 按结束时间排序（最新在前）
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // 创建查询
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: runningPredicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] (_, samples, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "查询失败: \(error.localizedDescription)"
                    return
                }
                
                guard let workouts = samples as? [HKWorkout], !workouts.isEmpty else {
                    self.errorMessage = "未找到跑步记录"
                    return
                }
                
                // 处理每条跑步记录
                let group = DispatchGroup()
                
                for workout in workouts {
                    group.enter()
                    
                    // 提取跑步详细信息
                    self.fetchWorkoutDetails(workout: workout) { details in
                        DispatchQueue.main.async {
                            if let details = details {
                                self.runningWorkouts.append(details)
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    // 所有数据获取完成后排序
                    self.runningWorkouts.sort { $0.startDate > $1.startDate }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // 获取单次跑步的详细信息
    private func fetchWorkoutDetails(workout: HKWorkout, completion: @escaping (RunningWorkout?) -> Void) {
        // 收集跑步的所有相关数据
        var runningWorkout = RunningWorkout(
            workout: workout,
            totalDistance: 0,
            averagePace: 0,
            totalEnergyBurned: 0,
            averageHeartRate: 0,
            routeLocations: []
        )
        
        let group = DispatchGroup()
        
        // 1. 获取总距离
        if let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            group.enter()
            let distancePredicate = HKQuery.predicateForObjects(from: workout)
            
            let distanceQuery = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: distancePredicate
            ) { (_, result, error) in
                if let result = result, let sum = result.sumQuantity() {
                    runningWorkout.totalDistance = sum.doubleValue(for: .meter())
                }
                group.leave()
            }
            healthStore.execute(distanceQuery)
        }
        
        // 2. 获取平均配速
        if #available(iOS 16.0, *) {
            if let speedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed) {
                group.enter()
                let speedPredicate = HKQuery.predicateForObjects(from: workout)
                
                let speedQuery = HKStatisticsQuery(
                    quantityType: speedType,
                    quantitySamplePredicate: speedPredicate
                ) { (_, result, error) in
                    if let result = result, let average = result.averageQuantity() {
                        let metersPerSecond = average.doubleValue(for: .meter().unitDivided(by: .second()))
                        // 转换为分钟/公里 (pace)
                        runningWorkout.averagePace = metersPerSecond > 0 ? 1000 / (metersPerSecond * 60) : 0
                    }
                    group.leave()
                }
                healthStore.execute(speedQuery)
            }
        }
        
        // 3. 获取消耗能量
        if let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            group.enter()
            let energyPredicate = HKQuery.predicateForObjects(from: workout)
            
            let energyQuery = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: energyPredicate
            ) { (_, result, error) in
                if let result = result, let sum = result.sumQuantity() {
                    runningWorkout.totalEnergyBurned = sum.doubleValue(for: .kilocalorie())
                }
                group.leave()
            }
            healthStore.execute(energyQuery)
        }
        
        // 4. 获取平均心率
        if let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            group.enter()
            let heartRatePredicate = HKQuery.predicateForObjects(from: workout)
            
            let heartRateQuery = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: heartRatePredicate
            ) { (_, result, error) in
                if let result = result, let average = result.averageQuantity() {
                    runningWorkout.averageHeartRate = average.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                }
                group.leave()
            }
            healthStore.execute(heartRateQuery)
        }
        
        // 5. 获取跑步路线
        group.enter()
        fetchRoute(for: workout) { locations in
            runningWorkout.routeLocations = locations
            group.leave()
        }
        
        // 所有数据获取完成后返回
        group.notify(queue: .global()) {
            completion(runningWorkout)
        }
    }
    
    // 获取跑步路线位置数据
    private func fetchRoute(for workout: HKWorkout, completion: @escaping ([CLLocation]) -> Void) {
        var locations: [CLLocation] = []
        
        // 创建路线查询谓词
        let routePredicate = HKQuery.predicateForObjects(from: workout)
        let routeType = HKSeriesType.workoutRoute()
        
        // 查询路线数据
        let routeQuery = HKSampleQuery(
            sampleType: routeType,
            predicate: routePredicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { [weak self] (_, samples, error) in
            guard let self = self,
                  let routes = samples as? [HKWorkoutRoute],
                  let route = routes.first else {
                completion([])
                return
            }
            
            // 获取路线中的位置点
            let locationQuery = HKWorkoutRouteQuery(route: route) { (_, locationOrNil, done, errorOrNil) in
                if let location = locationOrNil {
                    locations.append(contentsOf: location)
                }
                
                if done {
                    completion(locations)
                }
            }
            
            self.healthStore.execute(locationQuery)
        }
        
        healthStore.execute(routeQuery)
    }
}

// 包装 CLLocation 使其遵循 Identifiable 协议
struct IdentifiableLocation: Identifiable {
    let id = UUID() // 提供唯一标识符
    let location: CLLocation
    let tint: Color // 用于标记不同点的颜色
    
    var coordinate: CLLocationCoordinate2D {
        location.coordinate
    }
}

// 跑步数据结构
struct RunningWorkout: Identifiable {
    let id: UUID
    let workout: HKWorkout
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    
    var totalDistance: Double // 米
    var averagePace: Double   // 分钟/公里
    var totalEnergyBurned: Double // 千卡
    var averageHeartRate: Double  // 次/分钟
    var routeLocations: [CLLocation]
    
    // 格式化距离显示
    var formattedDistance: String {
        let formatter = LengthFormatter()
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter.string(fromValue: totalDistance / 1000, unit: .kilometer)
    }
    
    // 格式化配速显示
    var formattedPace: String {
        let minutes = Int(averagePace)
        let seconds = Int((averagePace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // 格式化持续时间
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? ""
    }
    
    init(workout: HKWorkout,
         totalDistance: Double,
         averagePace: Double,
         totalEnergyBurned: Double,
         averageHeartRate: Double,
         routeLocations: [CLLocation]) {
        self.id = UUID()
        self.workout = workout
        self.startDate = workout.startDate
        self.endDate = workout.endDate
        self.duration = workout.duration
        self.totalDistance = totalDistance
        self.averagePace = averagePace
        self.totalEnergyBurned = totalEnergyBurned
        self.averageHeartRate = averageHeartRate
        self.routeLocations = routeLocations
    }
}

extension RunningWorkout {
    // 获取起点和终点的可识别位置
    var identifiablePoints: [IdentifiableLocation] {
        var points: [IdentifiableLocation] = []
        
        if let start = routeLocations.first {
            points.append(IdentifiableLocation(
                location: start,
                tint: .green
            ))
        }
        
        if let end = routeLocations.last {
            points.append(IdentifiableLocation(
                location: end,
                tint: .red
            ))
        }
        
        return points
    }
    
    // 获取整个路线的可识别位置（用于绘制路径）
    var identifiableRoute: [IdentifiableLocation] {
        routeLocations.map {
            IdentifiableLocation(location: $0, tint: .blue)
        }
    }
}

