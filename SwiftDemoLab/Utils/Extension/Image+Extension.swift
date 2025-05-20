//
//  Image+Extension.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/5/20.
//

import UIKit

extension UIImage {
    static func image(withEmoji emoji: String, fontSize: CGFloat) -> UIImage? {
        // 1. 创建字体对象
        let font = UIFont.systemFont(ofSize: fontSize)
        let ctFont = CTFontCreateWithName(font.fontName as CFString, fontSize, nil)
        
        // 2. 创建属性字典
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): ctFont,
            NSAttributedString.Key(kCTForegroundColorFromContextAttributeName as String): true
        ]
        
        // 3. 创建 Core Text 文本行
        let attrStr = NSAttributedString(string: emoji, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attrStr as CFAttributedString)
        
        // 4. 获取 Emoji 的实际绘制区域
        let imageBounds = CTLineGetImageBounds(line, nil)
        if imageBounds.isEmpty {
            return nil
        }
        
        // 5. 计算上下文尺寸（包含缩放因子）
        let contextSize = CGSize(width: imageBounds.size.width, height: imageBounds.size.height)
        
        // 6. 创建透明背景的图像上下文
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // 7. 翻转坐标系
        context.translateBy(x: 0, y: contextSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // 8. 计算居中绘制位置
        let textPosition = CGPoint(x: -imageBounds.origin.x, y: -imageBounds.origin.y)
        
        // 9. 绘制文本
        context.textPosition = textPosition
        CTLineDraw(line, context)
        
        // 10. 获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // 11. 清理资源
        UIGraphicsEndImageContext()
        
        return image
    }
}
