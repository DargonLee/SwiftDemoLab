//
//  SliderSelectorViewController.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/1.
//

import UIKit
import SnapKit

class SliderSelectorViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "档位"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private lazy var currentValueLabel: UILabel = {
        let label = UILabel()
        label.text = "4"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemRed
        label.textAlignment = .center
        return label
    }()
    
    private lazy var sliderSelector: SliderSelectorView = {
        let slider = SliderSelectorView(min: 1, max: 4, initial: 4)
        slider.delegate = self
        return slider
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(titleLabel)
        view.addSubview(currentValueLabel)
        view.addSubview(sliderSelector)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        
        currentValueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
        }
        
        sliderSelector.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(60)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(80)
        }
    }
}

// MARK: - SliderSelectorViewDelegate
extension SliderSelectorViewController: SliderSelectorViewDelegate {
    func sliderSelector(_ slider: SliderSelectorView, didChangeValue value: Int) {
        currentValueLabel.text = "\(value)"
    }
}

// MARK: - SliderSelectorView
protocol SliderSelectorViewDelegate: AnyObject {
    func sliderSelector(_ slider: SliderSelectorView, didChangeValue value: Int)
}

class SliderSelectorView: UIControl {
    
    // MARK: - Properties
    let minValue: Int
    let maxValue: Int
    private(set) var value: Int {
        didSet {
            if value != oldValue {
                sendActions(for: .valueChanged)
                delegate?.sliderSelector(self, didChangeValue: value)
            }
            updateThumbPosition(animated: true)
            updateNodesColor()
        }
    }
    
    weak var delegate: SliderSelectorViewDelegate?
    
