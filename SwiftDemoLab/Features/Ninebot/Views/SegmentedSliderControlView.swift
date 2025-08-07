//
//  SegmentedSliderControlView.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/3.
//

import UIKit
import SnapKit

// MARK: - SegmentedSliderControlViewDelegate
protocol SegmentedSliderControlViewDelegate: AnyObject {
    func segmentedSlider(_ slider: SegmentedSliderControlView, didChangeValue value: Int)
    func segmentedSlider(_ slider: SegmentedSliderControlView, didSelectValue value: Int)
}

// MARK: - SegmentedSliderControlView
final class SegmentedSliderControlView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let trackHeight: CGFloat = 32
        static let thumbSize: CGFloat = 32
        static let nodeSize: CGFloat = 12
        static let trackCornerRadius: CGFloat = 15
        static let thumbCornerRadius: CGFloat = 16
        static let nodeCornerRadius: CGFloat = 6
        static let thumbBorderWidth: CGFloat = 4
        static let bottomStackSpacing: CGFloat = 8
        static let bottomStackInset: CGFloat = 16
        static let labelFontSize: CGFloat = 12
        static let nodeLeftInset: CGFloat = 16
        static let nodeRightInset: CGFloat = 16
    }
    
    // MARK: - Properties
    weak var delegate: SegmentedSliderControlViewDelegate?
    
    private var currentValue: Int = 2 {
        didSet {
            if oldValue != currentValue {
                updateVisualState()
                delegate?.segmentedSlider(self, didChangeValue: currentValue)
            }
        }
    }
    
    private let labelTexts: [String] = ["1", "2", "3", "4", "5"]
    private var nodeViews: [UIView] = []
    private var labelViews: [UILabel] = []
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: - UI Components
    private lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#EBECF0")
        view.layer.cornerRadius = Constants.trackCornerRadius
        return view
    }()
    
    private lazy var thumbButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "thumb.icon"), for: .normal)
