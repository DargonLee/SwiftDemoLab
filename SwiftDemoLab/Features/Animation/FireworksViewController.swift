//
//  FireworksViewController.swift
//  SwiftDemoLab
//
//  Created by Harlans on 2025/5/22.
//

import UIKit

class FireworksViewController: UIViewController {
    
    // MARK: - Properties
    private var rocketEmitter: CAEmitterLayer!
    private var launchButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupLaunchButton()
        setupRocketEmitter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateEmitterPosition()
    }
    
    // MARK: - Setup Methods
    private func setupViewController() {
        view.backgroundColor = UIColor.black
        title = "烟花效果"
    }
    
    private func setupLaunchButton() {
        launchButton = UIButton(type: .system)
        launchButton.setTitle("🚀 发射烟花", for: .normal)
        launchButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        launchButton.setTitleColor(.white, for: .normal)
        launchButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        launchButton.layer.cornerRadius = 25
        launchButton.layer.borderWidth = 2
        launchButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        // 添加按钮点击事件
        launchButton.addTarget(self, action: #selector(launchButtonTapped), for: .touchUpInside)
        launchButton.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        launchButton.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        view.addSubview(launchButton)
        
        // 设置按钮约束
        launchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            launchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            launchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            launchButton.widthAnchor.constraint(equalToConstant: 180),
            launchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupRocketEmitter() {
        rocketEmitter = CAEmitterLayer()
        rocketEmitter.emitterShape = .point
        rocketEmitter.renderMode = .additive
        updateEmitterPosition()
        view.layer.addSublayer(rocketEmitter)
    }
    
    private func updateEmitterPosition() {
        guard rocketEmitter != nil else { return }
        rocketEmitter.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.maxY - 100)
    }
    
    // MARK: - Button Actions
    @objc private func launchButtonTapped() {
        launchFirework()
    }
    
    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.launchButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.launchButton.alpha = 0.7
        }
    }
    
    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.launchButton.transform = .identity
            self.launchButton.alpha = 1.0
        }
    }
    
    // MARK: - Firework Launch Logic
    private func launchFirework() {
        // 创建火箭粒子
        let rocket = createRocketCell()
        rocketEmitter.emitterCells = [rocket]
        
        // 按钮发射反馈效果
        createLaunchFeedback()
        
        // 计算爆炸时机和位置
        let flightDuration = 1.8
        let explosionPosition = calculateExplosionPosition()
        
        // 在火箭飞行结束时触发爆炸
        DispatchQueue.main.asyncAfter(deadline: .now() + flightDuration) {
            // 停止火箭发射
            rocket.birthRate = 0
            
            // 创建爆炸效果
            self.createExplosion(at: explosionPosition)
        }
        
        // 清理火箭发射器
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.rocketEmitter.emitterCells = []
        }
    }
    
    private func calculateExplosionPosition() -> CGPoint {
        let explosionY = view.bounds.height * CGFloat.random(in: 0.25...0.55)
        let explosionX = view.bounds.midX + CGFloat.random(in: -120...120)
        return CGPoint(x: explosionX, y: explosionY)
    }
    
    private func createLaunchFeedback() {
        // 按钮颜色变化效果
        UIView.animate(withDuration: 0.2, animations: {
            self.launchButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.8)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.launchButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            }
        }
    }
    
    // MARK: - Rocket Creation
    private func createRocketCell() -> CAEmitterCell {
        let rocket = CAEmitterCell()
        
        // 基本属性
        rocket.name = "rocket"
        rocket.contents = createRocketImage()?.cgImage
        rocket.birthRate = 1.0
        rocket.lifetime = 2.0
        
        // 运动属性
        rocket.velocity = 420
        rocket.velocityRange = 60
        rocket.emissionLongitude = -.pi / 2  // 向上发射
        rocket.emissionRange = .pi / 10      // 发射角度范围
        rocket.yAcceleration = -100          // 重力加速度
        
        // 视觉属性
        rocket.scale = 0.7
        rocket.scaleRange = 0.2
        rocket.alphaSpeed = -0.4
        rocket.color = UIColor.orange.cgColor
        rocket.redRange = 0.3
        rocket.greenRange = 0.2
        rocket.blueRange = 0.1
        
        // 旋转效果
        rocket.spin = .pi / 6
        rocket.spinRange = .pi / 8
        
        return rocket
    }
    
    // MARK: - Explosion Creation
    private func createExplosion(at position: CGPoint) {
        // 创建主爆炸效果
        createMainBurst(at: position)
        
        // 创建彩色粒子散射
        createColorfulParticles(at: position)
        
        // 创建光晕效果
        createGlowEffect(at: position)
        
        // 屏幕闪烁效果
        createScreenFlash()
    }
    
    private func createMainBurst(at position: CGPoint) {
        let burstLayer = CAEmitterLayer()
        burstLayer.emitterPosition = position
        burstLayer.emitterShape = .point
        burstLayer.renderMode = .additive
        
        let mainBurst = CAEmitterCell()
        mainBurst.contents = createCircleParticleImage(size: CGSize(width: 10, height: 10))?.cgImage
        mainBurst.birthRate = 2500
        mainBurst.lifetime = 0.3
        mainBurst.velocity = 300
        mainBurst.velocityRange = 150
        mainBurst.emissionRange = .pi * 2  // 360度爆炸
        mainBurst.yAcceleration = 120
        mainBurst.scale = 1.0
        mainBurst.scaleSpeed = -0.8
        mainBurst.alphaSpeed = -2.5
        mainBurst.color = UIColor.white.cgColor
        mainBurst.redRange = 0.8
        mainBurst.greenRange = 0.8
        mainBurst.blueRange = 0.8
        
        burstLayer.emitterCells = [mainBurst]
        view.layer.addSublayer(burstLayer)
        
        // 清理图层
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            burstLayer.removeFromSuperlayer()
        }
    }
    
    private func createColorfulParticles(at position: CGPoint) {
        let particleLayer = CAEmitterLayer()
        particleLayer.emitterPosition = position
        particleLayer.emitterShape = .point
        particleLayer.renderMode = .additive
        
        // 创建多种颜色的粒子
        let colors: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow, .systemGreen,
            .systemBlue, .systemPurple, .systemPink, .white,
            .cyan, .magenta
        ]
        
        var colorCells: [CAEmitterCell] = []
        
        for (index, color) in colors.enumerated() {
            let particle = CAEmitterCell()
            particle.contents = createStarParticleImage(color: color)?.cgImage
            particle.birthRate = 180
            particle.lifetime = 2.8
            particle.velocity = 220
            particle.velocityRange = 80
            particle.yAcceleration = 100
            
            // 不同颜色在不同方向散射
            let angleStep = (2 * .pi) / Double(colors.count)
            let baseAngle = Double(index) * angleStep
            particle.emissionLongitude = baseAngle
            particle.emissionRange = .pi / 8
            
            particle.scale = 0.8
            particle.scaleSpeed = -0.25
            particle.alphaSpeed = -0.35
            particle.color = color.cgColor
            particle.spin = .pi
            particle.spinRange = .pi / 2
            
            colorCells.append(particle)
        }
        
        particleLayer.emitterCells = colorCells
        view.layer.addSublayer(particleLayer)
        
        // 清理图层
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            particleLayer.removeFromSuperlayer()
        }
    }
    
    private func createGlowEffect(at position: CGPoint) {
        let glowLayer = CAEmitterLayer()
        glowLayer.emitterPosition = position
        glowLayer.emitterShape = .point
        glowLayer.renderMode = .additive
        
        let glow = CAEmitterCell()
        glow.contents = createGlowImage()?.cgImage
        glow.birthRate = 80
        glow.lifetime = 3.5
        glow.velocity = 60
        glow.velocityRange = 40
        glow.emissionRange = .pi * 2
        glow.yAcceleration = 40
        glow.scale = 1.8
        glow.scaleSpeed = -0.2
        glow.alphaSpeed = -0.25
        glow.color = UIColor.white.cgColor
        glow.redRange = 0.6
        glow.greenRange = 0.6
        glow.blueRange = 0.6
        
        glowLayer.emitterCells = [glow]
        view.layer.addSublayer(glowLayer)
        
        // 清理图层
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            glowLayer.removeFromSuperlayer()
        }
    }
    
    private func createScreenFlash() {
        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        flashView.alpha = 0
        view.addSubview(flashView)
        
        // 快速闪烁动画
        UIView.animate(withDuration: 0.05, animations: {
            flashView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                flashView.alpha = 0
            }) { _ in
                flashView.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Particle Image Creation
    private func createRocketImage() -> UIImage? {
        let size = CGSize(width: 10, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 创建火箭尾焰渐变效果
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [
            UIColor.white.cgColor,
            UIColor.orange.cgColor,
            UIColor.red.cgColor,
            UIColor.clear.cgColor
        ]
        let locations: [CGFloat] = [0.0, 0.3, 0.7, 1.0]
        
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) {
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: size.width/2, y: 0),
                end: CGPoint(x: size.width/2, y: size.height),
                options: []
            )
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func createCircleParticleImage(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        let locations: [CGFloat] = [0.0, 1.0]
        
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) {
            context.drawRadialGradient(
                gradient,
                startCenter: center, startRadius: 0,
                endCenter: center, endRadius: radius,
                options: []
            )
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func createStarParticleImage(color: UIColor) -> UIImage? {
        let size = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 绘制五角星
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let outerRadius: CGFloat = 5
        let innerRadius: CGFloat = 2
        
        let path = UIBezierPath()
        
        for i in 0..<10 {
            let angle = CGFloat(i) * .pi / 5 - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func createGlowImage() -> UIImage? {
        let size = CGSize(width: 24, height: 24)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [
            UIColor.white.withAlphaComponent(0.9).cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor,
            UIColor.clear.cgColor
        ]
        let locations: [CGFloat] = [0.0, 0.4, 0.8, 1.0]
        
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) {
            context.drawRadialGradient(
                gradient,
                startCenter: center, startRadius: 0,
                endCenter: center, endRadius: radius,
                options: []
            )
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Touch Interaction (Optional)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: view)
        
        // 避免在按钮区域触发
        if !launchButton.frame.contains(location) {
            createExplosion(at: location)
        }
    }
}
