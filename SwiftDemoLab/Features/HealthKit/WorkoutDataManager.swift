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

// MARK: - WorkoutDataManager - HealthKit 数据管理核心

/// WorkoutDataManager: HealthKit 数据访问与处理的核心组件
/// 负责管理健康数据授权、查询和处理，将 HealthKit 原始数据转换为应用友好的模型
class WorkoutDataManager: NSObject, ObservableObject {
    // MARK: - 公开属性
    
    /// 发布给 UI 层的跑步记录数据
    @Published var runningWorkouts: [RunningWorkout] = []
    
    /// 数据加载状态
    @Published var isLoading = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    // MARK: - 私有属性
    
    /// HealthKit 存储实例
    private let healthStore = HKHealthStore()
    
    /// 取消标记集合，用于管理异步任务
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    
    override init() {
        super.init()
    }
    
    /// 注册 HealthKit 后台数据更新监听
    /// 用于在健康数据发生变化时接收通知并更新应用数据
    func registerBackgroundObserver() {
        // 确保已获得授权
        checkDetailedAuthorizationStatus { authorized in
            guard authorized else {
                print("未获得健康数据授权，无法注册后台更新")
                return
            }
            
            self.registerWorkoutObserver()
            self.registerStepCountObserver()
            
            // 注册其他可能需要的数据类型...
        }
    }
    
    /// 注册跑步记录观察者
    private func registerWorkoutObserver() {
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        
        let workoutQuery = HKObserverQuery(
            sampleType: workoutType,
            predicate: predicate
        ) { [weak self] _, completion, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                print("跑步数据监听出错: \(error.localizedDescription)")
                completion()
                return
            }
            
            // 在主线程更新 UI
            DispatchQueue.main.async {
                // 增量更新数据
                self.fetchLatestWorkouts()
                completion()
            }
        }
        
        healthStore.execute(workoutQuery)
        
