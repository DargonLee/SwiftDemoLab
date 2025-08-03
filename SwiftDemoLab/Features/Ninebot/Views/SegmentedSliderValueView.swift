//
//  SegmentedSliderHeaderView.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/3.
//

import UIKit
import SnapKit

class SegmentedSliderValueView: UIView {
    // MARK: - Public
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(hex: "#1E253D")
        label.numberOfLines = 1
        label.text = "档位"
        return label
    }()
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(hex: "#1E253D")
        label.numberOfLines = 1
        label.text = "2"
        return label
    }()
    
    // MARK: - Private
    private let stack = UIStackView()
    private let spacer = UIView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.distribution = .fill
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(spacer)
        stack.addArrangedSubview(valueLabel)
    }
    
    func updateValue(_ value: Int) {
        valueLabel.text = "\(value)"
    }
}
