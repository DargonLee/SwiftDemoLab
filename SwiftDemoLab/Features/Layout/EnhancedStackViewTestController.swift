//
//  EnhancedStackViewTestController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/30.
//

import UIKit

class EnhancedStackViewTestController: UIViewController {
    
    // MARK: - UI Elements
    private let stackView = UIStackView()
    private let controlPanel = UIStackView()
    private let statusView = UIView()
    private let statusLabel = UILabel()
    
    // MARK: - Properties
    private var currentAxis: NSLayoutConstraint.Axis = .horizontal
    private var currentDistribution: UIStackView.Distribution = .fill
    private var currentAlignment: UIStackView.Alignment = .fill
    private var currentSpacing: CGFloat = 8.0
    private var currentBaselineRelativeArrangement = false
    private var currentLayoutMarginsRelativeArrangement = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStackView()
        updateStatus()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // 状态视图
        statusView.backgroundColor = .secondarySystemBackground
        statusView.layer.cornerRadius = 8
        view.addSubview(statusView)
        
        statusLabel.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        statusLabel.numberOfLines = 0
        statusView.addSubview(statusLabel)
        
        // 主 StackView 配置
        stackView.backgroundColor = .systemGray6
        stackView.layer.cornerRadius = 8
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.systemGray3.cgColor
        view.addSubview(stackView)
        
        // 控制面板配置
        controlPanel.axis = .vertical
        controlPanel.spacing = 12
        view.addSubview(controlPanel)
        
