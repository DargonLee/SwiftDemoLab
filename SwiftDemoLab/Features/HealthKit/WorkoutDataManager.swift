//
//  WorkoutDataManager.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/4.
//

import HealthKit
import CoreLocation
import SwiftUI
import Combine
import MapKit

// MARK: - Permission Configuration

private struct HealthKitPermissions {
    static func getRequiredPermissions() -> (toShare: Set<HKSampleType>, toRead: Set<HKObjectType>) {
        let toShare: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        let toRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        return (toShare, toRead)
    }
}

class WorkoutDataManager: NSObject, ObservableObject {
    // MARK: - Properties
    let healthStore = HKHealthStore()
    let permissionTypes = HealthKitPermissions.getRequiredPermissions()
    
    // 发布的属性
    @Published var runningWorkouts: [RunningWorkout] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 取消标记用于管理异步任务
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 授权管理
    
    /// 检查HealthKit权限状态
    func checkAuthorizationStatus() async -> HKAuthorizationRequestStatus {
        do {
            let status = try await healthStore.statusForAuthorizationRequest(
                toShare: permissionTypes.toShare,
                read: permissionTypes.toRead
            )
            return status
        }catch {
            print("检查权限状态失败: \(error.localizedDescription)")
            return .shouldRequest
        }
    }
    
