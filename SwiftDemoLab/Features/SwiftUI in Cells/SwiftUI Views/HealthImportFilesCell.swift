//
//  HealthImportFilesCell.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/27.
//

import SwiftUI

struct HealthImportFilesData {
    let title: String
    let icon: String
    static let sampleData = [
        HealthImportFilesData(title: "运动数据文件", icon: "health_import_files_icon")
    ]
}


struct HealthImportFilesView: View {
    var body: some View {
        Text("运动数据文件")
    }
}
