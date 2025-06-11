//
//  RunningWorkoutsView.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/4.
//

import SwiftUI
import MapKit
import HealthKit

// MARK: - 主视图: 跑步记录列表

/// 跑步记录主视图 - 显示用户的所有跑步记录
struct RunningWorkoutsView: View {
    // 使用 StateObject 确保视图生命周期内数据管理器保持存在
    @StateObject private var dataManager = WorkoutDataManager()
    @State private var showingAuthorization = false
    @State private var showingErrorAlert = false
    
    var body: some View {
        Group {
            if dataManager.isLoading {
                LoadingView()
            } else if dataManager.errorMessage != nil {
                ErrorView(errorMessage: dataManager.errorMessage ?? "", onRetry: refreshData)
            } else if dataManager.runningWorkouts.isEmpty {
                EmptyWorkoutsView()
            } else {
                WorkoutsListView(runningWorkouts: dataManager.runningWorkouts)
            }
        }
        .navigationTitle("跑步记录")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: refreshData) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            checkAuthorization()
        }
        .sheet(isPresented: $showingAuthorization) {
            AuthorizationView(dataManager: dataManager)
        }
        .alert(
            "出错了",
            isPresented: $showingErrorAlert,
            actions: {
                Button("重试", action: refreshData)
                Button("取消", role: .cancel) {}
            },
            message: {
                if let error = dataManager.errorMessage {
                    Text(error)
                }
            }
        )
    }
    
    /// 检查 HealthKit 授权状态
    private func checkAuthorization() {
        let status = dataManager.checkAuthorizationStatus()
        
        if status == .notDetermined || status == .sharingDenied {
            showingAuthorization = true
        } else {
            refreshData()
        }
    }
    
    /// 刷新数据
    private func refreshData() {
        dataManager.fetchRunningWorkouts()
    }
}

// MARK: - 加载中视图

/// 加载状态视图
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("加载跑步数据中...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 错误视图

/// 错误状态视图
struct ErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("数据加载失败")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(errorMessage)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onRetry) {
                Label("重新加载", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

// MARK: - 空数据视图

/// 没有跑步数据时显示的视图
struct EmptyWorkoutsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.7))
            
            Text("暂无跑步记录")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("记录您的跑步后，数据将显示在这里")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - 跑步列表视图

/// 跑步记录列表视图
struct WorkoutsListView: View {
    let runningWorkouts: [RunningWorkout]
    
    var body: some View {
        List(runningWorkouts) { workout in
            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                WorkoutRowView(workout: workout)
            }
            .listRowSeparator(.visible)
        }
        .listStyle(.inset)
    }
}

// MARK: - 授权视图

