//
//  TestBottomSheetViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/26.
//

import UIKit

class TestBottomSheetViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupButton()
    }
    
    private func setupButton() {
        let button = UIButton(type: .system)
        button.setTitle("显示底部面板", for: .normal)
        button.addTarget(self, action: #selector(showBottomSheet), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func showBottomSheet() {
        let bottomSheet = BottomSheetViewController()
        bottomSheet.modalPresentationStyle = .overFullScreen
        present(bottomSheet, animated: false)
    }
    
}
