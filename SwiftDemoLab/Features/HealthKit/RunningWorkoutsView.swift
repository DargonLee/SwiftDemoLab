//
//  RunningWorkoutsView.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/4.
//

import SwiftUI
import MapKit
import HealthKit

struct RunningWorkoutsView: View {
    @StateObject private var dataManager = WorkoutDataManager()
    @State private var showingAuthorization = false
    
    var body: some View {
        Group {
            if dataManager.isLoading {
                ProgressView("加载跑步数据中...")
            } else if let error = dataManager.errorMessage {
                VStack {
                    Text(error)
                        .foregroundColor(.red)
                    Button("重试") {
                        dataManager.fetchRunningWorkouts()
                    }
                }
            } else if dataManager.runningWorkouts.isEmpty {
                Text("没有找到跑步记录")
                    .foregroundColor(.secondary)
            } else {
                List(dataManager.runningWorkouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        WorkoutRowView(workout: workout)
                    }
                }
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
    }
    
    private func checkAuthorization() {
        let status = dataManager.healthStore.authorizationStatus(
            for: HKObjectType.workoutType()
        )
        
        if status == .notDetermined || status == .sharingDenied {
            showingAuthorization = true
        } else {
            dataManager.fetchRunningWorkouts()
        }
    }
    
    private func refreshData() {
        dataManager.fetchRunningWorkouts()
    }
}

// 授权视图
struct AuthorizationView: View {
    @ObservedObject var dataManager: WorkoutDataManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("访问跑步数据")
                .font(.title)
            
            Text("请授权访问您的跑步数据，以便显示您的跑步记录和统计数据")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("授权访问") {
                dataManager.requestAuthorization { success in
                    if success {
                        dataManager.fetchRunningWorkouts()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .controlSize(.regular)
            .font(.system(size: 16, weight: .semibold))
            
            Button("稍后再说") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.bordered)
            .tint(.gray)
            .controlSize(.regular)
            .font(.system(size: 16))
        }
        .padding()
    }
}

// 跑步记录行视图
struct WorkoutRowView: View {
    let workout: RunningWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(workout.startDate, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("距离: \(workout.formattedDistance)")
                    Text("配速: \(workout.formattedPace)/公里")
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("时长: \(workout.formattedDuration)")
                    Text("心率: \(Int(workout.averageHeartRate))")
                }
            }
            .font(.callout)
        }
        .padding(.vertical, 8)
    }
}

// 跑步详情视图
struct WorkoutDetailView: View {
    let workout: RunningWorkout
    @State private var region: MKCoordinateRegion
    
    // 起点和终点标记
    private var annotationPoints: [IdentifiableLocation] {
        workout.identifiablePoints
    }
    
    init(workout: RunningWorkout) {
        self.workout = workout
        self._region = State(initialValue: workout.routeRegion)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 地图视图
                Map(coordinateRegion: $region,
                    interactionModes: .all,
                    showsUserLocation: false,
                    annotationItems: annotationPoints) { point in
                    MapAnnotation(coordinate: point.coordinate) {
                        Circle()
                            .fill(point.tint)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(radius: 3)
                    }
                }
                    .frame(height: 300)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                // 统计信息卡片
                VStack(alignment: .leading, spacing: 15) {
                    DetailRow(title: "日期", value: workout.startDate.formatted(date: .long, time: .shortened))
                    DetailRow(title: "距离", value: workout.formattedDistance)
                    DetailRow(title: "平均配速", value: "\(workout.formattedPace)/公里")
                    DetailRow(title: "持续时间", value: workout.formattedDuration)
                    DetailRow(title: "平均心率", value: "\(Int(workout.averageHeartRate)) BPM")
                    DetailRow(title: "消耗能量", value: "\(Int(workout.totalEnergyBurned)) 千卡")
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // 路线图（可选）
                if !workout.routeLocations.isEmpty {
                    VStack(alignment: .leading) {
                        Text("跑步路线")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Map(coordinateRegion: .constant(workout.routeRegion),
                            interactionModes: [],
                            showsUserLocation: false,
                            annotationItems: workout.identifiableRoute) { point in
                            MapAnnotation(coordinate: point.coordinate) {
                                Circle()
                                    .fill(point.tint)
                                    .frame(width: 4, height: 4)
                            }
                        }
                            .frame(height: 200)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("跑步详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 详情行视图
struct DetailRow: View {
    let title: String
    let value: String
    let icon: String?
    
    init(title: String, value: String, icon: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
    }
    
    var body: some View {
        HStack {
            if let iconName = icon {
                Image(systemName: iconName)
                    .foregroundColor(.blue)
                    .frame(width: 24)
            }
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 8)
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

#Preview {
    RunningWorkoutsView()
}
