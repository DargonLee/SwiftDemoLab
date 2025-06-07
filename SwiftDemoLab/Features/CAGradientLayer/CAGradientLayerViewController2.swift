//
//  CAGradientLayerViewController2.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/6/7.
//

import UIKit
import SnapKit


class CAGradientLayerViewController2: UIViewController {
    
    // 持有 Gradient Layer 与相关配置
    let gradientLayer = CAGradientLayer()
    var colors: [UIColor] = [.systemBlue, .systemBlue.withAlphaComponent(0)] {
        didSet { applyGradient() }
    }
    
    enum GradientDirection: String, CaseIterable {
        case topToBottom = "上到下"
        case bottomToTop = "下到上"
        case leftToRight = "左到右"
        case rightToLeft = "右到左"
    }
    var direction: GradientDirection = .topToBottom {
        didSet { applyGradient() }
    }
    var locations: [CGFloat] = [0.0, 1.0] {
        didSet { applyGradient() }
    }
    
    // UI元件
    let gradientView = UIView()
    let directionSegment = UISegmentedControl(items: GradientDirection.allCases.map { $0.rawValue })
    let addColorButton = UIButton(type: .system)
    let removeColorButton = UIButton(type: .system)
    let scrollView = UIScrollView()
    let controlsContainer = UIStackView()
    
