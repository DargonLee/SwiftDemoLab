//
//  SegmentedSliderView.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/1.
//

import UIKit
import SnapKit

final class SegmentedSliderView: UIView {
    let headerView = SegmentedSliderValueView()
    let customSlider = SegmentedSliderControlView()
    private let stack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stack.addArrangedSubview(headerView)
        
        stack.addArrangedSubview(customSlider)
    }
}


