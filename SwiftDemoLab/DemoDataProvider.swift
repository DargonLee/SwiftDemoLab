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
                DemoItem(title: "字体动画", desc: "字体变大或者变小有动画效果", controllerType: FontAnimateViewController.self)
            ]),
            DemoSection(title: "粒子动画", items: [
                DemoItem(title: "散花", desc: "散花动画示例", controllerType: FlowerEffectViewController.self),
                DemoItem(title: "烟花", desc: "烟花动画示例", controllerType: FireworksViewController.self),
            ])
        ]
    }
}
