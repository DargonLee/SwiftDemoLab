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
    private lazy var thumbView: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "thumb.icon"), for: .normal)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor(hex: "#03DCC2").cgColor
        return view
    }()
    private let labelTexts = ["1", "3", "5"]
    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        return stack
    }()
    
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
        
        trackView.addSubview(thumbView)
        thumbView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
            make.left.equalToSuperview().offset(16) // 初始位置
        }
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(hex: "#1E253D")
        return label
    }
}
