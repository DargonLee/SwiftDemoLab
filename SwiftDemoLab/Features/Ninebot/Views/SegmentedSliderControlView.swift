//
//  CustomSliderView.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/3.
//


import UIKit
import SnapKit

final class SegmentedSliderControlView: UIView {
    private lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#EBECF0")
        view.layer.cornerRadius = 15
        return view
    }()
    private lazy var thumbButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "thumb.icon"), for: .normal)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor(hex: "#03DCC2").cgColor
        return view
    }()
    private var nodeViews: [UIView] = []
    private let labelTexts = ["1", "3", "5"]
    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        return stack
    }()
    private var panGesture: UIPanGestureRecognizer!
    private var availableWidth: CGFloat {
        let value = trackView.bounds.size.width - thumbButton.bounds.size.width
        return value
    }
    private var totalCount: Int = 0
        
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(trackView)
        trackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(32)
        }
        
        if let lastText = labelTexts.last, let count = Int(lastText) {
            totalCount = count
            for _ in 0..<count {
                let nodeView = UIView()
                nodeView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
                nodeView.layer.cornerRadius = 6
                trackView.addSubview(nodeView)
                nodeViews.append(nodeView)
            }
        }
        
        addSubview(bottomStack)
        bottomStack.snp.makeConstraints { make in
            make.top.equalTo(trackView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }
        bottomStack.backgroundColor = .red
        for i in 0..<labelTexts.count {
            let label = createLabel(text: labelTexts[i])
            bottomStack.addArrangedSubview(label)
        }
        
        trackView.addSubview(thumbButton)
        thumbButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
            make.left.equalToSuperview().offset(16) // 初始位置
        }
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        thumbButton.addGestureRecognizer(panGesture)
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(hex: "#1E253D")
        return label
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        
        switch gesture.state {
        case .began, .changed:
            // 限制在轨道范围内，考虑滑块半径
            print("手势位置: \(point)")
            // 更新活动轨道预览
            
            // 预览即将选中的值
            
        case .ended, .cancelled, .failed:
            print("手势结束或取消")
            
        default:
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 初始位置
        let startX = trackView.minX  + trackView.height
        for (i, node) in nodeViews.enumerated() {
            let ratio = totalCount == 0 ? 0 : CGFloat(i) / CGFloat(totalCount)
            let x = startX + ratio * availableWidth
            let y = trackView.minY + trackView.height / 2
            node.bounds.size = CGSize(width: 12, height: 12)
            node.center = CGPoint(x: x, y: y)
        }
    }
        
}

private extension UIView {
    var minX: CGFloat { frame.minX }
    var maxX: CGFloat { frame.maxX }
    var minY: CGFloat { frame.minY }
    var maxY: CGFloat { frame.maxY }
    var midY: CGFloat { frame.midY }
    var width: CGFloat { frame.width }
    var height: CGFloat { frame.height }
}