    // MARK: - UI Components
    private lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        view.layer.cornerRadius = 22
        return view
    }()
    
    private lazy var activeTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray
        view.layer.cornerRadius = 22
        return view
    }()
    
    private lazy var thumbOuter: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
        view.layer.cornerRadius = 22
        return view
    }()
    
    private lazy var thumbMiddle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue
        view.layer.cornerRadius = 18
        return view
    }()
    
    private lazy var thumbInner: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed
        view.layer.cornerRadius = 6
        return view
    }()
    
    private var nodeViews: [UIView] = []
    private var nodeLabels: [UILabel] = []
    private var panGesture: UIPanGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!
    
    // MARK: - Initialization
    init(min: Int = 1, max: Int = 4, initial: Int = 4) {
        self.minValue = min
        self.maxValue = max
        self.value = initial.clamped(min ... max)
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.minValue = 1
        self.maxValue = 4
        self.value = 4
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        addSubview(trackView)
        trackView.addSubview(activeTrackView)
        trackView.addSubview(thumbOuter)
        thumbOuter.addSubview(thumbMiddle)
        thumbMiddle.addSubview(thumbInner)
        
        // 创建节点和标签
        let count = maxValue - minValue + 1
        for i in 0..<count {
            let nodeView = UIView()
            nodeView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
            nodeView.layer.cornerRadius = 6
            addSubview(nodeView)
            nodeViews.append(nodeView)
            
            let label = UILabel()
            label.text = "\(minValue + i)"
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            addSubview(label)
            nodeLabels.append(label)
        }
        
        // 手势
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(panGesture)
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 轨道布局
        let trackHeight: CGFloat = 44
        let trackInset: CGFloat = 16
        trackView.frame = CGRect(
            x: trackInset,
            y: (bounds.height - trackHeight) / 2,
            width: bounds.width - trackInset * 2,
            height: trackHeight
        )
        
        // 滑块大小
        let thumbSize: CGFloat = 44
        thumbOuter.bounds.size = CGSize(width: thumbSize, height: thumbSize)
        thumbMiddle.frame = thumbOuter.bounds.insetBy(dx: 6, dy: 6)
        thumbMiddle.layer.cornerRadius = thumbMiddle.bounds.height / 2
        thumbInner.frame = thumbMiddle.bounds.insetBy(dx: 6, dy: 6)
        thumbInner.layer.cornerRadius = thumbInner.bounds.height / 2
        
        // 节点位置 - 在轨道上方居中
        let count = CGFloat(maxValue - minValue)
        let thumbRadius = thumbSize / 2
        let availableWidth = trackView.width - thumbSize // 减去滑块直径
        let startX = trackView.minX + thumbRadius
        let endX = trackView.maxX - thumbRadius
        
        for (i, node) in nodeViews.enumerated() {
            let ratio = count == 0 ? 0 : CGFloat(i) / count
            let x = startX + ratio * availableWidth
            let y = trackView.minY + trackView.height / 2
            node.bounds.size = CGSize(width: 12, height: 12)
            node.center = CGPoint(x: x, y: y)
        }
        
        // 标签位置
        for (i, label) in nodeLabels.enumerated() {
            let ratio = count == 0 ? 0 : CGFloat(i) / count
            let x = startX + ratio * availableWidth
            let y = trackView.maxY + 15
            label.sizeToFit()
            label.center = CGPoint(x: x, y: y)
        }
        
        updateThumbPosition(animated: false)
        updateActiveTrack()
        updateNodesColor()
    }
    
    // MARK: - Private Methods
    private func positionFor(value: Int) -> CGPoint {
        let ratio = CGFloat(value - minValue) / CGFloat(maxValue - minValue)
        let count = CGFloat(maxValue - minValue)
        let thumbRadius = thumbOuter.bounds.width / 2
        let availableWidth = trackView.width - thumbOuter.bounds.width
        let startX = trackView.minX + thumbRadius
        let x = startX + ratio * availableWidth
        let y = trackView.minY + trackView.height / 2 // 与节点位置一致
        return CGPoint(x: x, y: y)
    }
    
    private func updateActiveTrack() {
        let thumbRadius = thumbOuter.bounds.width / 2
        let availableWidth = trackView.width - thumbOuter.bounds.width
        let startX = trackView.minX + thumbRadius
        let ratio = CGFloat(value - minValue) / CGFloat(maxValue - minValue)
        let thumbCenterX = startX + ratio * availableWidth
        let activeWidth = thumbCenterX - trackView.minX
        
        activeTrackView.frame = CGRect(
            x: 0,
            y: 0,
            width: activeWidth,
            height: trackView.bounds.height
        )
    }
    
    private func updateThumbPosition(animated: Bool) {
        let target = positionFor(value: value)
        let apply = {
            self.thumbOuter.center = target
            self.updateActiveTrack()
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: apply)
        } else {
            apply()
        }
    }
    
    private func updateNodesColor() {
        for (i, node) in nodeViews.enumerated() {
            let val = minValue + i
            if val <= value {
                node.backgroundColor = UIColor.systemRed.withAlphaComponent(0.6)
            } else {
                node.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
            }
        }
    }
    
    private func nearestValue(forX x: CGFloat) -> Int {
        let thumbRadius = thumbOuter.bounds.width / 2
        let availableWidth = trackView.width - thumbOuter.bounds.width
        let startX = trackView.minX + thumbRadius
        let endX = trackView.maxX - thumbRadius
        
        let ratio = (x - startX) / max(availableWidth, 1)
        let raw = CGFloat(minValue) + ratio * CGFloat(maxValue - minValue)
        let nearest = Int(round(raw))
        return nearest.clamped(minValue ... maxValue)
    }
    
    private func snapToNearest(point: CGPoint) {
        let thumbRadius = thumbOuter.bounds.width / 2
        let startX = trackView.minX + thumbRadius
        let endX = trackView.maxX - thumbRadius
        let x = max(startX, min(point.x, endX))
        let v = nearestValue(forX: x)
        self.value = v
    }
    
    // MARK: - Gesture Handlers
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        snapToNearest(point: point)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        
        switch gesture.state {
        case .began, .changed:
            // 限制在轨道范围内，考虑滑块半径
            let thumbRadius = thumbOuter.bounds.width / 2
            let availableWidth = trackView.width - thumbOuter.bounds.width
            let startX = trackView.minX + thumbRadius
            let endX = trackView.maxX - thumbRadius
            let x = max(startX, min(point.x, endX))
            let y = trackView.minY + trackView.height / 2 // 与节点位置一致
            thumbOuter.center = CGPoint(x: x, y: y)
            
            // 更新活动轨道预览
            let ratio = (x - startX) / max(availableWidth, 1)
            let thumbCenterX = startX + ratio * availableWidth
            let activeWidth = thumbCenterX - trackView.minX
            activeTrackView.frame = CGRect(
                x: 0,
                y: 0,
                width: activeWidth,
                height: trackView.bounds.height
            )
            
            // 预览即将选中的值
            let nearest = nearestValue(forX: x)
            if nearest != value {
                for (i, node) in nodeViews.enumerated() {
                    let val = minValue + i
                    if val <= nearest {
                        node.backgroundColor = UIColor.systemRed.withAlphaComponent(0.6)
                    } else {
                        node.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
                    }
                }
            }
            
        case .ended, .cancelled, .failed:
            snapToNearest(point: point)
            
        default:
            break
        }
    }
    
    // MARK: - Public Methods
    func setValue(_ newValue: Int, animated: Bool) {
        value = newValue.clamped(minValue ... maxValue)
        updateThumbPosition(animated: animated)
    }
}

// MARK: - Extensions
private extension Comparable {
    func clamped(_ range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
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
