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
    func segmentedSlider(_ slider: SegmentedSliderControlView, didSelectValue value: Int)
    func segmentedSlider(_ slider: SegmentedSliderControlView, didChangeValue value: Int)
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
    
    private var currentValue: Int = 1 {
        didSet {
            if oldValue != currentValue {
                delegate?.segmentedSlider(self, didChangeValue: currentValue)
            }
        }
    }
    
    private var selectedValue: Int = 1 {
        didSet {
            if oldValue != selectedValue {
                delegate?.segmentedSlider(self, didSelectValue: selectedValue)
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
            make.left.equalToSuperview().offset(Constants.thumbSize / 2)
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
            handlePanEnded()
            
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
    
    private func handlePanEnded() {
        // 吸附到最近的节点
        let targetValue = findNearestValue()
        animateToValue(targetValue)
        selectedValue = targetValue
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
    
    private func animateToValue(_ value: Int) {
        let targetX = calculatePositionFromValue(value)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.thumbButton.center.x = targetX
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
        currentValue = clampedValue
        selectedValue = clampedValue
        
        if animated {
            animateToValue(clampedValue)
        } else {
            let targetX = calculatePositionFromValue(clampedValue)
            thumbButton.center.x = targetX
        }
        
        updateVisualState()
    }
    
    func getCurrentValue() -> Int {
        return selectedValue
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
