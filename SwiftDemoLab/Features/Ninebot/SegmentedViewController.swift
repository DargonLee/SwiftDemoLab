
//
//  SegmentedViewController.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/1.
//

import UIKit

class SegmentedViewController: UIViewController {
    private let comfortRow = SegmentedSliderRowView(frame: .zero, mode: .comfort)
    private let statusDot = StatusDotView()
    private let gearControl = SegmentedSliderView()
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("点击我1", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var button2: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("点击我2", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped2), for: .touchUpInside)
        return button
    }()
    private lazy var bottoms: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [button, button2])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = gradientBackground()
        
        view.addSubview(bottoms)
        bottoms.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottoms.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottoms.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20),
            bottoms.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        
        // 舒适 行
//        comfortRow.titleLabel.text = "舒适"
//        comfortRow.trailingView = statusDot
        
        let stack = UIStackView(arrangedSubviews: [comfortRow, gearControl])
        stack.axis = .vertical
        stack.spacing = 28
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
        
        // 回调
//        gearControl.onValueChanged = { [weak self] v in
//            // 可在此联动状态点/业务逻辑
//            print("档位：$$v)")
//        }
        
        statusDot.addTarget(self, action: #selector(stateChanged(_:)), for: .valueChanged)
        statusDot.onValueChanged = { [weak self] isActive in
            // 可在此联动业务逻辑
            print("状态点激活：\(isActive)")
        }
    }
    
    @objc private func stateChanged(_ sender: StatusDotView) {
        print("active =", sender.isSelected)
    }
    
    private func gradientBackground() -> UIColor {
        // 简化：用系统背景色即可；如果需要渐变，可加一个 CAGradientLayer
        return UIColor.systemGroupedBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 如果要渐变背景，建议在这里添加/更新 CAGradientLayer 的 frame
    }
    
    @objc func buttonTapped() {
        let controller = ComfortLevelViewController()
        present(controller, animated: true)
    }
    
    @objc func buttonTapped2() {
        let controller = SliderSelectorViewController()
        present(controller, animated: true)
    }
}
