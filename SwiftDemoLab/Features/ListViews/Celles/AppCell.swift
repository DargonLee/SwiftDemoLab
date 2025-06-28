//
//  AppCell.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/28.
//

import UIKit
import SnapKit

class AppCell: UITableViewCell {

    let iconView = UIImageView()
    let titleLabel = UILabel()
    let statusLabel = UILabel()
    let progressLabel = UILabel()
    let helpButton = UIButton(type: .system)
    let arrowIcon = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .color("#19191E")
        backgroundColor = .clear
        selectionStyle = .none
        
        // 添加子视图
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(progressLabel)
        contentView.addSubview(helpButton)
        contentView.addSubview(arrowIcon)
        
        // icon
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 22
        iconView.layer.masksToBounds = true
        
        // 基本属性
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = .white
        
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .systemGray
        
        progressLabel.font = UIFont.systemFont(ofSize: 13)
        progressLabel.textColor = .systemBlue
        
        helpButton.setTitle("", for: .normal)
        helpButton.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        helpButton.tintColor = .systemGray2
        helpButton.addTarget(self, action: #selector(helpTapped(_:)), for: .touchUpInside)
        
        // 设置箭头图片
        arrowIcon.image = UIImage(systemName: "chevron.right")
        arrowIcon.contentMode = .scaleAspectFit
        arrowIcon.tintColor = .systemGray3
        
        // 布局
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(iconView.snp.right).offset(18)
            make.right.lessThanOrEqualTo(arrowIcon.snp.left).offset(-10)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(helpButton.snp.left).offset(-10)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(arrowIcon.snp.left).offset(-10)
        }
        
        arrowIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(8)
            make.height.equalTo(14)
        }
        
        helpButton.snp.makeConstraints { make in
            make.centerY.equalTo(statusLabel)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        
        // 底部分隔线
        let separator = UIView()
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func configure(app: ConnectedApp) {
        titleLabel.text = app.name
        statusLabel.text = app.status
        statusLabel.isHidden = app.status == nil
        
        if let progress = app.progress, let total = app.total, app.isSyncing {
            progressLabel.text = "\(progress)/\(total)"
            progressLabel.isHidden = false
        } else {
            progressLabel.isHidden = true
        }
        
        helpButton.isHidden = true
        arrowIcon.isHidden = true
    }
    
    func configure(title: String, showArrow: Bool = false, showHelp: Bool = false) {
        titleLabel.text = title
        statusLabel.isHidden = true
        progressLabel.isHidden = true
        helpButton.isHidden = !showHelp
        arrowIcon.isHidden = !showArrow
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.image = nil
        iconView.backgroundColor = nil
        titleLabel.text = nil
        statusLabel.text = nil
        progressLabel.text = nil
        helpButton.isHidden = true
        arrowIcon.isHidden = true
    }
    
    @objc func helpTapped(_ sender: UIButton) {
        // 显示帮助信息
    }
}

// 如果UIColor扩展不在这个文件中，添加它


