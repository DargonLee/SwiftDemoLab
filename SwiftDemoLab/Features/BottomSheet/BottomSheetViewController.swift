//
//  BottomSheetViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/26.
//

import UIKit
import SnapKit

class BottomSheetViewController: UIViewController {
    
    // MARK: - 配置参数
    private enum Constants {
        static let collapsedHeight: CGFloat = 100 // 折叠状态高度
        static let partialHeight: CGFloat = UIScreen.main.bounds.height * 0.5 // 部分展开高度
        static let fullHeight: CGFloat = UIScreen.main.bounds.height - 50 // 全屏高度(留出状态栏空间)
        static let animationDuration: TimeInterval = 0.3
    }
    
    // MARK: - UI 组件
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 3
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "可拖拽面板"
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.text = "这是一个可拖拽的底部面板组件。\n\n• 向上拖动可展开\n• 向下拖动可折叠\n• 支持三种状态位置\n• 类似微信小程序面板交互"
        tv.font = .systemFont(ofSize: 16)
        tv.isEditable = false
        return tv
    }()
    
    // MARK: - 布局变量
    private var containerHeightConstraint: Constraint!
    private var containerBottomConstraint: Constraint!
    private var currentContainerHeight: CGFloat = Constants.collapsedHeight
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupPanGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
    }
    
    // MARK: - 设置视图
    private func setupView() {
        view.backgroundColor = .clear
        containerView.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        containerView.addSubview(handleView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentTextView)
    }
    
    // MARK: - 设置约束
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            containerHeightConstraint = make.height.equalTo(Constants.collapsedHeight).constraint
            containerBottomConstraint = make.bottom.equalTo(view.snp.bottom).offset(Constants.collapsedHeight).constraint
        }
        
        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(6)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(handleView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    // MARK: - 手势处理
    private func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        containerView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            // 只允许向上拖动或向下拖动不超过初始高度
            let newHeight = currentContainerHeight - translation.y
            if newHeight < Constants.fullHeight {
                containerHeightConstraint.update(offset: newHeight)
                view.layoutIfNeeded()
            }
            
        case .ended:
            // 根据拖动速度和位置决定最终状态
            if velocity.y > 1000 { // 快速下滑
                animateContainerHeight(Constants.collapsedHeight)
            } else if velocity.y < -1000 { // 快速上滑
                animateContainerHeight(Constants.fullHeight)
            } else if containerView.frame.height > Constants.partialHeight {
                animateContainerHeight(Constants.fullHeight)
            } else if containerView.frame.height > Constants.collapsedHeight {
                animateContainerHeight(Constants.partialHeight)
            } else {
                animateContainerHeight(Constants.collapsedHeight)
            }
            
        default:
            break
        }
    }
    
    // MARK: - 动画方法
    private func animatePresentContainer() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.containerBottomConstraint.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.containerHeightConstraint.update(offset: height)
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
}
