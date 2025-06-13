//
//  ImagePreviewIndicatorView.swift
//  SLFoundation
//
//  Created by fenglianyi on 2024/6/24.
//

import UIKit

class ImagePreviewIndicatorView: UIView {
    lazy var label: UILabel = createLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func reloadData(current: Int, totalCount: Int) {
        label.text = "\(current+1)/\(totalCount)"
    }
    
    func setupUI() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLabel() -> UILabel {
        let view = UILabel()
        view.font = UIFont.withFont(size: 12, weight: .medium)
        view.textColor = .white
        return view
    }
}
