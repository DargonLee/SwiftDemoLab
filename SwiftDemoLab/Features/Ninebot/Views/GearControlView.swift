//
//  Untitled.swift
//  SwiftDemoLab
//
//  Created by Harlan on 2025/8/1.
//

import UIKit

//class GearControlView: UIView {
//    let titleRow = LabeledRowView()
//    let slider = SegmentedSliderView(min: 1, max: 5, initial: 2)
//    private let bottomScale = UIStackView()
//    
//    var onValueChanged: ((Int) -> Void)?
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
//    
//    private func setup() {
//        // 标题“档位” + 右侧当前值
//        titleRow.titleLabel.text = "档位"
////        titleRow.valueLabel.text = "2"
//        
//        
//        let vstack = UIStackView(arrangedSubviews: [titleRow, slider, bottomScale])
//        vstack.axis = .vertical
//        vstack.spacing = 16
//        addSubview(vstack)
//        vstack.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            vstack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//            vstack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//            vstack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
//            vstack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
//        ])
//        
//        // 底部刻度 1 3 5
//        bottomScale.axis = .horizontal
//        bottomScale.distribution = .equalCentering
//        bottomScale.alignment = .center
//        let labels = ["1","3","5"].map { txt -> UILabel in
//            let l = UILabel()
//            l.text = txt
//            l.font = .systemFont(ofSize: 18, weight: .regular)
//            l.textColor = UIColor.secondaryLabel
//            return l
//        }
//        let spacerL = UIView()
//        let spacerM = UIView()
//        bottomScale.addArrangedSubview(labels[0])
//        bottomScale.addArrangedSubview(spacerL)
//        bottomScale.addArrangedSubview(labels[1])
//        bottomScale.addArrangedSubview(spacerM)
//        bottomScale.addArrangedSubview(labels[2])
//        
//        slider.delegate = self
//    }
//    
//    func segmentedSlider(_ slider: SegmentedSliderView, didChangeValue value: Int) {
////        titleRow.valueLabel.text = "$$value)"
//        onValueChanged?(value)
//    }
//}
