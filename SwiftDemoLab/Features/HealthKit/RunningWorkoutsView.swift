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
    @State private var showingErrorAlert = false
    
    var body: some View {
        Group {
            if dataManager.isLoading {
                LoadingView()
            } else if dataManager.errorMessage != nil {
                EmptyView()
                    .onAppear {
                        showingErrorAlert = true
                    }
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
            Task {
                await checkAuthorization()
            }
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
    
    private func checkAuthorization() async {
        // 3. 异步请求授权状态
        let status = await dataManager.checkAuthorizationStatus()
        
        // 4. 处理授权状态
        await handleAuthorizationStatus(status)
    }

    // MARK: - Helper Methods

    private func handleAuthorizationStatus(_ status: HKAuthorizationRequestStatus) async {
        await MainActor.run {
            switch status {
            case .shouldRequest:
                // 需要请求授权，显示授权弹窗
                showingAuthorization = true
            case .unnecessary:
                // 用户已经授权，直接获取数据
                dataManager.fetchRunningWorkouts()
            case .unknown:
                showingErrorAlert = true
                dataManager.errorMessage = "健康数据授权状态未知，请稍后重试。"
            @unknown default:
                showingErrorAlert = true
                dataManager.errorMessage = "未知的健康数据授权状态，请稍后重试。"
            }
        }
    }
    
    private func refreshData() {
        dataManager.fetchRunningWorkouts()
    }
}

struct LoadingView: View {
    var body: some View {
        ProgressView("加载跑步数据中...")
    }
}

struct EmptyWorkoutsView: View {
    var body: some View {
        Text("没有找到跑步记录")
            .foregroundColor(.secondary)
    }
}

#Preview {
    RunningWorkoutsView()
}
