//
//  TestViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/5/19.
//

import UIKit
import SnapKit

class TestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Hello, Swift! 111"
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = .yellow
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
}