    // 动态控件数组
    var colorButtons: [UIButton] = []
    var locationSliders: [UISlider] = []
    var locationLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSubviews()
        setupLayout()
        setupActions()
        applyGradient()
    }
    
    func setupSubviews() {
        gradientView.layer.cornerRadius = 16
        gradientView.clipsToBounds = true
        view.addSubview(gradientView)
        
        directionSegment.selectedSegmentIndex = 0
        view.addSubview(directionSegment)
        
        // 设置容器视图
        controlsContainer.axis = .vertical
        controlsContainer.spacing = 16
        controlsContainer.distribution = .fillEqually
        
        // 设置滚动视图
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(controlsContainer)
        
        // 添加/删除按钮
        addColorButton.setTitle("添加颜色", for: .normal)
        addColorButton.backgroundColor = .systemBlue
        addColorButton.setTitleColor(.white, for: .normal)
        addColorButton.layer.cornerRadius = 8
        view.addSubview(addColorButton)
        
        removeColorButton.setTitle("删除颜色", for: .normal)
        removeColorButton.backgroundColor = .systemRed
        removeColorButton.setTitleColor(.white, for: .normal)
        removeColorButton.layer.cornerRadius = 8
        removeColorButton.isEnabled = colors.count > 2
        view.addSubview(removeColorButton)
        
        // 添加初始颜色控件
        for i in 0..<colors.count {
            addColorControl(at: i)
        }
        
        // 添加一次layer
        gradientView.layer.addSublayer(gradientLayer)
    }
    
    func setupLayout() {
        // 渐变显区
        gradientView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(view.snp.height).multipliedBy(0.36)
        }
        
        directionSegment.snp.makeConstraints { make in
            make.top.equalTo(gradientView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
        }
        
        // 添加/删除按钮
        addColorButton.snp.makeConstraints { make in
            make.top.equalTo(directionSegment.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(32)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        removeColorButton.snp.makeConstraints { make in
            make.top.equalTo(directionSegment.snp.bottom).offset(24)
            make.right.equalToSuperview().offset(-32)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        // 滚动视图
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(addColorButton.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        // 容器视图
        controlsContainer.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.left.right.equalToSuperview().inset(32)
            make.width.equalTo(scrollView).offset(-64)
        }
    }
    
    func setupActions() {
        directionSegment.addTarget(self, action: #selector(directionChanged), for: .valueChanged)
        addColorButton.addTarget(self, action: #selector(addColor), for: .touchUpInside)
        removeColorButton.addTarget(self, action: #selector(removeColor), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 不断刷新layer尺寸
        gradientLayer.frame = gradientView.bounds
    }
    
    func applyGradient() {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations.map { NSNumber(value: Float($0)) }
        
        switch direction {
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        }
        
        // 更新按钮颜色
        for (index, button) in colorButtons.enumerated() {
            button.backgroundColor = colors[index]
        }
    }
    
    // 添加颜色控件
    func addColorControl(at index: Int) {
        // 颜色按钮
        let colorButton = UIButton(type: .system)
        colorButton.setTitle("颜色\(index + 1)", for: .normal)
        colorButton.backgroundColor = colors[index]
        colorButton.setTitleColor(.white, for: .normal)
        colorButton.layer.cornerRadius = 8
        colorButton.tag = index
        colorButton.addTarget(self, action: #selector(chooseColor(_:)), for: .touchUpInside)
        
        // 位置标签
        let locationLabel = UILabel()
        locationLabel.text = "位置\(index + 1): \(String(format: "%.2f", locations[index]))"
        locationLabel.font = .systemFont(ofSize: 14)
        
        // 位置滑块
        let locationSlider = UISlider()
        locationSlider.minimumValue = 0.0
        locationSlider.maximumValue = 1.0
        locationSlider.value = Float(locations[index])
        locationSlider.tag = index
        locationSlider.addTarget(self, action: #selector(locationSliderChanged(_:)), for: .valueChanged)
        
        // 水平堆栈视图
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        horizontalStack.distribution = .fill
        horizontalStack.alignment = .center
        
        // 垂直堆栈视图
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.distribution = .fill
        
        // 添加到堆栈视图
        horizontalStack.addArrangedSubview(colorButton)
        verticalStack.addArrangedSubview(locationLabel)
        verticalStack.addArrangedSubview(locationSlider)
        horizontalStack.addArrangedSubview(verticalStack)
        
        // 设置约束
        colorButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        verticalStack.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(200)
        }
        
        // 添加到容器
        controlsContainer.addArrangedSubview(horizontalStack)
        
        // 保存引用
        colorButtons.append(colorButton)
        locationSliders.append(locationSlider)
        locationLabels.append(locationLabel)
    }
    
    // 移除颜色控件
    func removeColorControl(at index: Int) {
        guard index < colorButtons.count else { return }
        
        // 移除UI
        if let view = controlsContainer.arrangedSubviews[index] as? UIStackView {
            controlsContainer.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // 移除引用
        colorButtons.remove(at: index)
        locationSliders.remove(at: index)
        locationLabels.remove(at: index)
    }
    
    // 更新所有控件的标签
    func updateControlTags() {
        for (index, button) in colorButtons.enumerated() {
            button.tag = index
            button.setTitle("颜色\(index + 1)", for: .normal)
            locationSliders[index].tag = index
            locationLabels[index].text = "位置\(index + 1): \(String(format: "%.2f", locations[index]))"
        }
    }
    
    @objc func directionChanged() {
        direction = GradientDirection.allCases[directionSegment.selectedSegmentIndex]
    }
    
    @objc func locationSliderChanged(_ sender: UISlider) {
        let index = sender.tag
        locations[index] = CGFloat(sender.value)
        locationLabels[index].text = "位置\(index + 1): \(String(format: "%.2f", sender.value))"
        applyGradient()
    }
    
    @objc func chooseColor(_ sender: UIButton) {
        let index = sender.tag
        presentColorPicker(current: colors[index]) { [weak self] newColor in
            guard let self = self, let newColor = newColor else { return }
            self.colors[index] = newColor
            self.applyGradient()
        }
    }
    
    @objc func addColor() {
        // 添加新颜色（默认为最后一个颜色的半透明版本）
        let newColor = colors.last?.withAlphaComponent(0.5) ?? .systemBlue
        colors.append(newColor)
        
        // 计算新位置（在最后两个位置之间）
        let newLocation: CGFloat
        if locations.count >= 2 {
            newLocation = (locations[locations.count - 1] + locations[locations.count - 2]) / 2
        } else {
            newLocation = 0.5
        }
        locations.append(newLocation)
        
        // 添加新控件
        addColorControl(at: colors.count - 1)
        updateControlTags()
        
        // 启用删除按钮
        removeColorButton.isEnabled = colors.count > 2
    }
    
    @objc func removeColor() {
        guard colors.count > 2 else { return }
        
        // 移除最后一个颜色
        colors.removeLast()
        locations.removeLast()
        
        // 移除控件
        removeColorControl(at: colorButtons.count - 1)
        updateControlTags()
        
        // 禁用删除按钮当只有2个颜色时
        removeColorButton.isEnabled = colors.count > 2
    }
    
    // Swift技巧：闭包方式为颜色回调
    private var colorPickCompletion: ((UIColor?) -> Void)?
    func presentColorPicker(current: UIColor, completion: @escaping (UIColor?) -> Void) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = current
        picker.delegate = self
        colorPickCompletion = completion
        present(picker, animated: true)
    }
}

extension CAGradientLayerViewController2: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorPickCompletion?(viewController.selectedColor)
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        colorPickCompletion?(viewController.selectedColor)
    }
}

//class CAGradientLayerViewController2: UIViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = self.view.bounds
//        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemBlue.withAlphaComponent(0).cgColor]
//        gradientLayer.locations = [0.0, 1.0]; // 从顶部到底部的渐变
////        gradientLayer.locations = [0.6, 1.0]; // 从View顶部的60%开始渐变到底部100%
//        
//        // 默认值
////        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
////        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
//        
//        // 从下往上
////        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
////        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
//        
//        // 从左往右
////        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
////        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
//        
//        // 从右往左
//        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
//        
//        self.view.layer.addSublayer(gradientLayer)
//    }
//}
