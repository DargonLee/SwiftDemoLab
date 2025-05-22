//
//  FireworksViewController.swift
//  SwiftDemoLab
//
//  Created by Harlans on 2025/5/22.
//

import UIKit
import QuartzCore

class FireworksViewController: UIViewController {

    // 發射器圖層 (Emitter Layer)
    private var fireworksEmitter: CAEmitterLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // 設定背景為黑色以突顯煙火
        setupFireworks()
        startFireworks() // 你也可以在某個事件觸發後才啟動，例如按鈕點擊
    }

    private func setupFireworks() {
        // 1. 創建發射器圖層
        fireworksEmitter = CAEmitterLayer()
        fireworksEmitter.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.maxY - 50) // 從底部中間發射
        fireworksEmitter.emitterShape = .line // 從一條線上發射，模擬多個發射點
        fireworksEmitter.emitterSize = CGSize(width: view.bounds.width - 100, height: 20) // 發射線的寬度
        fireworksEmitter.renderMode = .additive // 混合模式，讓顏色更亮

        // 2. 創建煙火"火箭" (上升的轨迹)
        let rocketCell = CAEmitterCell()
        rocketCell.emissionLongitude = -CGFloat.pi / 2 // 向上發射 (M_PI_2 在 Swift 中是 Double，需要轉換)
        rocketCell.emissionLatitude = 0
        rocketCell.emissionRange = CGFloat.pi / 4 // 發射角度範圍，製造一些隨機性
        rocketCell.lifetime = 2.0 // 火箭生命週期 (秒)
        rocketCell.birthRate = 1 // 每秒產生1個火箭
        rocketCell.velocity = 400 // 火箭初始速度
        rocketCell.velocityRange = 100 // 速度隨機範圍
        rocketCell.yAcceleration = -30 // 模擬重力 (向上為負)
        rocketCell.color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5).cgColor // 火箭軌跡顏色
        rocketCell.redRange = 0.7
        rocketCell.greenRange = 0.7
        rocketCell.blueRange = 0.7

        // 火箭的"尾巴" (小火花)
        rocketCell.contents = UIImage(named: "spark")?.cgImage // 需要一張名為 "spark" 的小圖片作為粒子
                                                              // 如果沒有圖片，可以使用一個小的純色方塊
        if rocketCell.contents == nil {
            rocketCell.contents = createFallbackSparkImage()?.cgImage
        }
        rocketCell.scale = 0.3
        rocketCell.scaleRange = 0.1


        // 3. 創建煙火"爆炸"效果
        let explosionCell = CAEmitterCell()
        explosionCell.name = "explosion" // 給爆炸效果命名，方便之後觸發
        explosionCell.emissionLongitude = CGFloat.pi * 2 // 360度全方向發射 (2 * M_PI)
        explosionCell.emissionRange = CGFloat.pi * 2 // 確保是全方向
        explosionCell.lifetime = 0.8 // 爆炸粒子生命週期
        explosionCell.birthRate = 0 // 初始不產生，由火箭觸發
        explosionCell.velocity = 250
        explosionCell.velocityRange = 50
        explosionCell.yAcceleration = 80 // 爆炸後粒子受重力下墜
        explosionCell.spin = CGFloat.pi * 2 // 粒子旋轉
        explosionCell.spinRange = CGFloat.pi * 2

        explosionCell.contents = UIImage(named: "spark")?.cgImage
        if explosionCell.contents == nil {
            explosionCell.contents = createFallbackSparkImage()?.cgImage
        }
        explosionCell.scale = 0.5
        explosionCell.scaleSpeed = -0.2 // 粒子逐漸變小
        explosionCell.alphaSpeed = -0.8 // 粒子逐漸消失

        // 為爆炸粒子設定多種顏色
        let colors: [UIColor] = [
            .red, .orange, .yellow, .green, .blue, .purple, .white
        ]
        explosionCell.emitterCells = colors.map { color in
            let colorSpark = CAEmitterCell()
            colorSpark.birthRate = 500 // 每個爆炸產生大量彩色粒子
            colorSpark.lifetime = 0.5
            colorSpark.velocity = 50
            colorSpark.scale = 0.8
            colorSpark.contents = UIImage(named: "spark")?.cgImage
            if colorSpark.contents == nil {
                colorSpark.contents = createFallbackSparkImage(color: color)?.cgImage
            }
            colorSpark.color = color.cgColor
            colorSpark.redSpeed = CGFloat.random(in: -1.0...1.0) // 顏色隨時間稍微變化
            colorSpark.greenSpeed = CGFloat.random(in: -1.0...1.0)
            colorSpark.blueSpeed = CGFloat.random(in: -1.0...1.0)
            colorSpark.beginTime = 0.01 // 稍微延遲出現，讓爆炸更有層次
            colorSpark.duration = 0.3 // 彩色粒子持續時間
            return colorSpark
        }


        // 4. 將爆炸效果作為子發射器添加到火箭上
        // 這裡我們使用 KVC (Key-Value Coding) 在火箭生命結束時觸發爆炸
        // 另一種更現代的方式是使用 CAAction 或代理，但 KVC 比較簡潔
        // 注意：setValue(_:forKeyPath:) 中的 "emitterCells.explosion.birthRate"
        // 是指當火箭 (rocketCell) 的生命週期結束時，將名為 "explosion" 的子發射器 (explosionCell) 的 birthRate 設為一個值 (例如 5000)
        // 從而觸發爆炸。但 CAEmitterCell 本身沒有直接的 "death event" 可以掛鉤。
        // 通常的做法是讓火箭本身也包含一些短生命週期的粒子，然後在火箭消失的位置創建一個新的、短暫的爆炸發射器。

        // 為了簡化，我們讓火箭本身也帶有一些爆炸粒子，這些粒子會在火箭的生命週期內發射。
        // 更真實的煙火會在火箭到達頂點後才爆炸。
        // 這裡我們創建一個單獨的爆炸發射器，並在火箭到達預期高度時觸發它。
        // 我們將火箭和爆炸效果都添加到主發射器中。
        // 主發射器發射火箭，火箭本身不直接觸發爆炸。
        // 我們會通過編程方式在適當的時候創建爆炸。

        fireworksEmitter.emitterCells = [rocketCell] // 主發射器只發射火箭

        // 將爆炸效果作為一個可以被觸發的模板（但不直接添加到主發射器）
        // 我們會在火箭到達頂點時，手動創建一個基於 explosionCell 的臨時發射器
        // 或者，更簡單的方式是，讓火箭在生命結束時產生爆炸粒子
        rocketCell.emitterCells = [explosionCell] // 將爆炸粒子作為火箭的子粒子
                                                  // 這樣當火箭粒子產生時，它內部也會產生爆炸粒子

        // 調整 rocketCell 使其在生命結束時觸發 explosionCell
        // 這裡我們讓 explosionCell 的 birthRate 在火箭生命週期結束時變為一個較大的值
        // 這需要一個技巧，因為 CAEmitterCell 沒有直接的 "onDeath" 回調。
        // 一個常見方法是讓火箭粒子本身包含爆炸粒子，並調整它們的 `beginTime` 和 `duration`。

        // 這裡我們簡化處理：讓火箭在飛行過程中就開始"洩漏"一些爆炸粒子，
        // 並且在其生命週期結束前，爆炸粒子的 birthRate 會增加。
        // 但更常見且效果更好的是在火箭到達頂點時，創建一個新的 CAEmitterLayer 來處理爆炸。

        // 為了這個範例，我們讓火箭粒子在它的生命結束時，其子發射器 explosionCell 的 birthRate 增加。
        // 這通常通過設置 `emitterCells` 數組並調整其屬性來完成。
        // CAEmitterCell 的 `birthRate` 是每秒粒子數。
        // 我們希望爆炸是一次性的，所以 explosionCell 的 `birthRate` 應該只在短時間內很高。
        // 這裡的 `explosionCell.birthRate = 0` 意味著它平時不產生粒子。
        // 我們需要一種機制來在火箭 "死亡" 時將其 birthRate 提高。

        // 一個簡單的模擬方式是：火箭本身就是一個短暫的發射源，它發射出爆炸粒子。
        // 我們讓火箭粒子在生命週期結束時，其子發射器 explosionCell 的 birthRate 增加。
        // 這可以通過 KVC 實現，但更直接的方式是讓 explosionCell 的 lifetime 非常短，
        // 並且 birthRate 很高，然後將它作為 rocketCell 的子 cell。
        // rocketCell.emitterCells = [createProgrammaticExplosionCell()]
        // 上述的 rocketCell.emitterCells = [explosionCell] 已經做了這件事，
        // 但 explosionCell 的 birthRate 是 0。
        // 我們需要讓 rocketCell 在其生命週期的某個點（例如結束時）觸發 explosionCell。

        // 實際上，更可控的方式是：
        // 1. 發射器只發射火箭。
        // 2. 監測火箭（或估算其到達頂點的時間）。
        // 3. 在火箭到達頂點的位置，動態創建一個新的 CAEmitterLayer 來產生爆炸效果，該 layer 的 lifetime 很短。

        // 為了簡化這個範例，我們將使用另一種策略：
        // 火箭粒子本身在其生命週期的末尾產生爆炸粒子。
        // 我們讓 explosionCell 的 beginTime 接近 rocketCell 的 lifetime。
        let actualExplosionCell = CAEmitterCell()
        actualExplosionCell.name = "actualExplosion"
        actualExplosionCell.birthRate = 5000 // 一次性爆發大量粒子
        actualExplosionCell.lifetime = 0.05 // 爆炸發射源的生命週期極短，確保是一次性
        actualExplosionCell.beginTime = rocketCell.lifetime - 0.1 // 在火箭生命週期快結束時開始

        actualExplosionCell.emissionLongitude = CGFloat.pi * 2
        actualExplosionCell.emissionRange = CGFloat.pi * 2
        actualExplosionCell.velocity = 150 // 爆炸粒子速度
        actualExplosionCell.velocityRange = 50
        actualExplosionCell.yAcceleration = 40 // 模擬重力
        actualExplosionCell.spin = CGFloat.pi
        actualExplosionCell.spinRange = CGFloat.pi
        actualExplosionCell.scale = 0.1
        actualExplosionCell.scaleSpeed = -0.05
        actualExplosionCell.alphaSpeed = -1.5 // 快速消失

        // 為實際爆炸粒子設定多種顏色
        var explosionParticles: [CAEmitterCell] = []
        for color in colors {
            let spark = CAEmitterCell()
            spark.birthRate = 200 // 每個爆炸顏色產生一些粒子
            spark.lifetime = 1.5      // 粒子持續時間長一些
            spark.velocity = 100
            spark.velocityRange = 30
            spark.yAcceleration = 30
            spark.emissionLongitude = CGFloat.pi * 2
            spark.emissionRange = CGFloat.pi * 2
            spark.contents = UIImage(named: "spark")?.cgImage ?? createFallbackSparkImage(color: color)?.cgImage
            spark.color = color.cgColor
            spark.scale = 0.6
            spark.scaleSpeed = -0.3
            spark.alphaSpeed = -0.8
            explosionParticles.append(spark)
        }
        actualExplosionCell.emitterCells = explosionParticles
        rocketCell.emitterCells = [actualExplosionCell] // 火箭在其生命結束時觸發這個 explosion

        // 5. 將發射器圖層添加到視圖
        view.layer.addSublayer(fireworksEmitter)
    }

    // 輔助函數：創建一個備用的粒子圖像 (如果 "spark.png" 不存在)
    private func createFallbackSparkImage(size: CGSize = CGSize(width: 10, height: 10), color: UIColor = .white) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        color.setFill()
        context.fillEllipse(in: CGRect(origin: .zero, size: size))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }


    // 你可以添加方法來控制煙火的開始和停止
    public func startFireworks() {
        // 可以通過設置 birthRate 來控制發射
        // fireworksEmitter.birthRate = 1 // 開始發射
        // 實際上，是 rocketCell 的 birthRate 控制火箭的產生
        // fireworksEmitter.setValue(1, forKeyPath: "emitterCells.rocket.birthRate")
        // 由於我們直接修改了 emitterCells 數組，可以直接設置
        if let rocket = fireworksEmitter.emitterCells?.first {
            rocket.birthRate = 1 // 開始發射火箭
        }
    }

    public func stopFireworks() {
        if let rocket = fireworksEmitter.emitterCells?.first {
            rocket.birthRate = 0 // 停止發射火箭
        }
        // fireworksEmitter.birthRate = 0 // 停止發射
    }

    // 觸發一次性的爆炸 (如果需要手動觸發)
    public func triggerExplosion(at point: CGPoint) {
        let explosionLayer = CAEmitterLayer()
        explosionLayer.emitterPosition = point
        explosionLayer.renderMode = .additive
        explosionLayer.emitterShape = .point
        explosionLayer.lifetime = 0.5 // 爆炸發射器本身的生命週期

        let singleExplosionCell = CAEmitterCell()
        // ... (複製上面 actualExplosionCell 的屬性，但 birthRate 可能需要調整)
        singleExplosionCell.birthRate = 1 // 只觸發一次這個 "發射源"
        singleExplosionCell.lifetime = 0.1 // 發射源的生命週期
        // ... 其他屬性 (velocity, yAcceleration, scale, alphaSpeed, etc.)
        // ... 並設置其 emitterCells (彩色粒子)

        // 這裡我們重用之前定義的 actualExplosionCell 的配置
        let actualExplosionCellCopy = CAEmitterCell()
        actualExplosionCellCopy.name = "manualExplosion"
        actualExplosionCellCopy.birthRate = 5000
        actualExplosionCellCopy.lifetime = 0.05
        // 不需要 beginTime，因為是立即觸發
        actualExplosionCellCopy.emissionLongitude = CGFloat.pi * 2
        actualExplosionCellCopy.emissionRange = CGFloat.pi * 2
        actualExplosionCellCopy.velocity = 150
        actualExplosionCellCopy.velocityRange = 50
        actualExplosionCellCopy.yAcceleration = 40
        actualExplosionCellCopy.spin = CGFloat.pi
        actualExplosionCellCopy.spinRange = CGFloat.pi
        actualExplosionCellCopy.scale = 0.1
        actualExplosionCellCopy.scaleSpeed = -0.05
        actualExplosionCellCopy.alphaSpeed = -1.5

        var explosionParticles: [CAEmitterCell] = []
        let colors: [UIColor] = [ .red, .orange, .yellow, .green, .blue, .purple, .white ]
        for color in colors {
            let spark = CAEmitterCell()
            spark.birthRate = 200
            spark.lifetime = 1.5
            spark.velocity = 100
            spark.velocityRange = 30
            spark.yAcceleration = 30
            spark.emissionLongitude = CGFloat.pi * 2
            spark.emissionRange = CGFloat.pi * 2
            spark.contents = UIImage(named: "spark")?.cgImage ?? createFallbackSparkImage(color: color)?.cgImage
            spark.color = color.cgColor
            spark.scale = 0.6
            spark.scaleSpeed = -0.3
            spark.alphaSpeed = -0.8
            explosionParticles.append(spark)
        }
        actualExplosionCellCopy.emitterCells = explosionParticles

        explosionLayer.emitterCells = [actualExplosionCellCopy]
        view.layer.addSublayer(explosionLayer)

        // 短暫延遲後移除這個臨時的爆炸發射器
        DispatchQueue.main.asyncAfter(deadline: .now() + singleExplosionCell.lifetime + (explosionParticles.first?.lifetime ?? 1.5) + 0.5) {
            explosionLayer.removeFromSuperlayer()
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 點擊屏幕時在點擊位置觸發一次爆炸
        if let touch = touches.first {
            let location = touch.location(in: view)
            triggerExplosion(at: location)
        }
    }
}

// 如何使用：
// 在你的 SceneDelegate.swift 或者 AppDelegate.swift 中 (取決於你的項目結構)
// 或者從另一個 ViewController 呈現：
// let fireworksVC = FireworksViewController()
// self.present(fireworksVC, animated: true, completion: nil)
// 或者作為子 ViewController：
// let fireworksVC = FireworksViewController()
// addChild(fireworksVC)
// view.addSubview(fireworksVC.view)
// fireworksVC.view.frame = view.bounds // 或者你想要的大小
// fireworksVC.didMove(toParent: self)

