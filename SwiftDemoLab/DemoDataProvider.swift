//
//  DemoDataProvider.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/5/20.
//

import UIKit

struct DemoItem {
    let title: String
    let desc: String
    let controllerType: UIViewController.Type
}

struct DemoSection {
    let title: String
    let items: [DemoItem]
}

struct DemoDataProvider {
    static func allSections() -> [DemoSection] {
        return [
            DemoSection(title: "功能演示", items: [
                DemoItem(title: "测试页面", desc: "TestViewController 示例", controllerType: TestViewController.self),
                DemoItem(title: "字体动画", desc: "字体变大或者变小有动画效果", controllerType: FontAnimateViewController.self),
                DemoItem(title: "Emoji测试", desc: "渲染emoji表情", controllerType: EmojiViewController.self),
                DemoItem(title: "字体动画", desc: "字体变大或者变小有动画效果", controllerType: FontAnimateViewController.self),
                DemoItem(title: "悬浮控制器", desc: "拖动全屏下拉悬浮", controllerType: TestBottomSheetViewController.self),
                DemoItem(title: "列表控制器", desc: "UITableView使用", controllerType: TabViewDemoController.self),
                DemoItem(title: "StackView布局 1", desc: "UIStackView使用", controllerType: StackViewTestController.self),
                DemoItem(title: "StackView布局 2", desc: "UIStackView增强使用", controllerType: EnhancedStackViewTestController.self),
                DemoItem(title: "控制器弹出", desc: "modalPresentationStyle", controllerType: PresentationStyleTestController.self),
                DemoItem(title: "折叠控制器", desc: "tableView实现", controllerType: CollapseController.self),
                DemoItem(title: "AppStore", desc: "UICollectionViewCompositionalLayout实现", controllerType: AppStoreViewController.self),
                DemoItem(title: "滑块视图", desc: "标题区 + 状态圆点 + 分段滑块（1~5 档）+ 底部刻度", controllerType: SegmentedViewController.self),
            ]),
            DemoSection(title: "粒子动画", items: [
                DemoItem(title: "散花", desc: "散花动画示例", controllerType: FlowerEffectViewController.self),
                DemoItem(title: "烟花", desc: "烟花动画示例", controllerType: FireworksViewController.self),
            ]),
            DemoSection(title: "框架使用", items: [
                DemoItem(title: "HealthKit", desc: "HealthKit的数据同步 Demo", controllerType: HealthKitViewController.self),
                DemoItem(title: "CAGradientLayer1", desc: "CAGradientLayer的使用", controllerType: CAGradientLayerViewController.self),
                DemoItem(title: "CAGradientLayer2", desc: "CAGradientLayer的使用", controllerType: CAGradientLayerViewController2.self),
                DemoItem(title: "UseSwiftUIWithUIKit", desc: "SwiftUI和UIKit混编", controllerType: HostingConfigurationViewController.self)
            ])
        ]
    }
}
