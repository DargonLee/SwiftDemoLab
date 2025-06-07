//
//  CAGradientLayerViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/6.
//

import UIKit


class CAGradientLayerViewController: UIViewController {
    
    // MARK: - UI Elements
    private let gradientView = UIView()
    private let colorPaletteView = UIView()
    private let controlsStackView = UIStackView()
    
    // MARK: - Gradient Properties
    private let gradientLayer = CAGradientLayer()
    private var colors: [UIColor] = [.systemRed, .systemYellow, .systemGreen]
    private var locations: [NSNumber] = [0.0, 0.5, 1.0]
    private var startPoint = CGPoint(x: 0, y: 0.5)
    private var endPoint = CGPoint(x: 1, y: 0.5)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGradient()
        setupGestureRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "CAGradientLayer 实验室"
        
        // 渐变视图
        gradientView.layer.cornerRadius = 16
        gradientView.layer.masksToBounds = true
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        
        // 颜色选择面板
        colorPaletteView.translatesAutoresizingMaskIntoConstraints = false
        colorPaletteView.layer.cornerRadius = 8
        colorPaletteView.backgroundColor = .secondarySystemBackground
        view.addSubview(colorPaletteView)
        
        // 控制面板
        controlsStackView.axis = .vertical
        controlsStackView.spacing = 16
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsStackView)
        
        // 约束
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            gradientView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            
            colorPaletteView.topAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: 32),
            colorPaletteView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            colorPaletteView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            colorPaletteView.heightAnchor.constraint(equalToConstant: 60),
            
            controlsStackView.topAnchor.constraint(equalTo: colorPaletteView.bottomAnchor, constant: 32),
            controlsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            controlsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
        // 创建控制按钮
        addControlButtons()
        addColorSelectionButtons()
    }
    
    private func setupGradient() {
        // 配置渐变层
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.cornerRadius = 16
        
        // 添加到视图
        gradientView.layer.addSublayer(gradientLayer)
    }
    
    private func updateGradientFrame() {
        // 更新渐变层尺寸
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - 控制面板
    private func addControlButtons() {
        let titles = [
            "线性渐变 →",
            "线性渐变 ↓",
            "径向渐变",
            "对角线渐变",
            "添加颜色点",
            "移除颜色点"
        ]
        
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(controlButtonTapped(_:)), for: .touchUpInside)
            controlsStackView.addArrangedSubview(button)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }
    
    // MARK: - 颜色选择
    private func addColorSelectionButtons() {
        let colorStackView = UIStackView()
        colorStackView.axis = .horizontal
        colorStackView.distribution = .fillEqually
        colorStackView.spacing = 8
        
        let colors: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow,
            .systemGreen, .systemBlue, .systemPurple,
            .systemPink, .systemTeal, .white
        ]
        
        for (index, color) in colors.enumerated() {
            let button = UIButton()
            button.backgroundColor = color
            button.layer.cornerRadius = 6
            button.layer.borderWidth = color == .white ? 1 : 0
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.tag = index
            button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
            colorStackView.addArrangedSubview(button)
        }
        
        colorPaletteView.addSubview(colorStackView)
        colorStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorStackView.topAnchor.constraint(equalTo: colorPaletteView.topAnchor, constant: 8),
            colorStackView.leadingAnchor.constraint(equalTo: colorPaletteView.leadingAnchor, constant: 8),
            colorStackView.trailingAnchor.constraint(equalTo: colorPaletteView.trailingAnchor, constant: -8),
            colorStackView.bottomAnchor.constraint(equalTo: colorPaletteView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - 手势识别
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGradientTap(_:)))
        gradientView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGradientPan(_:)))
        gradientView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - 事件处理
    @objc private func controlButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0: // 水平渐变
            startPoint = CGPoint(x: 0, y: 0.5)
            endPoint = CGPoint(x: 1, y: 0.5)
        case 1: // 垂直渐变
            startPoint = CGPoint(x: 0.5, y: 0)
            endPoint = CGPoint(x: 0.5, y: 1)
        case 2: // 径向渐变
            gradientLayer.type = .radial
            startPoint = CGPoint(x: 0.5, y: 0.5)
            endPoint = CGPoint(x: 1.5, y: 1.5)
        case 3: // 对角线渐变
            startPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: 1, y: 1)
        case 4: // 添加颜色点
            if colors.count < 5 {
                let newColor = UIColor.randomPastel
                colors.append(newColor)
                locations = locationsForCount(colors.count)
            }
        case 5: // 移除颜色点
            if colors.count > 2 {
                colors.removeLast()
                locations = locationsForCount(colors.count)
            }
        default:
            break
        }
        
        updateGradient()
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        var colors: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow,
            .systemGreen, .systemBlue, .systemPurple,
            .systemPink, .systemTeal, .white
        ]
        
        if sender.tag < colors.count {
            // 替换第一个颜色
            colors[0] = colors[sender.tag]
            updateGradient()
        }
    }
    
    @objc private func handleGradientTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: gradientView)
        let normalizedX = point.x / gradientView.bounds.width
        let normalizedY = point.y / gradientView.bounds.height
        
        // 在点击位置添加新颜色
        if colors.count < 5 {
            colors.append(UIColor.randomPastel)
            locations.append(NSNumber(value: Double(normalizedX)))
            updateGradient()
        }
    }
    
    @objc private func handleGradientPan(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: gradientView)
        let normalizedX = point.x / gradientView.bounds.width
        
        // 动态改变渐变位置
        if colors.count >= 2 {
            locations[1] = NSNumber(value: Double(normalizedX))
            updateGradient()
        }
    }
    
    // MARK: - 辅助方法
    private func updateGradient() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        CATransaction.commit()
    }
    
    private func locationsForCount(_ count: Int) -> [NSNumber] {
        return (0..<count).map { NSNumber(value: Double($0) / Double(count - 1)) }
    }
}

// MARK: - UIColor 扩展
extension UIColor {
    // 随机柔和的颜色
    static var randomPastel: UIColor {
        let hue = CGFloat.random(in: 0...1)
        return UIColor(hue: hue, saturation: 0.6, brightness: 0.95, alpha: 1)
    }
}

