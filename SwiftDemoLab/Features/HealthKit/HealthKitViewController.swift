//
//  HealthKitViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/4.
//

import UIKit
import SwiftUI

class HealthKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        // 创建 UIHostingController，将 SwiftUI 视图作为 rootView
        let swiftUIView = RunningWorkoutsView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // 添加为子控制器
        addChild(hostingController)
        // 设置 hostingController 的视图大小等于 self.view
        hostingController.view.frame = self.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // 加入当前 view 层级
        view.addSubview(hostingController.view)
        // 通知 hostingController 已经移动到父控制器
        hostingController.didMove(toParent: self)
    }
}

