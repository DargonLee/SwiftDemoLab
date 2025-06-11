//
//  AuthorizationView.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/11.
//

import SwiftUI

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