/// HealthKit 授权请求视图
struct AuthorizationView: View {
    @ObservedObject var dataManager: WorkoutDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var isRequestingAuth = false
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "figure.run")
                .font(.system(size: 70))
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            Text("访问健康数据")
                .font(.title)
                .fontWeight(.bold)
            
            Text("需要访问您的健康数据以显示跑步记录。您的健康数据不会上传或共享给任何第三方。")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            
            if isRequestingAuth {
                ProgressView()
                    .padding()
            } else {
                Button("授权访问") {
                    isRequestingAuth = true
                    requestAuthorization()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.large)
                .padding(.top, 10)
                
                Button("稍后再说") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                .controlSize(.large)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    /// 请求 HealthKit 授权
    private func requestAuthorization() {
        dataManager.requestAuthorization { success in
            isRequestingAuth = false
            if success {
                dataManager.fetchRunningWorkouts()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - 跑步记录行视图

/// 单条跑步记录行视图
struct WorkoutRowView: View {
    let workout: RunningWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 日期和星期
            HStack {
                Text(workout.startDate, style: .date)
                    .font(.headline)
                
                Text(formattedWeekday(from: workout.startDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 运动强度标签
                Text(workout.intensityLevel)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(intensityColor.opacity(0.2))
                    .foregroundColor(intensityColor)
                    .clipShape(Capsule())
            }
            
            Divider()
            
            // 主要数据
            HStack(alignment: .top) {
                // 左侧: 距离和配速
                VStack(alignment: .leading, spacing: 6) {
                    DataItemView(
                        icon: "figure.walk",
                        title: "距离",
                        value: workout.formattedDistance
                    )
                    
                    DataItemView(
                        icon: "stopwatch",
                        title: "配速",
                        value: "\(workout.formattedPace)/km"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 右侧: 时长和心率
                VStack(alignment: .leading, spacing: 6) {
                    DataItemView(
                        icon: "clock",
                        title: "时长",
                        value: workout.formattedDuration
                    )
                    
                    DataItemView(
                        icon: "heart",
                        title: "心率",
                        value: "\(Int(workout.averageHeartRate)) bpm"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 8)
    }
    
    /// 将日期格式化为星期几
    private func formattedWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    /// 根据运动强度返回颜色
    private var intensityColor: Color {
        switch workout.intensityLevel {
        case "低强度":
            return .green
        case "中等强度":
            return .orange
        case "高强度":
            return .red
        default:
            return .blue
        }
    }
}

/// 数据项视图 - 用于显示图标、标题和值
struct DataItemView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.callout)
                    .fontWeight(.medium)
            }
        }
    }
}

// MARK: - 跑步详情视图

/// 单次跑步详情视图
struct WorkoutDetailView: View {
    let workout: RunningWorkout
//    @State private var region: MKCoordinateRegion
    @State private var showingFullScreenMap = false
    @State private var cameraPosition: MapCameraPosition
    
    // 起点和终点标记
    private var annotationPoints: [IdentifiableLocation] {
        workout.identifiablePoints
    }
    
    // 地图坐标数组，用于绘制路线
    private var routeCoordinates: [CLLocationCoordinate2D] {
        workout.routeLocations.map { $0.coordinate }
    }
    
    init(workout: RunningWorkout) {
        self.workout = workout
        
        // 如果有路线数据，则使用路线区域，否则使用默认区域
        if !workout.routeLocations.isEmpty {
            // 计算适合显示的区域
            var minLat = workout.routeLocations[0].coordinate.latitude
            var maxLat = minLat
            var minLon = workout.routeLocations[0].coordinate.longitude
            var maxLon = minLon
            
            for location in workout.routeLocations {
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
            let region = MKCoordinateRegion(center: center, span: span)
//            self._region = State(initialValue: region)
            cameraPosition = .region(region)

        } else {
            // 没有路线数据时使用默认区域
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            cameraPosition = .region(region)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 地图视图
                if !workout.routeLocations.isEmpty {
                    ZStack(alignment: .topTrailing) {
                        // 地图
                        Map(position: $cameraPosition) {
                            ForEach(workout.identifiablePoints) { point in
                                Annotation("", coordinate: point.coordinate) {
                                    Circle()
                                        .fill(point.tint)
                                        .frame(width: 16, height: 16)
                                        .overlay(
                                            Circle().stroke(Color.white, lineWidth: 2)
                                        )
                                        .shadow(radius: 3)
                                }
                            }
                            if !routeCoordinates.isEmpty {
                                MapPolyline(coordinates: routeCoordinates)
                                    .stroke(.blue, lineWidth: 4)
                            }
                        }
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        
                        // 全屏按钮
                        Button(action: {
                            showingFullScreenMap = true
                        }) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 16, weight: .bold))
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        .padding(8)
                    }
                    .padding(.horizontal)
                }
                
                // 摘要卡片
                WorkoutSummaryCard(workout: workout)
                    .padding(.horizontal)
                
                // 详细信息卡片
                WorkoutDetailsCard(workout: workout)
                    .padding(.horizontal)
                
                Spacer(minLength: 30)
            }
            .padding(.vertical)
        }
        .navigationTitle("跑步详情")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingFullScreenMap) {
            // 全屏地图视图
            FullScreenMapView(cameraPosition: cameraPosition, workout: workout)
        }
    }
}

/// 全屏地图视图
struct FullScreenMapView: View {
    let cameraPosition: MapCameraPosition
    let workout: RunningWorkout
    @Environment(\.presentationMode) var presentationMode
    @State private var currentRegion: MapCameraPosition
    
    
    // 地图坐标数组，用于绘制路线
    private var routeCoordinates: [CLLocationCoordinate2D] {
        workout.routeLocations.map { $0.coordinate }
    }
    
    init(cameraPosition: MapCameraPosition, workout: RunningWorkout) {
        self.cameraPosition = cameraPosition
//        cameraPosition = .region(region)
        _currentRegion = State(initialValue: cameraPosition)
        self.workout = workout
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $currentRegion) {
                ForEach(workout.identifiablePoints) { point in
                    Annotation("", coordinate: point.coordinate) {
                        Circle()
                            .fill(point.tint)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(radius: 3)
                    }
                }
                if !routeCoordinates.isEmpty {
                    MapPolyline(coordinates: routeCoordinates)
                        .stroke(.blue, lineWidth: 4)
                }
            }
            .edgesIgnoringSafeArea(.all)
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(10)
                    .background(Color(.systemBackground).opacity(0.8))
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            .padding([.top, .trailing], 16)
        }
    }
}


/// 跑步摘要卡片
struct WorkoutSummaryCard: View {
    let workout: RunningWorkout
    
    var body: some View {
        VStack(spacing: 0) {
            // 卡片标题
            HStack {
                Text("跑步摘要")
                    .font(.headline)
                Spacer()
                Text(workout.startDate, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
                .padding(.vertical, 10)
            
            // 四项主要数据的网格
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                SummaryItem(
                    icon: "figure.walk",
                    value: workout.formattedDistance,
                    title: "总距离"
                )
                
                SummaryItem(
                    icon: "stopwatch",
                    value: workout.formattedPace,
                    title: "平均配速"
                )
                
                SummaryItem(
                    icon: "clock",
                    value: workout.formattedDuration,
                    title: "运动时长"
                )
                
                SummaryItem(
                    icon: "flame",
                    value: "\(Int(workout.totalEnergyBurned))",
                    title: "消耗(千卡)"
                )
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

/// 摘要数据项
struct SummaryItem: View {
    let icon: String
    let value: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// 跑步详细信息卡片
struct WorkoutDetailsCard: View {
    let workout: RunningWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("详细信息")
                .font(.headline)
                .padding(.bottom, 5)
            
            DetailRow(title: "开始时间", value: formatTime(workout.startDate))
            DetailRow(title: "结束时间", value: formatTime(workout.endDate))
            DetailRow(title: "平均心率", value: "\(Int(workout.averageHeartRate)) BPM")
            DetailRow(title: "运动强度", value: workout.intensityLevel)
            DetailRow(title: "千卡/公里", value: String(format: "%.1f", workout.caloriesPerKilometer))
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// 格式化时间
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 详情行视图

/// 详细信息行视图
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 预览

#Preview {
    RunningWorkoutsView()
}
