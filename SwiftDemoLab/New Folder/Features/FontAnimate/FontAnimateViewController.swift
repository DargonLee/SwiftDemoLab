//
//  FontAnimateViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/5/20.
//

import UIKit
import SnapKit

class FontAnimateViewController: UIViewController {
    // MARK: - UI Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "字体动画演示"
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var switchCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var modeLabel: UILabel = {
        let label = UILabel()
        label.text = "UILabel"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var modeSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.isOn = true
        switchView.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        return switchView
    }()
    
    private lazy var animCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "动态字体动画效果"
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var textLayer: CATextLayer = {
        let layer = CATextLayer()
        layer.string = "CATextLayer字体动画"
        layer.font = UIFont.boldSystemFont(ofSize: fontSize)
        layer.fontSize = fontSize
        layer.alignmentMode = .center
        layer.contentsScale = UIScreen.main.scale
        layer.foregroundColor = UIColor.label.cgColor
        return layer
    }()
    
    private lazy var biggerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("增大字体", for: .normal)
        button.addTarget(self, action: #selector(increaseFont), for: .touchUpInside)
        beautifyButton(button)
        return button
    }()
    
    private lazy var smallerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("减小字体", for: .normal)
        button.addTarget(self, action: #selector(decreaseFont), for: .touchUpInside)
        beautifyButton(button)
        return button
    }()
    
    // MARK: - Properties
    private var fontSize: CGFloat = 20
    private var useLabelMode = true // true: UILabel, false: CATextLayer
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(switchCard)
        switchCard.addSubview(modeLabel)
        switchCard.addSubview(modeSwitch)
        
        view.addSubview(animCard)
        animCard.addSubview(label)
        animCard.addSubview(containerView)
        containerView.layer.addSublayer(textLayer)
        
        view.addSubview(biggerButton)
        view.addSubview(smallerButton)
        
        containerView.isHidden = true // 默认只显示 label
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.centerX.equalToSuperview()
        }
        
        switchCard.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(56)
        }
        
        modeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        modeSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        animCard.snp.makeConstraints { make in
            make.top.equalTo(switchCard.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(120)
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        biggerButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
            make.left.equalTo(view.snp.centerX).offset(20)
            make.height.equalTo(44)
            make.width.equalTo(120)
        }
        
        smallerButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
            make.right.equalTo(view.snp.centerX).offset(-20)
            make.height.equalTo(44)
            make.width.equalTo(120)
        }
        
        // 设置 textLayer frame
        containerView.layoutIfNeeded()
        textLayer.frame = containerView.bounds
    }
    
    // MARK: - Helper Methods
    private func beautifyButton(_ btn: UIButton) {
        btn.backgroundColor = UIColor.systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.layer.cornerRadius = 22
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 6
    }
    
    // MARK: - Actions
    @objc private func modeChanged() {
        useLabelMode = modeSwitch.isOn
        label.isHidden = !useLabelMode
        containerView.isHidden = useLabelMode
        modeLabel.text = useLabelMode ? "UILabel" : "CATextLayer"
    }
    
    @objc private func increaseFont() {
        let newSize = min(fontSize + 10, 80)
        if useLabelMode {
            animateLabelFontSize(to: newSize)
        } else {
            animateTextLayerFontSize(to: newSize)
        }
    }
    
    @objc private func decreaseFont() {
        let newSize = max(fontSize - 10, 10)
        if useLabelMode {
            animateLabelFontSize(to: newSize)
        } else {
            animateTextLayerFontSize(to: newSize)
        }
    }
    
    private func animateLabelFontSize(to newSize: CGFloat) {
        let newFont = UIFont.systemFont(ofSize: newSize, weight: .bold)
        let duration = 0.35
        UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve, animations: {
            self.label.font = newFont
        }, completion: nil)
        UIView.animate(withDuration: duration / 2, animations: {
            self.label.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: duration / 2) {
                self.label.transform = .identity
            }
        })
        fontSize = newSize
    }
    
    private func animateTextLayerFontSize(to newSize: CGFloat) {
        let animation = CABasicAnimation(keyPath: "fontSize")
        animation.fromValue = fontSize
        animation.toValue = newSize
        animation.duration = 0.35
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        textLayer.add(animation, forKey: "fontSize")
        textLayer.font = UIFont.boldSystemFont(ofSize: newSize)
        textLayer.fontSize = newSize
        fontSize = newSize
    }
}

