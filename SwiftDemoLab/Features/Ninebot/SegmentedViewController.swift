
//
//  SegmentedViewController.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/1.
//

import UIKit
import SnapKit

class SegmentedViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var comfortRow: SegmentedSliderRowView = {
        let row = SegmentedSliderRowView(frame: .zero, mode: .comfort)
        return row
    }()
    
    private lazy var headerView: SegmentedSliderValueView = {
        let header = SegmentedSliderValueView()
        return header
    }()
    
    private lazy var customSlider: SegmentedSliderControlView = {
        let slider = SegmentedSliderControlView(initialValue: 3) // 设置默认值为3
        slider.delegate = self
        return slider
    }()
    
    private lazy var button1: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("点击我1", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#03DCC2")
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var button2: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("点击我2", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#1E253D")
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(buttonTapped2), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomButtonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [button1, button2])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [comfortRow, headerView, customSlider])
        stack.axis = .vertical
        stack.spacing = 28
        stack.alignment = .fill
        stack.distribution = .fill
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
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // 添加主内容栈
        view.addSubview(mainStack)
        
        // 添加底部按钮栈
        view.addSubview(bottomButtonStack)
    }
    
    private func setupConstraints() {
        // 主内容栈布局
        mainStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        
        // 底部按钮栈布局
        bottomButtonStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(44)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        let controller = ComfortLevelViewController()
        present(controller, animated: true)
    }
    
    @objc private func buttonTapped2() {
        let controller = SliderSelectorViewController()
        present(controller, animated: true)
    }
}

// MARK: - SegmentedSliderControlViewDelegate
extension SegmentedViewController: SegmentedSliderControlViewDelegate {
    func segmentedSlider(_ slider: SegmentedSliderControlView, didChangeValue value: Int) {
        // 当滑块值改变时，更新显示的值
        headerView.updateValue(value)
    }
    
    func segmentedSlider(_ slider: SegmentedSliderControlView, didSelectValue value: Int) {
        // 当滑块值被选中时，更新显示的值
        headerView.updateValue(value)
    }
}
