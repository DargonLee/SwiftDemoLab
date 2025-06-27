//
//  HealthWorkoutListCell.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/27.
//

import SwiftUI

struct HealthWorkoutListData {
    let title: String
    let desc: String
    
    static let sampleData = [
        HealthWorkoutListData(title: "Running", desc: "Daily running workout"),
        HealthWorkoutListData(title: "Cycling", desc: "Weekend cycling adventure"),
        HealthWorkoutListData(title: "Swimming", desc: "Morning swimming session")
    ]
}

struct HealthWorkoutListView: View {
    var body: some View {
        Text("HealthWorkoutListView")
    }
}