        // 启用后台更新
        healthStore.enableBackgroundDelivery(
            for: workoutType,
            frequency: .immediate
        ) { success, error in
            if success {
                print("跑步记录后台更新已启用")
            } else if let error = error {
                print("跑步记录后台更新启用失败: \(error.localizedDescription)")
            }
        }
    }
    
    /// 注册步数记录观察者
    private func registerStepCountObserver() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let stepQuery = HKObserverQuery(
            sampleType: stepType,
            predicate: nil
        ) { [weak self] _, completion, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                print("步数数据监听出错: \(error.localizedDescription)")
                completion()
                return
            }
            
            // 当跑步数据已加载时，更新步数
            if !self.runningWorkouts.isEmpty {
                DispatchQueue.main.async {
                    // 仅更新步数相关数据
                    self.updateWorkoutsStepData()
                    completion()
                }
            } else {
                completion()
            }
        }
        
        healthStore.execute(stepQuery)
        
        // 启用后台更新
        healthStore.enableBackgroundDelivery(
            for: stepType,
            frequency: .hourly // 步数可以设置为小时级别的更新频率
        ) { success, error in
            if success {
                SwiftyLog.info("步数记录后台更新已启用")
            } else if let error = error {
                SwiftyLog.error("步数记录后台更新启用失败: \(error.localizedDescription)")
            }
        }
    }
    
    /// 获取最新的跑步数据
    private func fetchLatestWorkouts() {
        // 使用上次获取数据的时间作为起点
        let lastSyncDate = UserDefaults.standard.object(forKey: "lastWorkoutSyncDate") as? Date ?? Date.distantPast
        let predicate = HKQuery.predicateForSamples(withStart: lastSyncDate, end: nil, options: .strictEndDate)
        
        // 创建查询
        let runningPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            HKQuery.predicateForWorkouts(with: .running),
            predicate
        ])
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: runningPredicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] (_, samples, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("获取最新跑步数据失败: \(error.localizedDescription)")
                return
            }
            
            guard let workouts = samples as? [HKWorkout], !workouts.isEmpty else {
                return
            }
            
            // 更新同步时间
            UserDefaults.standard.set(Date(), forKey: "lastWorkoutSyncDate")
            
            // 处理新数据
            Task {
                let newWorkouts = await self.processWorkouts(workouts)
                
                // 合并新旧数据
                DispatchQueue.main.async {
                    // 移除重复项
                    let existingIds = Set(self.runningWorkouts.map { $0.workout.uuid })
                    let uniqueNewWorkouts = newWorkouts.filter { !existingIds.contains($0.workout.uuid) }
                    
                    if !uniqueNewWorkouts.isEmpty {
                        self.runningWorkouts.append(contentsOf: uniqueNewWorkouts)
                        self.runningWorkouts.sort { $0.startDate > $1.startDate }
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    /// 仅更新现有跑步记录的步数数据
    private func updateWorkoutsStepData() {
        Task {
            for (index, workout) in runningWorkouts.enumerated() {
                do {
                    let steps = try await fetchTotalSteps(for: workout.workout)
                    
                    // 如果步数有变化，更新数据
                    if steps != workout.totalSteps {
                        DispatchQueue.main.async {
                            self.runningWorkouts[index].totalSteps = steps
                            
                                                         // 更新步幅计算
                             if steps > 0 {
                                 let newStepLength = self.runningWorkouts[index].totalDistance / Double(steps)
                                 self.runningWorkouts[index].stepLength = newStepLength
                             }
                        }
                    }
                } catch {
                    print("更新步数数据失败: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 处理后台健康数据更新
    /// 应当在 AppDelegate 的 application(_:didFinishLaunchingWithOptions:) 方法中调用
    /// - Parameter launchOptions: 启动选项
    /// - Returns: 是否处理了健康数据更新
    func handleBackgroundLaunch(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 检查是否由健康数据更新唤醒
        if let options = launchOptions,
           options[.location] == nil, // 排除位置更新唤醒
           options[.bluetoothCentrals] == nil {
            
            // 可能是健康数据更新触发，执行数据刷新
            fetchLatestWorkouts()
            return true
        }
        return false
    }
    
    // MARK: - 健康数据授权管理
    
    /// 检查详细的健康数据授权状态
    /// - Parameter completion: 授权状态检查结果回调，true 表示已授权，false 表示需要授权
    func checkDetailedAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        let typesToRead = getRequiredHealthDataTypes()
        
        healthStore.getRequestStatusForAuthorization(toShare: [], read: typesToRead) { [weak self] status, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "获取授权状态失败: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                switch status {
                case .unnecessary:
                    // 已获得所有所需授权
                    completion(true)
                case .shouldRequest:
                    // 需要请求授权
                    completion(false)
                case .unknown:
                    self.errorMessage = "无法确定授权状态"
                    completion(false)
                @unknown default:
                    self.errorMessage = "未知授权状态"
                    completion(false)
                }
            }
        }
    }
    
    /// 请求 HealthKit 数据访问授权
    /// - Parameter completion: 授权结果回调，true 表示授权成功，false 表示授权失败
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // 首先确认设备支持 HealthKit
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.errorMessage = "此设备不支持 HealthKit"
                completion(false)
            }
            return
        }
        
        // 定义需要读取的健康数据类型
        let typesToRead: Set<HKObjectType> = getRequiredHealthDataTypes()
        
        // 请求授权
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
    
    /// 获取应用需要的所有健康数据类型
    /// - Returns: 健康数据类型集合
    private func getRequiredHealthDataTypes() -> Set<HKObjectType> {
        var typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        // 添加新增的健康数据类型
        if let elevationAscended = HKObjectType.quantityType(forIdentifier: .flightsClimbed) {
            typesToRead.insert(elevationAscended)
        }
        
        // 高度变化相关数据类型
        if #available(iOS 16.0, *) {
            if let elevationDescended = HKObjectType.quantityType(forIdentifier: .stairDescentSpeed) {
                typesToRead.insert(elevationDescended)
            }
        }
        
        // 适配 iOS 16 及以上版本的跑步速度类型
        if #available(iOS 16.0, *) {
            if let runningSpeed = HKObjectType.quantityType(forIdentifier: .runningSpeed) {
                typesToRead.insert(runningSpeed)
            }
            
            if let runningStrideLength = HKObjectType.quantityType(forIdentifier: .runningStrideLength) {
                typesToRead.insert(runningStrideLength)
            }
            
            if let runningVerticalOscillation = HKObjectType.quantityType(forIdentifier: .runningVerticalOscillation) {
                typesToRead.insert(runningVerticalOscillation)
            }
            
            if let runningGroundContactTime = HKObjectType.quantityType(forIdentifier: .runningGroundContactTime) {
                typesToRead.insert(runningGroundContactTime)
            }
        }
        
        // 适配 iOS 17 及以上版本的骑行速度类型
        if #available(iOS 17.0, *) {
            if let cyclingSpeed = HKObjectType.quantityType(forIdentifier: .cyclingSpeed) {
                typesToRead.insert(cyclingSpeed)
            }
        }
        
        return typesToRead
    }
    
    // MARK: - 数据获取与处理
    
    /// 获取并处理用户的跑步运动记录
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
                    // 没有找到跑步记录，这不是错误，只是空结果
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
    /// - Parameter workouts: 从 HealthKit 获取的原始跑步记录
    @MainActor
    private func processWorkouts(_ workouts: [HKWorkout]) async -> [RunningWorkout] {
        var results: [RunningWorkout] = []
        
        // 使用 TaskGroup 并发处理所有 workout
        await withTaskGroup(of: RunningWorkout?.self) { group in
            for workout in workouts {
                group.addTask {
                    await self.fetchWorkoutDetailsAsync(workout: workout)
                }
            }
            
            // 收集所有非空结果
            for await result in group {
                if let result = result {
                    results.append(result)
                }
            }
        }
        
        // 所有数据获取完成后排序并更新 UI
        self.runningWorkouts = results.sorted { $0.startDate > $1.startDate }
        return results
    }
    
    /// 异步获取单次跑步的详细信息
    /// - Parameter workout: 原始 HKWorkout 对象
    /// - Returns: 处理好的 RunningWorkout 对象，失败则返回 nil
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
        
        // 使用 Swift 并发 API 同时获取所有详细数据
        async let distance = fetchTotalDistance(for: workout)
        async let pace = fetchAveragePace(for: workout)
        async let speed = fetchAverageSpeed(for: workout)
        async let energy = fetchTotalEnergy(for: workout)
        async let heartRate = fetchAverageHeartRate(for: workout)
        async let locations = fetchRouteLocations(for: workout)
        async let steps = fetchTotalSteps(for: workout)
        async let elevationData = fetchElevationData(for: workout)
        async let maxHR = fetchMaxHeartRate(for: workout)
        async let heartRateSamples = fetchHeartRateSamples(for: workout)
        
        do {
            // 等待所有请求完成并填充数据
            runningWorkout.totalDistance = try await distance
            runningWorkout.averagePace = try await pace
            runningWorkout.totalEnergyBurned = try await energy
            runningWorkout.averageHeartRate = try await heartRate
            
            // 获取平均速度
            runningWorkout.averageSpeed = try await speed
            
            // 获取路线位置，并限制数量以避免内存问题
            let allLocations = try await locations
            runningWorkout.routeLocations = allLocations.count > 1000 
                ? Array(allLocations.prefix(1000))
                : allLocations
            
            // 填充新增字段
            runningWorkout.totalSteps = try await steps
            let elevation = try await elevationData
            runningWorkout.elevationGain = elevation.gain
            runningWorkout.elevationLoss = elevation.loss
            runningWorkout.maxHeartRate = try await maxHR
            
            // 获取心率数据点
            runningWorkout.heartRateSamples = try await heartRateSamples
            
            // 如果有路线数据，尝试获取天气和地形信息
            if let firstLocation = runningWorkout.routeLocations.first {
                // 根据开始位置推断地形类型
                runningWorkout.terrainType = inferTerrainType(from: runningWorkout.routeLocations)
                
                // 在实际应用中，这里可以调用天气API获取历史天气数据
                // 此处为简化只提供默认值，可以扩展为实际实现
                if let weather = await fetchWeatherData(for: firstLocation.coordinate, at: workout.startDate) {
                    runningWorkout.weatherCondition = weather.condition
                    runningWorkout.temperature = weather.temperature
                    runningWorkout.humidity = weather.humidity
                }
            }
            
            return runningWorkout
        } catch {
            print("获取运动详情失败: \(error.localizedDescription)")
            // 即使获取详细信息失败，我们仍返回基本信息
            return runningWorkout
        }
    }
    
    /// 获取总步数
    /// - Parameter workout: 跑步记录
    /// - Returns: 总步数
    private func fetchTotalSteps(for workout: HKWorkout) async throws -> Int {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let stepsPredicate = HKQuery.predicateForObjects(from: workout)
            
            let stepsQuery = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: stepsPredicate
            ) { (_, result, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                continuation.resume(returning: steps)
            }
            healthStore.execute(stepsQuery)
        }
    }
    
    /// 获取海拔数据
    /// - Parameter workout: 跑步记录
    /// - Returns: 累计爬升和下降
    private func fetchElevationData(for workout: HKWorkout) async throws -> (gain: Double, loss: Double) {
        // 如果没有路线数据，则无法计算海拔变化
        let locations = try await fetchRouteLocations(for: workout)
        if locations.isEmpty {
            return (0, 0)
        }
        
        var totalGain: Double = 0
        var totalLoss: Double = 0
        var previousAltitude = locations[0].altitude
        
        for location in locations.dropFirst() {
            let currentAltitude = location.altitude
            let difference = currentAltitude - previousAltitude
            
            if difference > 0 {
                totalGain += difference
            } else {
                totalLoss += abs(difference)
            }
            
            previousAltitude = currentAltitude
        }
        
        return (totalGain, totalLoss)
    }
    
    /// 获取最大心率
    /// - Parameter workout: 跑步记录
    /// - Returns: 最大心率
    private func fetchMaxHeartRate(for workout: HKWorkout) async throws -> Double {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return 0
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let heartRatePredicate = HKQuery.predicateForObjects(from: workout)
            
            let heartRateQuery = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: heartRatePredicate,
                options: .discreteMax
            ) { (_, result, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let maxHR = result?.maximumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
                continuation.resume(returning: maxHR)
            }
            healthStore.execute(heartRateQuery)
        }
    }
    
    /// 根据位置推断地形类型
    /// - Parameter locations: 位置数组
    /// - Returns: 推断的地形类型
    private func inferTerrainType(from locations: [CLLocation]) -> String {
        // 这里可以实现更复杂的逻辑，例如根据坡度变化、海拔等推断
        // 简化实现
        if locations.isEmpty {
            return "未知"
        }
        
        // 计算海拔变化
        var elevationChanges: [Double] = []
        var previousAltitude = locations[0].altitude
        
        for location in locations.dropFirst() {
            let change = abs(location.altitude - previousAltitude)
            elevationChanges.append(change)
            previousAltitude = location.altitude
        }
        
        // 计算平均海拔变化
        let avgElevationChange = elevationChanges.reduce(0, +) / Double(max(1, elevationChanges.count))
        
        // 根据平均海拔变化推断地形
        if avgElevationChange > 5.0 {
            return "山地"
        } else if avgElevationChange > 2.0 {
            return "丘陵"
        } else {
            return "平地"
        }
    }
    
    /// 获取天气数据
    /// - Parameters:
    ///   - coordinate: 坐标
    ///   - date: 日期
    /// - Returns: 天气数据
    private func fetchWeatherData(for coordinate: CLLocationCoordinate2D, at date: Date) async -> (condition: String, temperature: Double, humidity: Double)? {
        // 实际应用中，这里应该调用天气API获取历史天气数据
        // 由于这只是一个示例，我们返回一些模拟数据
        return ("晴朗", 25.0, 60.0)
    }
    
    // MARK: - 健康数据详细查询方法
    
    /// 获取跑步总距离
    /// - Parameter workout: 跑步记录
    /// - Returns: 总距离（米）
    private func fetchTotalDistance(for workout: HKWorkout) async throws -> Double {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return workout.totalDistance?.doubleValue(for: .meter()) ?? 0
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
                
                let distance = result?.sumQuantity()?.doubleValue(for: .meter()) 
                    ?? workout.totalDistance?.doubleValue(for: .meter()) 
                    ?? 0
                continuation.resume(returning: distance)
            }
            healthStore.execute(distanceQuery)
        }
    }
    
    /// 获取平均配速（分钟/公里）
    /// - Parameter workout: 跑步记录
    /// - Returns: 平均配速
    private func fetchAveragePace(for workout: HKWorkout) async throws -> Double {
        // iOS 16+ 才支持 runningSpeed 类型
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
                        // 回退到从距离和时间计算
                        self.calculatePaceFromDistanceAndTime(workout, continuation: continuation)
                    }
                }
                healthStore.execute(speedQuery)
            }
        } else {
            // 如果不支持 runningSpeed，则从距离和时间计算
            return try await withCheckedThrowingContinuation { continuation in
                self.calculatePaceFromDistanceAndTime(workout, continuation: continuation)
            }
        }
    }
    
    /// 从距离和时间计算配速
    /// - Parameters:
    ///   - workout: 跑步记录
    ///   - continuation: 异步延续
    private func calculatePaceFromDistanceAndTime(_ workout: HKWorkout, continuation: CheckedContinuation<Double, Error>) {
        // 尝试从 workout 对象直接获取距离
        if let distance = workout.totalDistance?.doubleValue(for: .meter()),
           distance > 0 && workout.duration > 0 {
            // 转换为分钟/公里
            let pace = (workout.duration / 60) / (distance / 1000)
            continuation.resume(returning: pace)
            return
        }
        
        // 如果 workout 没有直接提供距离，查询距离
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            continuation.resume(returning: 0)
            return
        }
        
        let distancePredicate = HKQuery.predicateForObjects(from: workout)
        
        let distanceQuery = HKStatisticsQuery(
            quantityType: distanceType,
            quantitySamplePredicate: distancePredicate
        ) { (_, result, error) in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            
            if let distance = result?.sumQuantity()?.doubleValue(for: .meter()),
               distance > 0 && workout.duration > 0 {
                // 转换为分钟/公里
                let pace = (workout.duration / 60) / (distance / 1000)
                continuation.resume(returning: pace)
            } else {
                continuation.resume(returning: 0)
            }
        }
        healthStore.execute(distanceQuery)
    }
    
    /// 获取消耗能量（千卡）
    /// - Parameter workout: 跑步记录
    /// - Returns: 消耗的总能量
    private func fetchTotalEnergy(for workout: HKWorkout) async throws -> Double {
        // 首先尝试从 workout 对象直接获取能量消耗
        if let energy = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
            return energy
        }
        
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
    
    /// 获取平均心率（次/分钟）
    /// - Parameter workout: 跑步记录
    /// - Returns: 平均心率
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
    /// - Parameter workout: 跑步记录
    /// - Returns: 位置点数组
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
    
    /// 获取跑步过程中的心率数据点
    /// - Parameter workout: 跑步记录
    /// - Returns: 心率数据点数组，包含时间戳和心率值
    func fetchHeartRateSamples(for workout: HKWorkout) async throws -> [(timestamp: Date, value: Double)] {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return []
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            // 创建心率查询谓词，限定在跑步时间段内
            let startDatePredicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
            let workoutPredicate = HKQuery.predicateForObjects(from: workout)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDatePredicate, workoutPredicate])
            
            // 按时间排序
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            
            // 查询心率数据
            let heartRateQuery = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { (_, samples, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let heartRateSamples = samples as? [HKQuantitySample], !heartRateSamples.isEmpty else {
                    continuation.resume(returning: [])
                    return
                }
                
                // 转换为时间戳和心率值的数组
                let heartRateData = heartRateSamples.map { sample in
                    let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    return (timestamp: sample.startDate, value: heartRate)
                }
                
                continuation.resume(returning: heartRateData)
            }
            
            self.healthStore.execute(heartRateQuery)
        }
    }
    
    /// 获取平均速度（米/秒）
    /// - Parameter workout: 跑步记录
    /// - Returns: 平均速度
    private func fetchAverageSpeed(for workout: HKWorkout) async throws -> Double {
        // 优先使用 workout 对象中可能已有的速度
        if let totalDistance = workout.totalDistance?.doubleValue(for: .meter()),
           workout.duration > 0 {
            return totalDistance / workout.duration
        }
        
        // iOS 16+ 支持 runningSpeed 类型，尝试获取
        if #available(iOS 16.0, *),
           let speedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed) {
            return try await withCheckedThrowingContinuation { continuation in
                let speedPredicate = HKQuery.predicateForObjects(from: workout)
                
                let speedQuery = HKStatisticsQuery(
                    quantityType: speedType,
                    quantitySamplePredicate: speedPredicate,
                    options: .discreteAverage
                ) { (_, result, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    if let result = result, let average = result.averageQuantity() {
                        let metersPerSecond = average.doubleValue(for: .meter().unitDivided(by: .second()))
                        continuation.resume(returning: metersPerSecond)
                    } else {
                        // 尝试从距离和时间计算
                        self.calculateSpeedFromDistanceAndTime(workout, continuation: continuation)
                    }
                }
                healthStore.execute(speedQuery)
            }
        } else {
            // 如果不支持 runningSpeed，从距离和时间计算
            return try await withCheckedThrowingContinuation { continuation in
                self.calculateSpeedFromDistanceAndTime(workout, continuation: continuation)
            }
        }
    }
    
    /// 从距离和时间计算速度
    /// - Parameters:
    ///   - workout: 跑步记录
    ///   - continuation: 异步延续
    private func calculateSpeedFromDistanceAndTime(_ workout: HKWorkout, continuation: CheckedContinuation<Double, Error>) {
        // 尝试从 workout 对象直接获取距离
        if let distance = workout.totalDistance?.doubleValue(for: .meter()),
           distance > 0 && workout.duration > 0 {
            // 米/秒
            let speed = distance / workout.duration
            continuation.resume(returning: speed)
            return
        }
        
        // 如果 workout 没有直接提供距离，查询距离
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            continuation.resume(returning: 0)
            return
        }
        
        let distancePredicate = HKQuery.predicateForObjects(from: workout)
        
        let distanceQuery = HKStatisticsQuery(
            quantityType: distanceType,
            quantitySamplePredicate: distancePredicate
        ) { (_, result, error) in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            
            if let distance = result?.sumQuantity()?.doubleValue(for: .meter()),
               distance > 0 && workout.duration > 0 {
                // 米/秒
                let speed = distance / workout.duration
                continuation.resume(returning: speed)
            } else {
                continuation.resume(returning: 0)
            }
        }
        healthStore.execute(distanceQuery)
    }
    
    // MARK: - 生命周期管理
    
    deinit {
        // 取消所有挂起的任务
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - 位置数据模型

/// 可识别的位置点，用于地图标记
struct IdentifiableLocation: Identifiable {
    let id = UUID() // 提供唯一标识符
    let location: CLLocation
    let tint: Color // 用于标记不同点的颜色
    
    var coordinate: CLLocationCoordinate2D {
        location.coordinate
    }
}

// MARK: - 跑步数据结构

/// 跑步数据结构 - 应用友好的数据模型
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
    
    // 新增字段
    var totalSteps: Int = 0           // 总步数
    var averageSpeed: Double = 0      // 平均速度 (米/秒)
    var elevationGain: Double = 0     // 累计爬升 (米)
    var elevationLoss: Double = 0     // 累计下降 (米)
    var maxHeartRate: Double = 0      // 最大心率
    var weatherCondition: String = "" // 天气状况
    var temperature: Double = 0       // 温度 (摄氏度)
    var humidity: Double = 0          // 湿度
    var terrainType: String = ""      // 地形类型 (平地/山地/城市等)
    var heartRateSamples: [(timestamp: Date, value: Double)] = [] // 心率数据点
    
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
    
    // 格式化速度显示 (千米/小时)
    var formattedSpeed: String {
        let kmPerHour = averageSpeed * 3.6
        return String(format: "%.1f km/h", kmPerHour)
    }
    
    // 格式化步数显示
    var formattedSteps: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: totalSteps)) ?? "0"
    }
    
    // 格式化高度显示
    var formattedElevation: String {
        return String(format: "+%.0f m / -%.0f m", elevationGain, elevationLoss)
    }
    
    // 计算卡路里每公里
    var caloriesPerKilometer: Double {
        guard totalDistance > 0 else { return 0 }
        return totalEnergyBurned / (totalDistance / 1000)
    }
    
    // 步幅 (米/步)
    var stepLength: Double = 0
    
    // 计算步幅 (米/步)
    var calculatedStepLength: Double {
        guard totalSteps > 0 else { return stepLength }
        return totalDistance / Double(totalSteps)
    }
    
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
    
    // 心率区间分布
    var heartRateZones: [String: Double] {
        guard !heartRateSamples.isEmpty else { return [:] }
        
        // 定义心率区间
        let zones = [
            "恢复区间 (50-60%)": (50, 60),
            "有氧耐力区间 (60-70%)": (60, 70),
            "有氧力量区间 (70-80%)": (70, 80),
            "无氧阈值区间 (80-90%)": (80, 90),
            "最大心率区间 (90-100%)": (90, 100)
        ]
        
        // 假设最大心率为 220 - 年龄，这里使用 30 岁作为默认值
        // 实际应用中应该从用户配置文件获取年龄
        let maxHeartRate = 220 - 30
        
        var distribution: [String: Int] = [:]
        zones.keys.forEach { distribution[$0] = 0 }
        
        // 统计每个心率样本所在区间
        for sample in heartRateSamples {
            let percentage = (sample.value / Double(maxHeartRate)) * 100
            
            for (zone, range) in zones {
                if percentage >= Double(range.0) && percentage < Double(range.1) {
                    distribution[zone, default: 0] += 1
                    break
                }
            }
        }
        
        // 计算百分比分布
        let total = Double(heartRateSamples.count)
        var percentageDistribution: [String: Double] = [:]
        
        for (zone, count) in distribution {
            percentageDistribution[zone] = Double(count) / total * 100
        }
        
        return percentageDistribution
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
