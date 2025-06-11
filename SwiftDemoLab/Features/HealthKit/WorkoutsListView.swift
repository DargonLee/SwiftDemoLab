//
//  WorkoutsListView.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/11.
//

import SwiftUI
import MapKit
import HealthKit

struct WorkoutsListView: View {
    let runningWorkouts: [RunningWorkout]
    var body: some View {
        List(runningWorkouts) { workout in
            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                WorkoutRowView(workout: workout)
            }
        }
    }
}

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
