    //
    //  FlowerScatterEffectViewController.swift
    //  SwiftDemoLab
    //
    //  Created by Harlans on 2025/5/22.
    //

import UIKit
import SnapKit

class FlowerEffectViewController: UIViewController {
    
    lazy var scatterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("散花 ✨", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 25, bottom: 12, right: 25)
        button.addTarget(self, action: #selector(didTapScatterButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1, green: 0.15, blue: 0.25, alpha: 1.0) // 深色背景
        
        setupViews()
    }
    
    func setupViews() {
        view.addSubview(scatterButton)
        scatterButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
    }
    
    @objc func didTapScatterButton() {
        launchSeed()
    }
    
    func launchSeed() {
        let seedSize: CGFloat = 12
        let seedView = UIView()
        seedView.backgroundColor = .yellow
        seedView.frame = CGRect(x: 0, y: 0, width: seedSize, height: seedSize)
        seedView.layer.cornerRadius = seedSize / 2
        seedView.layer.shadowColor = UIColor.yellow.cgColor
        seedView.layer.shadowRadius = 8
        seedView.layer.shadowOpacity = 0.7
        
            // 起始位置：按钮上方一点
        let startX = view.bounds.midX
        let startY = scatterButton.frame.minY - 30
        seedView.center = CGPoint(x: startX, y: startY)
        
        view.addSubview(seedView)
        
            // 目标位置：屏幕顶部附近
        let endX = view.bounds.midX
        let endY = view.bounds.minY + 80 // 靠近顶部，给散开留点空间
        
        UIView.animate(withDuration: 1.2, delay: 0, options: [.curveEaseOut], animations: {
            seedView.center = CGPoint(x: endX, y: endY)
            seedView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7) // 变小一点
            seedView.alpha = 0.5
        }) { [weak self] _ in
            seedView.removeFromSuperview()
            self?.createScatteringEffect(at: CGPoint(x: endX, y: endY))
        }
    }
    
    func createScatteringEffect(at position: CGPoint) {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = position
        emitterLayer.emitterShape = .point // 从一个点发射
        emitterLayer.renderMode = .additive // 粒子叠加时会更亮，适合烟花效果
                                            // emitterLayer.emitterSize = CGSize(width: 10, height: 10) // 如果形状不是point，可以定义发射区域大小
        
        var emitterCells: [CAEmitterCell] = []
        
        let colors: [UIColor] = [
            UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 1), // Orange
            UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1), // Yellow
            UIColor(red: 0.9, green: 0.3, blue: 0.4, alpha: 1), // Pink
            UIColor.white.withAlphaComponent(0.9)
        ]
        
        for color in colors {
            let petalCell = CAEmitterCell()
            petalCell.birthRate = 150 // 每个cell每秒产生多少粒子 (当emitterLayer.birthRate=1时)
            petalCell.lifetime = 3.0      // 粒子存活时间
            petalCell.lifetimeRange = 1.0 // 存活时间变化范围
            
            petalCell.velocity = CGFloat.random(in: 120...200) // 粒子速度
            petalCell.velocityRange = 60   // 速度变化范围
            
                // 发射方向和范围
            petalCell.emissionLongitude = CGFloat.random(in: 0...(2 * .pi)) // 初始发射方向(随机)
            petalCell.emissionRange = .pi * 2.0 // 360度全方位发射 (相对于emissionLongitude)
            
            petalCell.yAcceleration = 150.0 // Y轴加速度（重力）
            
                // 粒子内容，这里用代码创建简单圆形
                // 你也可以替换为 [UIImage(named: "flower_petal")?.cgImage]
            petalCell.contents = createParticleImage(size: CGSize(width: 8, height: 8), color: color, isRound: true)?.cgImage
            
            petalCell.scale = 1.0
            petalCell.scaleRange = 0.4     // 缩放范围
            petalCell.scaleSpeed = -0.3    // 逐渐缩小
            
            petalCell.alphaSpeed = -0.4    // 逐渐透明
            
            petalCell.spin = .pi / 2       // 初始旋转
            petalCell.spinRange = .pi      // 旋转范围
            
            emitterCells.append(petalCell)
        }
        
        emitterLayer.emitterCells = emitterCells
        view.layer.addSublayer(emitterLayer)
        
            // 发射一阵后停止
            // emitterLayer的birthRate控制其作为发射源的激活状态
            // emitterCell的birthRate控制从该源发射粒子的速率
        emitterLayer.birthRate = 1.0 // 激活发射器层
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { // 短暂爆发
            emitterLayer.birthRate = 0 // 停止产生新的粒子束
        }
        
            // 在所有粒子消失后移除发射器层
            // 计算最长可能的生命周期
        let maxLifetime = emitterCells.map { $0.lifetime + $0.lifetimeRange }.max() ?? 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + maxLifetime + 0.5) { // 加一点缓冲时间
            emitterLayer.removeFromSuperlayer()
        }
    }
    
        // 辅助函数：用代码创建粒子图像 (返回 CGImage)
    func createParticleImage(size: CGSize, color: UIColor, isRound: Bool) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        color.setFill()
        let rect = CGRect(origin: .zero, size: size)
        
        if isRound {
            context.fillEllipse(in: rect)
        } else {
            context.fill(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