//        button.setImage(UIImage(named: "thumb.icon"), for: .highlighted)
        button.layer.cornerRadius = Constants.thumbCornerRadius
        button.layer.borderWidth = Constants.thumbBorderWidth
        button.layer.borderColor = UIColor(hex: "#03DCC2").cgColor
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        return stack
    }()
    
    // MARK: - Computed Properties
    private var availableWidth: CGFloat {
        return trackView.bounds.width - Constants.thumbSize
    }
    
    private var maxValue: Int {
        return labelTexts.count
    }
    
    // MARK: - Initialization
    init(labelTexts: [String] = ["1", "2", "3", "4", "5"]) {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupGestures()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .clear
        
        // 添加轨道视图
        addSubview(trackView)
        
        // 创建节点视图
        createNodeViews()
        
        // 添加底部标签栈
        addSubview(bottomStack)
        createLabelViews()
        
        // 添加滑块
        trackView.addSubview(thumbButton)
    }
    
    private func setupConstraints() {
        trackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Constants.trackHeight)
        }
        
        bottomStack.snp.makeConstraints { make in
            make.top.equalTo(trackView.snp.bottom).offset(Constants.bottomStackSpacing)
            make.left.right.equalToSuperview().inset(Constants.bottomStackInset)
            make.bottom.equalToSuperview()
        }
        
        thumbButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(Constants.thumbSize)
            make.left.equalToSuperview()
        }
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        thumbButton.addGestureRecognizer(panGesture)
    }
    
    // MARK: - UI Creation Methods
    private func createNodeViews() {
        for _ in 0..<maxValue {
            let nodeView = UIView()
            nodeView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
            nodeView.layer.cornerRadius = Constants.nodeCornerRadius
            trackView.addSubview(nodeView)
            nodeViews.append(nodeView)
        }
    }
    
    private func createLabelViews() {
        for text in labelTexts {
            let label = createLabel(text: text)
            bottomStack.addArrangedSubview(label)
            labelViews.append(label)
        }
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .medium)
        label.textColor = UIColor(hex: "#1E253D")
        label.textAlignment = .center
        return label
    }
    
    // MARK: - Gesture Handling
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            handlePanBegan()
            
        case .changed:
            handlePanChanged(translation: translation)
            
        case .ended, .cancelled, .failed:
            let velocity = gesture.velocity(in: self)
            handlePanEnded(velocity: velocity)
            
        default:
            break
        }
    }
    
    private func handlePanBegan() {
        // 可以添加开始拖拽的视觉反馈
    }
    
    private func handlePanChanged(translation: CGPoint) {
        let newX = thumbButton.center.x + translation.x
        let clampedX = clampThumbPosition(newX)
        
        thumbButton.center.x = clampedX
        
        // 更新当前值
        let newValue = calculateValueFromPosition(clampedX)
        if newValue != currentValue {
            currentValue = newValue
            updateVisualState()
        }
        
        // 重置手势的translation
        panGesture.setTranslation(.zero, in: self)
    }
    
    private func handlePanEnded(velocity: CGPoint) {
        // 计算基于速度的目标值
        let targetValue = calculateTargetValueWithVelocity(velocity)
        animateToValueWithVelocity(targetValue, velocity: velocity)
        currentValue = targetValue
        delegate?.segmentedSlider(self, didSelectValue: currentValue)
    }
    
    // MARK: - Helper Methods
    private func clampThumbPosition(_ x: CGFloat) -> CGFloat {
        let minX = Constants.thumbSize / 2
        let maxX = trackView.bounds.width - Constants.thumbSize / 2
        return max(minX, min(maxX, x))
    }
    
    private func calculateValueFromPosition(_ x: CGFloat) -> Int {
        let leftInset = Constants.nodeLeftInset
        let rightInset = Constants.nodeRightInset
        let availableWidth = trackView.bounds.width - leftInset - rightInset
        let minX = leftInset
        let maxX = trackView.bounds.width - rightInset
        let progress = (x - minX) / (maxX - minX)
        let value = Int(round(progress * CGFloat(maxValue - 1))) + 1
        return max(1, min(maxValue, value))
    }
    
    private func findNearestValue() -> Int {
        return currentValue
    }
    
    private func calculateTargetValueWithVelocity(_ velocity: CGPoint) -> Int {
        let velocityThreshold: CGFloat = 300 // 降低速度阈值，让惯性更容易触发
        
        // 如果速度很小，直接吸附到最近的节点
        if abs(velocity.x) < velocityThreshold {
            return findNearestValue()
        }
        
        // 根据速度方向计算目标值
        let currentPosition = thumbButton.center.x
        let leftInset = Constants.nodeLeftInset
        let rightInset = Constants.nodeRightInset
        let availableWidth = trackView.bounds.width - leftInset - rightInset
        
        // 计算当前位置对应的值
        let progress = (currentPosition - leftInset) / availableWidth
        let currentValueFloat = progress * CGFloat(maxValue - 1) + 1
        
        // 根据速度大小和方向计算目标值
        let velocityMagnitude = abs(velocity.x)
        let velocityFactor = min(velocityMagnitude / 1000, 2.0) // 限制最大影响因子
        
        var targetValueFloat = currentValueFloat
        
        if velocity.x > 0 {
            // 向右滑动，值增加
            let increment = velocityFactor
            targetValueFloat = min(CGFloat(maxValue), currentValueFloat + increment)
        } else {
            // 向左滑动，值减少
            let decrement = velocityFactor
            targetValueFloat = max(1, currentValueFloat - decrement)
        }
        
        // 四舍五入到最近的整数值
        let targetValue = Int(round(targetValueFloat))
        return max(1, min(maxValue, targetValue))
    }
    
    private func animateToValue(_ value: Int) {
        let targetX = calculatePositionFromValue(value)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.thumbButton.center.x = targetX
        }
    }
    
    private func animateToValueWithVelocity(_ value: Int, velocity: CGPoint) {
        let targetX = calculatePositionFromValue(value)
        let velocityMagnitude = abs(velocity.x)
        
        // 根据速度调整动画参数
        let duration: TimeInterval
        let springDamping: CGFloat
        let initialVelocity: CGFloat
        
        if velocityMagnitude > 800 {
            // 高速滑动，使用更快的动画，可能有轻微回弹
            duration = 0.3
            springDamping = 0.5
            initialVelocity = velocityMagnitude / 1000 // 使用实际速度
        } else if velocityMagnitude > 400 {
            // 中速滑动
            duration = 0.25
            springDamping = 0.65
            initialVelocity = velocityMagnitude / 1200
        } else {
            // 低速滑动，使用标准动画
            duration = 0.2
            springDamping = 0.8
            initialVelocity = 0.5
        }
        
        // 添加轻微的缩放效果
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: initialVelocity, options: .curveEaseOut) {
            self.thumbButton.center.x = targetX
            // 轻微的缩放效果
            self.thumbButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            // 恢复原始大小
            UIView.animate(withDuration: 0.1) {
                self.thumbButton.transform = .identity
            }
        }
    }
    
    private func calculatePositionFromValue(_ value: Int) -> CGFloat {
        let leftInset = Constants.nodeLeftInset
        let rightInset = Constants.nodeRightInset
        let minX = leftInset
        let maxX = trackView.bounds.width - rightInset
        let progress = CGFloat(value - 1) / CGFloat(maxValue - 1)
        return minX + progress * (maxX - minX)
    }
    
    private func updateVisualState() {
        // 更新节点状态
        for (index, nodeView) in nodeViews.enumerated() {
            let isActive = index < currentValue
            nodeView.backgroundColor = isActive ? UIColor(hex: "#03DCC2").withAlphaComponent(0.6) : UIColor.systemRed.withAlphaComponent(0.3)
        }
        
        // 更新标签状态
        for (index, labelView) in labelViews.enumerated() {
            let isActive = index < currentValue
            labelView.textColor = isActive ? UIColor(hex: "#03DCC2") : UIColor(hex: "#1E253D")
            labelView.font = isActive ? .systemFont(ofSize: Constants.labelFontSize, weight: .bold) : .systemFont(ofSize: Constants.labelFontSize, weight: .medium)
        }
    }
    
    // MARK: - Public Methods
    func setValue(_ value: Int, animated: Bool = true) {
        let clampedValue = max(1, min(maxValue, value))
        
        if animated {
            animateToValue(clampedValue)
        } else {
            let targetX = calculatePositionFromValue(clampedValue)
            thumbButton.center.x = targetX
        }
        
        currentValue = clampedValue
    }
    
    func getCurrentValue() -> Int {
        return currentValue
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateNodePositions()
    }
    
    private func updateNodePositions() {
        guard !nodeViews.isEmpty else { return }
        
        let trackWidth = trackView.bounds.width
        let leftInset = Constants.nodeLeftInset
        let rightInset = Constants.nodeRightInset
        let availableWidth = trackWidth - leftInset - rightInset
        
        // 如果只有一个节点，居中显示
        if nodeViews.count == 1 {
            let x = trackWidth / 2
            let y = trackView.bounds.height / 2
            nodeViews[0].frame = CGRect(
                x: x - Constants.nodeSize / 2,
                y: y - Constants.nodeSize / 2,
                width: Constants.nodeSize,
                height: Constants.nodeSize
            )
            return
        }
        
        // 计算节点间距
        let nodeSpacing = availableWidth / CGFloat(nodeViews.count - 1)
        
        for (index, nodeView) in nodeViews.enumerated() {
            let x = leftInset + nodeSpacing * CGFloat(index)
            let y = trackView.bounds.height / 2
            
            nodeView.frame = CGRect(
                x: x - Constants.nodeSize / 2,
                y: y - Constants.nodeSize / 2,
                width: Constants.nodeSize,
                height: Constants.nodeSize
            )
        }
    }
}

// MARK: - UIView Extension
private extension UIView {
    var minX: CGFloat { frame.minX }
    var maxX: CGFloat { frame.maxX }
    var minY: CGFloat { frame.minY }
    var maxY: CGFloat { frame.maxY }
    var midY: CGFloat { frame.midY }
    var width: CGFloat { frame.width }
    var height: CGFloat { frame.height }
}