        // 布局约束
        statusView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor, constant: -12),
            
            stackView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35),
            
            controlPanel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            controlPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            controlPanel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // 添加控制按钮
        addControlButtons()
    }
    
    private func setupStackView() {
        // 创建不同尺寸的示例视图
        let sizes: [CGSize] = [
            CGSize(width: 40, height: 40),
            CGSize(width: 60, height: 30),
            CGSize(width: 50, height: 70),
            CGSize(width: 70, height: 50),
            CGSize(width: 30, height: 60)
        ]
        
        let colors: [UIColor] = [.systemRed, .systemGreen, .systemBlue, .systemOrange, .systemPurple]
        
        for (index, color) in colors.enumerated() {
            let size = sizes[index % sizes.count]
            let view = UIView()
            view.backgroundColor = color
            view.layer.cornerRadius = 4
            
            // 添加标签显示编号
            let label = UILabel()
            label.text = "\(index + 1)"
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 18)
            label.textAlignment = .center
            view.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
            // 添加尺寸约束
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: size.width),
                view.heightAnchor.constraint(equalToConstant: size.height)
            ])
            
            stackView.addArrangedSubview(view)
        }
        
        // 初始配置
        updateStackView()
    }
    
    // MARK: - Control Panel
    private func addControlButtons() {
        // 1. 轴线控制
        addControlSection(title: "AXIS", options: [
            ("Horizontal", #selector(setHorizontalAxis)),
            ("Vertical", #selector(setVerticalAxis))
        ])
        
        // 2. 分布控制
        addControlSection(title: "DISTRIBUTION", options: [
            ("Fill", #selector(setFillDistribution)),
            ("Fill Equally", #selector(setFillEqually)),
            ("Equal Spacing", #selector(setEqualSpacing)),
            ("Equal Centering", #selector(setEqualCentering)),
            ("Fill Proportionally", #selector(setFillProportionally))
        ])
        
        // 3. 对齐控制
        addControlSection(title: "ALIGNMENT", options: [
            ("Fill", #selector(setFillAlignment)),
            ("Leading", #selector(setLeadingAlignment)),
            ("Center", #selector(setCenterAlignment)),
            ("Trailing", #selector(setTrailingAlignment)),
            ("Top", #selector(setTopAlignment)),
            ("Bottom", #selector(setBottomAlignment)),
            ("First Baseline", #selector(setFirstBaselineAlignment))
        ])
        
        // 4. 间距控制
        addControlSection(title: "SPACING", options: [
            ("-10", #selector(decreaseSpacingBy10)),
            ("-5", #selector(decreaseSpacingBy5)),
            ("+5", #selector(increaseSpacingBy5)),
            ("+10", #selector(increaseSpacingBy10))
        ])
        
        // 5. 高级选项
        addControlSection(title: "ADVANCED", options: [
            ("Margins: \(currentLayoutMarginsRelativeArrangement ? "ON" : "OFF")", #selector(toggleLayoutMargins)),
            ("Baseline: \(currentBaselineRelativeArrangement ? "ON" : "OFF")", #selector(toggleBaselineArrangement)),
            ("Add View", #selector(addView)),
            ("Remove View", #selector(removeView))
        ])
    }
    
    private func addControlSection(title: String, options: [(title: String, action: Selector)]) {
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        sectionStack.addArrangedSubview(titleLabel)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        
        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option.title, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.layer.cornerRadius = 6
            button.addTarget(self, action: option.action, for: .touchUpInside)
            buttonStack.addArrangedSubview(button)
        }
        
        sectionStack.addArrangedSubview(buttonStack)
        controlPanel.addArrangedSubview(sectionStack)
    }
    
    // MARK: - StackView 配置更新
    private func updateStackView() {
        UIView.animate(withDuration: 0.3) {
            self.stackView.axis = self.currentAxis
            self.stackView.distribution = self.currentDistribution
            self.stackView.alignment = self.currentAlignment
            self.stackView.spacing = self.currentSpacing
            self.stackView.isBaselineRelativeArrangement = self.currentBaselineRelativeArrangement
            self.stackView.isLayoutMarginsRelativeArrangement = self.currentLayoutMarginsRelativeArrangement
        }
        updateStatus()
    }
    
    private func updateStatus() {
        let axisStr = currentAxis == .horizontal ? "Horizontal" : "Vertical"
        let distributionStr: String
        switch currentDistribution {
        case .fill: distributionStr = "Fill"
        case .fillEqually: distributionStr = "Fill Equally"
        case .fillProportionally: distributionStr = "Fill Proportionally"
        case .equalSpacing: distributionStr = "Equal Spacing"
        case .equalCentering: distributionStr = "Equal Centering"
        @unknown default: distributionStr = "Unknown"
        }
        
        let alignmentStr: String
        switch currentAlignment {
        case .fill: alignmentStr = "Fill"
        case .leading: alignmentStr = "Leading"
        case .top: alignmentStr = "Top"
        case .firstBaseline: alignmentStr = "First Baseline"
        case .center: alignmentStr = "Center"
        case .trailing: alignmentStr = "Trailing"
        case .bottom: alignmentStr = "Bottom"
        @unknown default: alignmentStr = "Unknown"
        }
        
        let statusText = """
        Axis: \(axisStr)
        Distribution: \(distributionStr)
        Alignment: \(alignmentStr)
        Spacing: \(currentSpacing)
        Views: \(stackView.arrangedSubviews.count)
        Baseline Relative: \(currentBaselineRelativeArrangement ? "Yes" : "No")
        Margins Relative: \(currentLayoutMarginsRelativeArrangement ? "Yes" : "No")
        """
        
        statusLabel.text = statusText
    }
    
    // MARK: - 按钮动作方法
    // 轴线控制
    @objc private func setHorizontalAxis() {
        currentAxis = .horizontal
        updateStackView()
    }
    
    @objc private func setVerticalAxis() {
        currentAxis = .vertical
        updateStackView()
    }
    
    // 分布控制
    @objc private func setFillDistribution() {
        currentDistribution = .fill
        updateStackView()
    }
    
    @objc private func setFillEqually() {
        currentDistribution = .fillEqually
        updateStackView()
    }
    
    @objc private func setFillProportionally() {
        currentDistribution = .fillProportionally
        updateStackView()
    }
    
    @objc private func setEqualSpacing() {
        currentDistribution = .equalSpacing
        updateStackView()
    }
    
    @objc private func setEqualCentering() {
        currentDistribution = .equalCentering
        updateStackView()
    }
    
    // 对齐控制
    @objc private func setFillAlignment() {
        currentAlignment = .fill
        updateStackView()
    }
    
    @objc private func setLeadingAlignment() {
        currentAlignment = currentAxis == .horizontal ? .leading : .top
        updateStackView()
    }
    
    @objc private func setTrailingAlignment() {
        currentAlignment = currentAxis == .horizontal ? .trailing : .bottom
        updateStackView()
    }
    
    @objc private func setTopAlignment() {
        currentAlignment = .top
        updateStackView()
    }
    
    @objc private func setCenterAlignment() {
        currentAlignment = .center
        updateStackView()
    }
    
    @objc private func setBottomAlignment() {
        currentAlignment = .bottom
        updateStackView()
    }
    
    @objc private func setFirstBaselineAlignment() {
        currentAlignment = .firstBaseline
        updateStackView()
    }
    
    // 间距控制
    @objc private func increaseSpacingBy5() {
        currentSpacing += 5
        updateStackView()
    }
    
    @objc private func increaseSpacingBy10() {
        currentSpacing += 10
        updateStackView()
    }
    
    @objc private func decreaseSpacingBy5() {
        currentSpacing = max(0, currentSpacing - 5)
        updateStackView()
    }
    
    @objc private func decreaseSpacingBy10() {
        currentSpacing = max(0, currentSpacing - 10)
        updateStackView()
    }
    
    // 高级选项
    @objc private func toggleLayoutMargins() {
        currentLayoutMarginsRelativeArrangement.toggle()
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        updateStackView()
        
        // 更新按钮标题
        if let advancedSection = controlPanel.arrangedSubviews.last as? UIStackView,
           let buttonStack = advancedSection.arrangedSubviews.last as? UIStackView,
           let button = buttonStack.arrangedSubviews.first as? UIButton {
            button.setTitle("Margins: \(currentLayoutMarginsRelativeArrangement ? "ON" : "OFF")", for: .normal)
        }
    }
    
    @objc private func toggleBaselineArrangement() {
        currentBaselineRelativeArrangement.toggle()
        updateStackView()
        
        // 更新按钮标题
        if let advancedSection = controlPanel.arrangedSubviews.last as? UIStackView,
           let buttonStack = advancedSection.arrangedSubviews.last as? UIStackView,
           buttonStack.arrangedSubviews.count > 1,
           let button = buttonStack.arrangedSubviews[1] as? UIButton {
            button.setTitle("Baseline: \(currentBaselineRelativeArrangement ? "ON" : "OFF")", for: .normal)
        }
    }
    
    @objc private func addView() {
        let newView = UIView()
        newView.backgroundColor = UIColor(
            hue: CGFloat.random(in: 0...1),
            saturation: 0.7,
            brightness: 0.8,
            alpha: 1
        )
        newView.layer.cornerRadius = 4
        
        let size = CGSize(width: CGFloat.random(in: 30...70), height: CGFloat.random(in: 30...70))
        newView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        newView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        let label = UILabel()
        label.text = "\(stackView.arrangedSubviews.count + 1)"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        newView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: newView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: newView.centerYAnchor)
        ])
        
        stackView.addArrangedSubview(newView)
        updateStatus()
        
        UIView.animate(withDuration: 0.3) {
            self.stackView.layoutIfNeeded()
        }
    }
    
    @objc private func removeView() {
        guard stackView.arrangedSubviews.count > 1 else { return }
        
        let viewToRemove = stackView.arrangedSubviews.last!
        stackView.removeArrangedSubview(viewToRemove)
        viewToRemove.removeFromSuperview()
        updateStatus()
        
        UIView.animate(withDuration: 0.3) {
            self.stackView.layoutIfNeeded()
        }
    }
}
