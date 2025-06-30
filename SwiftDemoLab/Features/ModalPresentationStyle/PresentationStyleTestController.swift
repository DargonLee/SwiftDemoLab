//
//  PresentationStyleTestController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/30.
//

import UIKit

class PresentationStyleTestController: UITableViewController {
    
    // 定义测试数据模型
    struct PresentationStyle {
        let title: String
        let style: UIModalPresentationStyle
        let description: String
    }
    
    // 测试数据
    private let presentationStyles: [PresentationStyle] = [
        PresentationStyle(
            title: "自动选择 (Automatic)",
            style: .automatic,
            description: "系统根据设备和上下文自动选择合适的呈现方式"
        ),
        PresentationStyle(
            title: "全屏 (Full Screen)",
            style: .fullScreen,
            description: "覆盖整个屏幕，默认方式"
        ),
        PresentationStyle(
            title: "页面表单 (Page Sheet)",
            style: .pageSheet,
            description: "在iPhone上类似全屏，在iPad上为居中表单"
        ),
        PresentationStyle(
            title: "表单 (Form Sheet)",
            style: .formSheet,
            description: "在iPad上居中显示，在iPhone上会调整为全屏"
        ),
        PresentationStyle(
            title: "当前上下文 (Current Context)",
            style: .currentContext,
            description: "在父视图控制器定义的区域内呈现"
        ),
        PresentationStyle(
            title: "自定义 (Custom)",
            style: .custom,
            description: "使用自定义的转场动画"
        ),
        PresentationStyle(
            title: "覆盖全屏 (Over Full Screen)",
            style: .overFullScreen,
            description: "覆盖在现有内容之上，不清除背景"
        ),
        PresentationStyle(
            title: "覆盖当前上下文 (Over Current Context)",
            style: .overCurrentContext,
            description: "覆盖在当前视图控制器之上"
        ),
        PresentationStyle(
            title: "弹出框 (Popover)",
            style: .popover,
            description: "以弹出框形式呈现，需要设置锚点"
        ),
        PresentationStyle(
            title: "无 (None)",
            style: .none,
            description: "不使用任何特殊呈现方式"
        ),
        PresentationStyle(
            title: "默认 (Default)",
            style: .automatic,
            description: "使用系统默认呈现方式"
        )
    ]
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "呈现样式测试"
        view.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 70
        
        // 添加导航栏按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "演示设置",
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )
    }
    
    @objc private func showSettings() {
        let settingsController = SettingsController()
        settingsController.modalPresentationStyle = .formSheet
        present(settingsController, animated: true)
    }
    
    // MARK: - TableView 数据源
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationStyles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let style = presentationStyles[indexPath.row]
        
        // 配置单元格
        cell.textLabel?.text = style.title
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        cell.detailTextLabel?.text = style.description
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 2
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .secondarySystemGroupedBackground
        
        return cell
    }
    
    // MARK: - TableView 代理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let style = presentationStyles[indexPath.row]
        showActionSheet(for: style)
    }
    
    private func showActionSheet(for style: PresentationStyle) {
        let alert = UIAlertController(
            title: "选择操作",
            message: "测试: \(style.title)",
            preferredStyle: .actionSheet
        )
        
        // Present 操作
        alert.addAction(UIAlertAction(title: "Present 模态呈现", style: .default) { _ in
            self.presentDemoController(style: style.style)
        })
        
        // Push 操作
        alert.addAction(UIAlertAction(title: "Push 导航推入", style: .default) { _ in
            self.pushDemoController()
        })
        
        // 取消操作
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // 对于 iPad，需要设置弹出位置
        if let popover = alert.popoverPresentationController {
            if let cell = tableView.cellForRow(at: IndexPath(row: presentationStyles.firstIndex(where: { $0.title == style.title })!, section: 0)) {
                popover.sourceView = cell
                popover.sourceRect = cell.bounds
            }
        }
        
        present(alert, animated: true)
    }
    
    private func presentDemoController(style: UIModalPresentationStyle) {
        let demoController = DemoViewController()
        demoController.modalPresentationStyle = style
        demoController.presentationTitle = "Presented: \(presentationStyles.first(where: { $0.style == style })?.title ?? "")"
        
        // 为弹出框样式设置锚点
        if style == .popover, let popover = demoController.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(demoController, animated: true)
    }
    
    private func pushDemoController() {
        let demoController = DemoViewController()
        demoController.presentationTitle = "Pushed via Navigation"
        
        if let navController = navigationController {
            navController.pushViewController(demoController, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: demoController)
            present(nav, animated: true)
        }
    }
}

// MARK: - 演示控制器
class DemoViewController: UIViewController {
    
    var presentationTitle: String = "演示控制器"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 创建容器
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        // 标题标签
        let titleLabel = UILabel()
        titleLabel.text = presentationTitle
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        // 描述标签
        let descriptionLabel = UILabel()
        descriptionLabel.text = "当前模态呈现样式: \(modalPresentationStyle.description)"
        descriptionLabel.font = .systemFont(ofSize: 18)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(descriptionLabel)
        
        // 关闭按钮
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        closeButton.backgroundColor = .systemBlue
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 10
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(closeButton)
        
        // 布局约束
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            container.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            closeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            closeButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 120),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 添加背景视图用于演示透明度
        if modalPresentationStyle == .overFullScreen || modalPresentationStyle == .overCurrentContext {
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            backgroundView.frame = view.bounds
            view.insertSubview(backgroundView, at: 0)
            
            // 添加点击关闭手势
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
            backgroundView.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func close() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - 设置控制器
class SettingsController: UITableViewController {
    
    private let settings = [
        ("背景透明度", "调整模态控制器的背景透明度"),
        ("动画效果", "自定义呈现和消失动画"),
        ("圆角半径", "设置模态控制器的圆角大小"),
        ("阴影效果", "启用/禁用模态控制器的阴影"),
        ("背景模糊", "添加背景模糊效果")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "演示设置"
        view.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingCell")
        tableView.rowHeight = 60
        
        // 添加关闭按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissController)
        )
    }
    
    @objc private func dismissController() {
        dismiss(animated: true)
    }
    
    // MARK: - TableView 数据源
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        let setting = settings[indexPath.row]
        
        // 配置单元格
        cell.textLabel?.text = setting.0
        cell.textLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        cell.detailTextLabel?.text = setting.1
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .secondarySystemGroupedBackground
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(
            title: settings[indexPath.row].0,
            message: "此功能为演示用途，实际应用中可以实现自定义设置",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - 扩展 UIModalPresentationStyle 的描述
extension UIModalPresentationStyle {
    var description: String {
        switch self {
        case .fullScreen:
            return "Full Screen"
        case .pageSheet:
            return "Page Sheet"
        case .formSheet:
            return "Form Sheet"
        case .currentContext:
            return "Current Context"
        case .custom:
            return "Custom"
        case .overFullScreen:
            return "Over Full Screen"
        case .overCurrentContext:
            return "Over Current Context"
        case .popover:
            return "Popover"
        case .none:
            return "None"
        case .automatic:
            return "Automatic"
        @unknown default:
            return "Unknown"
        }
    }
}
