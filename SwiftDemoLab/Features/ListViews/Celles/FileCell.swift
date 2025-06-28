//
//  FileCell.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/28.
//

import UIKit
import SnapKit

class FileCell: UITableViewCell {
    
    let dateContainer = UIView()
    let dateLabel = UILabel()
    let titleLabel = UILabel()
    let distanceLabel = UILabel()
    let durationLabel = UILabel()
    let paceLabel = UILabel()
    let sourceLabel = UILabel()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d日\nHH:mm"
        return formatter
    }()
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = .black
        backgroundColor = .black
        
        // 日期容器
        dateContainer.backgroundColor = .clear
        contentView.addSubview(dateContainer)
        
        // 日期标签
        dateLabel.numberOfLines = 2
        dateLabel.font = UIFont.systemFont(ofSize: 15)
        dateLabel.textColor = .lightGray
        dateLabel.textAlignment = .center
        dateContainer.addSubview(dateLabel)
        
        // 其他标签
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = .white
        
        distanceLabel.font = UIFont.systemFont(ofSize: 15)
        distanceLabel.textColor = .lightGray
        
        durationLabel.font = UIFont.systemFont(ofSize: 15)
        durationLabel.textColor = .lightGray
        
        paceLabel.font = UIFont.systemFont(ofSize: 15)
        paceLabel.textColor = .lightGray
        
        sourceLabel.font = UIFont.systemFont(ofSize: 13)
        sourceLabel.textColor = .systemGray

        contentView.addSubview(titleLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(paceLabel)
        contentView.addSubview(sourceLabel)
        
        // 布局
        dateContainer.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(16)
            make.centerY.equalTo(contentView)
            make.width.equalTo(40)
            make.height.equalTo(60)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(dateContainer.snp.right).offset(16)
            make.top.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.left.equalTo(distanceLabel.snp.right).offset(20)
            make.centerY.equalTo(distanceLabel)
        }
        
        paceLabel.snp.makeConstraints { make in
            make.left.equalTo(durationLabel.snp.right).offset(20)
            make.centerY.equalTo(distanceLabel)
        }
        
        sourceLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(distanceLabel.snp.bottom).offset(8)
            make.bottom.lessThanOrEqualTo(contentView).offset(-16)
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
    
    func configure(file: ImportedFile) {
        // 设置日期显示
        dateLabel.text = dateFormatter.string(from: file.date)
        
        titleLabel.text = file.title
        distanceLabel.text = file.distance
        durationLabel.text = file.duration
        paceLabel.text = file.pace
        sourceLabel.text = "来源：\(file.source)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        titleLabel.text = nil
        distanceLabel.text = nil
        durationLabel.text = nil
        paceLabel.text = nil
        sourceLabel.text = nil
    }
}
