//
//  UIStackViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/30.
//

import UIKit

/*
 @property(nonatomic) UIStackViewDistribution distribution;
 typedef NS_ENUM(NSInteger, UIStackViewDistribution) {
     UIStackViewDistributionFill = 0, //子视图填充满指定方向，优先拉伸第一个控件
     UIStackViewDistributionFillEqually, //每个子视图填充大小相等，
     UIStackViewDistributionFillProportionally, //根据每个子视图里面内容的尺寸来进行填充操作
     UIStackViewDistributionEqualSpacing, //每个子视图之间的间距相等
     UIStackViewDistributionEqualCentering, //每个子视图中心直接的间距相等
 } API_AVAILABLE(ios(9.0));

 
 @property(nonatomic) UIStackViewAlignment alignment;
 typedef NS_ENUM(NSInteger, UIStackViewAlignment) {
     UIStackViewAlignmentFill, //水平:subView的上下和StackView的上下边距 相等   垂直: subView的左右边距和 StackView的所有相等
     UIStackViewAlignmentLeading,//垂直有效 ：左对齐
     UIStackViewAlignmentTop = UIStackViewAlignmentLeading, // 水平有效 上对齐
     UIStackViewAlignmentFirstBaseline,//水平有效，第一行基准线对齐。
     UIStackViewAlignmentCenter, //中心基准线对齐 1.水平 高度中点对齐 2.垂直：宽度中点对齐
     UIStackViewAlignmentTrailing,  //垂直有效，右边界对齐。
     UIStackViewAlignmentBottom = UIStackViewAlignmentTrailing,// 水平有效 ，下边界对齐。
     UIStackViewAlignmentLastBaseline,//水平有效，最后一行基准线对齐。
 } API_AVAILABLE(9_0);
 */

class StackViewTestController: UIViewController {
    
    // MARK: - UI Elements
    private let stackView = UIStackView()
    private let controlPanel = UIStackView()
    
    // MARK: - Properties
    private var currentAxis: NSLayoutConstraint.Axis = .horizontal
    private var currentDistribution: UIStackView.Distribution = .fill
    private var currentAlignment: UIStackView.Alignment = .fill
    private var currentSpacing: CGFloat = 8.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStackView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // 主 StackView 配置
        stackView.backgroundColor = .systemGray6
        stackView.layer.cornerRadius = 8
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.systemGray3.cgColor
        view.addSubview(stackView)
        
        // 控制面板配置
        controlPanel.axis = .vertical
        controlPanel.spacing = 8
        view.addSubview(controlPanel)
        
        // 布局约束
        stackView.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            controlPanel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            controlPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // 添加控制按钮
        addControlButtons()
    }
    
    private func setupStackView() {
        // 创建示例视图
        let colors: [UIColor] = [.systemRed, .systemGreen, .systemBlue, .systemYellow, .systemPurple]
        
        for (index, color) in colors.enumerated() {
            let view = UIView()
            view.backgroundColor = color
            view.layer.cornerRadius = 4
            
            // 添加标签显示编号
            let label = UILabel()
            label.text = "\(index + 1)"
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 24)
            label.textAlignment = .center
            view.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
            // 添加尺寸约束 (确保视图有大小)
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: 60),
                view.heightAnchor.constraint(equalToConstant: 60)
            ])
            
            stackView.addArrangedSubview(view)
        }
        
        // 初始配置
        updateStackView()
    }
    
    // MARK: - Control Panel
    private func addControlButtons() {
        // 1. 轴线控制
        addControlSection(title: "Axis", options: [
            ("Horizontal", #selector(setHorizontalAxis)),
            ("Vertical", #selector(setVerticalAxis))
        ])
        
        // 2. 分布控制
        addControlSection(title: "Distribution", options: [
            ("Fill", #selector(setFillDistribution)),
            ("Fill Equally", #selector(setFillEqually)),
            ("Equal Spacing", #selector(setEqualSpacing)),
            ("Equal Centering", #selector(setEqualCentering))
        ])
        
        // 3. 对齐控制
        addControlSection(title: "Alignment", options: [
            ("Fill", #selector(setFillAlignment)),
            ("Leading", #selector(setLeadingAlignment)),
            ("Center", #selector(setCenterAlignment)),
            ("Trailing", #selector(setTrailingAlignment)),
            ("Top", #selector(setTopAlignment)),
            ("Bottom", #selector(setBottomAlignment))
        ])
        
        // 4. 间距控制
        addControlSection(title: "Spacing", options: [
            ("+ Increase", #selector(increaseSpacing)),
            ("- Decrease", #selector(decreaseSpacing))
        ])
    }
    
    private func addControlSection(title: String, options: [(title: String, action: Selector)]) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        controlPanel.addArrangedSubview(titleLabel)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        
        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option.title, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 6
            button.addTarget(self, action: option.action, for: .touchUpInside)
            buttonStack.addArrangedSubview(button)
        }
        
        controlPanel.addArrangedSubview(buttonStack)
    }
    
    // MARK: - StackView 配置更新
    private func updateStackView() {
        UIView.animate(withDuration: 0.3) {
            self.stackView.axis = self.currentAxis
            self.stackView.distribution = self.currentDistribution
            self.stackView.alignment = self.currentAlignment
            self.stackView.spacing = self.currentSpacing
        }
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
        currentAlignment = .leading
        updateStackView()
    }
    
    @objc private func setTrailingAlignment() {
        currentAlignment = .trailing
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
    
    // 间距控制
    @objc private func increaseSpacing() {
        currentSpacing += 8
        updateStackView()
    }
    
    @objc private func decreaseSpacing() {
        currentSpacing = max(0, currentSpacing - 8)
        updateStackView()
    }
}
