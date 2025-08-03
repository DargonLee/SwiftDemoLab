//
//  StatusDotView.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/1.
//

import UIKit
import SnapKit

final class StatusDotView: UIControl {
    // MARK: Callbacks
    var onValueChanged: ((Bool) -> Void)?

    // MARK: - Config
    var activeDotColor: UIColor = UIColor(hex: "#56E796")
    var inactiveDotColor: UIColor = UIColor(hex: "#3C4668")
    var activeBgColor: UIColor = UIColor(hex: "#4B526A")
    var inactiveBgColor: UIColor = UIColor(hex: "#BBC0D0")
    var preferredSize: CGSize = CGSize(width: 24, height: 24) {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    // MARK: - State
    override var isSelected: Bool {
        didSet { applyAppearance(animated: true) }
    }
    override var isHighlighted: Bool {
        didSet { applyHighlight(animated: true) }
    }
    override var isEnabled: Bool {
        didSet { applyDisabled(animated: false) }
    }
    
    // MARK: - UI
    private let innerDot: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        applyAppearance(animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        applyAppearance(animated: false)
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = inactiveBgColor
        addSubview(innerDot)
        isUserInteractionEnabled = true
        addTarget(self, action: #selector(tapAction), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        innerDot.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(self).multipliedBy(10.0 / 24.0)
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height)  / 2
        innerDot.layer.cornerRadius = innerDot.bounds.height / 2
    }
    
    override var intrinsicContentSize: CGSize {
        preferredSize
    }
    
    // MARK: - Appearance
    private func applyAppearance(animated: Bool) {
        let updates = {
            self.backgroundColor = self.isSelected ? self.activeBgColor : self.inactiveBgColor
            self.innerDot.backgroundColor = self.isSelected ? self.activeDotColor : self.inactiveDotColor
            self.alpha = self.isEnabled ? 1.0 : 0.5
        }
        if animated {
            UIView.transition(with: self, duration: 0.22, options: [.transitionCrossDissolve, .allowUserInteraction], animations: updates)
        } else {
            updates()
        }
    }
    
    private func applyHighlight(animated: Bool) {
        let updates = {
            self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            self.alpha = self.isHighlighted ? 0.85 : (self.isEnabled ? 1.0 : 0.5)
        }
        if animated {
            UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: updates)
        } else {
            updates()
        }
    }
    
    private func applyDisabled(animated: Bool) {
        self.alpha = isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = isEnabled
    }
    
    // MARK: - Actions
    @objc private func tapAction() {
        isSelected.toggle()
        sendActions(for: .valueChanged)
        onValueChanged?(isSelected)
    }
}