    /// 请求健康数据权限
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // 检查设备是否支持HealthKit
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.errorMessage = "此设备不支持HealthKit"
                completion(false)
            }
            return
        }
        
        // 请求权限
        healthStore.requestAuthorization(toShare: permissionTypes.toShare, read: permissionTypes.toRead) { [weak self] success, error in
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
    
    // MARK: - 数据获取
    
    /// 获取所有跑步类型的健身记录
    func fetchRunningWorkouts() {
        // 重置状态
        isLoading = true
        errorMessage = nil
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
                
                // 使用异步任务组处理所有工作
                Task {
                    await self.processWorkouts(workouts)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    /// 异步处理多个跑步记录
    @MainActor
    private func processWorkouts(_ workouts: [HKWorkout]) async {
        var results: [RunningWorkout] = []
        
        for workout in workouts {
            if let details = await fetchWorkoutDetailsAsync(workout: workout) {
                results.append(details)
            }
        }
        
        // 所有数据获取完成后排序并更新UI
        self.runningWorkouts = results.sorted { $0.startDate > $1.startDate }
    }
    
    /// 异步获取单次跑步的详细信息
    private func fetchWorkoutDetailsAsync(workout: HKWorkout) async -> RunningWorkout? {
        // 创建基本运动记录
        var runningWorkout = RunningWorkout(
            workout: workout,
            totalDistance: 0,
            averagePace: 0,
            totalEnergyBurned: 0,
            averageHeartRate: 0,
            routeLocations: []
        )
        
        // 使用任务组并发获取所有数据
        async let distance = fetchTotalDistance(for: workout)
        async let pace = fetchAveragePace(for: workout)
        async let energy = fetchTotalEnergy(for: workout)
        async let heartRate = fetchAverageHeartRate(for: workout)
        async let locations = fetchRouteLocations(for: workout)
        
        do {
            // 等待所有请求完成并填充数据
            runningWorkout.totalDistance = try await distance
            runningWorkout.averagePace = try await pace
            runningWorkout.totalEnergyBurned = try await energy
            runningWorkout.averageHeartRate = try await heartRate
            runningWorkout.routeLocations = try await locations
            
            return runningWorkout
        } catch {
            print("获取运动详情失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 详细数据获取方法
    
    /// 获取总距离
    private func fetchTotalDistance(for workout: HKWorkout) async throws -> Double {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return 0
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let distancePredicate = HKQuery.predicateForObjects(from: workout)
            
            let distanceQuery = HKStatisticsQuery(
                quantityType: distanceType,
                quantitySamplePredicate: distancePredicate
            ) { (_, result, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let distance = result?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                continuation.resume(returning: distance)
            }
            healthStore.execute(distanceQuery)
        }
    }
    
    /// 获取平均配速
    private func fetchAveragePace(for workout: HKWorkout) async throws -> Double {
        // iOS 16+ 才支持runningSpeed类型
        if #available(iOS 16.0, *),
           let speedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed) {
            return try await withCheckedThrowingContinuation { continuation in
                let speedPredicate = HKQuery.predicateForObjects(from: workout)
                
                let speedQuery = HKStatisticsQuery(
                    quantityType: speedType,
                    quantitySamplePredicate: speedPredicate
                ) { (_, result, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    if let result = result, let average = result.averageQuantity() {
                        let metersPerSecond = average.doubleValue(for: .meter().unitDivided(by: .second()))
                        // 转换为分钟/公里 (pace)
                        let pace = metersPerSecond > 0 ? 1000 / (metersPerSecond * 60) : 0
                        continuation.resume(returning: pace)
                    } else {
                        continuation.resume(returning: 0)
                    }
                }
                healthStore.execute(speedQuery)
            }
        } else {
            // 如果不支持runningSpeed，尝试从距离和时间计算
            let distance = try await fetchTotalDistance(for: workout)
            let duration = workout.duration
            
            // 只有当距离和时间都有效时才计算配速
            if distance > 0 && duration > 0 {
                // 转换为分钟/公里
                return (duration / 60) / (distance / 1000)
            }
            return 0
        }
    }
    
    /// 获取消耗能量
    private func fetchTotalEnergy(for workout: HKWorkout) async throws -> Double {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return 0
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let energyPredicate = HKQuery.predicateForObjects(from: workout)
            
            let energyQuery = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: energyPredicate
            ) { (_, result, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let energy = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: energy)
            }
            healthStore.execute(energyQuery)
        }
    }
    
    /// 获取平均心率
    private func fetchAverageHeartRate(for workout: HKWorkout) async throws -> Double {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return 0
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let heartRatePredicate = HKQuery.predicateForObjects(from: workout)
            
            let heartRateQuery = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: heartRatePredicate
            ) { (_, result, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let heartRate = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
                continuation.resume(returning: heartRate)
            }
            healthStore.execute(heartRateQuery)
        }
    }
    
    /// 获取跑步路线位置数据
    private func fetchRouteLocations(for workout: HKWorkout) async throws -> [CLLocation] {
        return try await withCheckedThrowingContinuation { continuation in
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
                guard let self = self else {
                    continuation.resume(returning: [])
                    return
                }
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let routes = samples as? [HKWorkoutRoute],
                      let route = routes.first else {
                    continuation.resume(returning: [])
                    return
                }
                
                // 获取路线中的位置点
                let locationQuery = HKWorkoutRouteQuery(route: route) { (_, locationOrNil, done, errorOrNil) in
                    if let error = errorOrNil {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    if let location = locationOrNil {
                        locations.append(contentsOf: location)
                    }
                    
                    if done {
                        continuation.resume(returning: locations)
                    }
                }
                
                self.healthStore.execute(locationQuery)
            }
            
            healthStore.execute(routeQuery)
        }
    }
    
    // MARK: - 清理资源
    
    deinit {
        // 取消所有挂起的任务
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - 位置数据模型

/// 包装 CLLocation 使其遵循 Identifiable 协议
struct IdentifiableLocation: Identifiable {
    let id = UUID() // 提供唯一标识符
    let location: CLLocation
    let tint: Color // 用于标记不同点的颜色
    
    var coordinate: CLLocationCoordinate2D {
        location.coordinate
    }
}

// MARK: - 跑步数据结构

/// 跑步数据结构
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
    
    // 计算卡路里每公里
    var caloriesPerKilometer: Double {
        guard totalDistance > 0 else { return 0 }
        return totalEnergyBurned / (totalDistance / 1000)
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

// MARK: - RunningWorkout 扩展
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
    
    // 运动强度评估（基于心率）
    var intensityLevel: String {
        if averageHeartRate < 120 {
            return "低强度"
        } else if averageHeartRate < 150 {
            return "中等强度"
        } else {
            return "高强度"
        }
    }
}

// 扩展RunningWorkout提供地图相关功能
extension RunningWorkout {
    
    // 获取起点位置
    var startLocation: CLLocation {
        routeLocations.first ?? CLLocation(latitude: 0, longitude: 0)
    }
    
    // 获取终点位置
    var endLocation: CLLocation {
        routeLocations.last ?? CLLocation(latitude: 0, longitude: 0)
    }
    
    // 计算适合地图显示的区域
    var routeRegion: MKCoordinateRegion {
        guard !routeLocations.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        
        var minLat = routeLocations[0].coordinate.latitude
        var maxLat = minLat
        var minLon = routeLocations[0].coordinate.longitude
        var maxLon = minLon
        
        for location in routeLocations {
            let coord = location.coordinate
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}
