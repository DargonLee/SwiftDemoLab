//
//  HealthLinkCell.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/27.
//

import SwiftUI

import SwiftUI

struct HealthLinkCellData: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    static let sampleData = [
        HealthLinkCellData(title: "步数", icon: "figure.walk"),
        HealthLinkCellData(title: "心率", icon: "heart.fill"),
        HealthLinkCellData(title: "睡眠", icon: "moon.zzz.fill")
    ]
}

struct HealthLinkCell: View {
    let data: HealthLinkCellData
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: data.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundColor(.red)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            Text(data.title)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(.systemBackground))
    }
}

