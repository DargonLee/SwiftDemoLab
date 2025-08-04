//
//  SegmentedSliderViewController.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/3.
//

import UIKit
import SnapKit

class SegmentedSliderViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "分段滑块控制器"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(hex: "#1E253D")
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "拖拽滑块选择不同的值"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(hex: "#666666")
        label.textAlignment = .center
        return label
    }()
    
    private lazy var segmentedSlider: SegmentedSliderControlView = {
        let slider = SegmentedSliderControlView(labelTexts: ["1", "3", "5"])
        slider.delegate = self
        return slider
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.text = "当前值: 1"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(hex: "#03DCC2")
        label.textAlignment = .center
        return label
    }()
    
    private lazy var controlStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加控制栈
        view.addSubview(controlStack)
        
        // 添加标题和描述
        controlStack.addArrangedSubview(titleLabel)
        controlStack.addArrangedSubview(descriptionLabel)
        
        // 添加滑块
        controlStack.addArrangedSubview(segmentedSlider)
        
        // 添加值显示标签
        controlStack.addArrangedSubview(valueLabel)
        
        // 添加按钮栈
        controlStack.addArrangedSubview(buttonStack)
        
        // 创建控制按钮
        createControlButtons()
    }
    
    private func setupConstraints() {
        controlStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(32)
        }
        
        segmentedSlider.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo(80)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
    }
    
    private func createControlButtons() {
        // 重置按钮
        let resetButton = createButton(title: "重置", action: #selector(resetSlider))
        buttonStack.addArrangedSubview(resetButton)
        
        // 设置最大值按钮
        let maxButton = createButton(title: "最大值", action: #selector(setMaxValue))
        buttonStack.addArrangedSubview(maxButton)
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#03DCC2")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    @objc private func resetSlider() {
        segmentedSlider.setValue(1, animated: true)
        updateValueLabel(1)
    }
    
    @objc private func setMaxValue() {
        segmentedSlider.setValue(5, animated: true)
        updateValueLabel(5)
    }
    
    private func updateValueLabel(_ value: Int) {
        valueLabel.text = "当前值: \(value)"
    }
    
    // MARK: - Debug Info
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 打印节点位置信息用于调试
        print("滑块组件布局完成")
        print("当前值: \(segmentedSlider.getCurrentValue())")
    }
}

// MARK: - SegmentedSliderControlViewDelegate
extension SegmentedSliderViewController: SegmentedSliderControlViewDelegate {
    
    func segmentedSlider(_ slider: SegmentedSliderControlView, didChangeValue value: Int) {
        print("滑块值变化为: \(value)")
    }
    
    func segmentedSlider(_ slider: SegmentedSliderControlView, didSelectValue value: Int) {
        updateValueLabel(value)
        print("滑块选择了值: \(value) - 带有惯性效果")
    }
} 