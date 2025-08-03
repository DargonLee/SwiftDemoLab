//
//  Untitled.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/1.
//

import UIKit
import SnapKit

final class SegmentedSliderRowView: UIView {
    
    // MARK: - Public
    let statusDot = StatusDotView()
    
    var contentInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet { updateStackConstraints() }
    }
    var statusDotSize: CGSize = CGSize(width: 24, height: 24) {
        didSet {
            statusDot.snp.updateConstraints { make in
                make.width.equalTo(statusDotSize.width)
                make.height.equalTo(statusDotSize.height)
            }
            setNeedsLayout()
        }
    }
    
    // MARK: - Private
    private let stack = UIStackView()
    private let spacer = UIView()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    convenience init(frame: CGRect, mode: DrivingMode) {
        self.init(frame: frame)
        self.titleLabel.text = mode.displayText
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.distribution = .fill
        
        addSubview(stack)
        updateStackConstraints()
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(spacer)
        stack.addArrangedSubview(statusDot)
        
        statusDot.snp.makeConstraints { make in
            make.width.equalTo(statusDotSize.width)
            make.height.equalTo(statusDotSize.height)
        }
    }
    
    private func updateStackConstraints() {
        stack.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(contentInsets.top)
            make.left.equalToSuperview().inset(contentInsets.left)
            make.bottom.equalToSuperview().inset(contentInsets.bottom)
            make.right.equalToSuperview().inset(contentInsets.right)
        }
    }
    
    func setDotActive(_ active: Bool) {
        statusDot.isSelected = active
    }
}

enum DrivingMode: String, CaseIterable {
    case comfort = "COMFORT"
    case standard = "STANDARD"
    case sport = "SPORT"

    var displayText: String {
        switch self {
        case .comfort:
            return "舒适"
        case .standard:
            return "标准"
        case .sport:
            return "运动"
        }
    }
}

