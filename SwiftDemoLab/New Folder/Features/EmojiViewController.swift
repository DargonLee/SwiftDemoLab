//
//  EmojiViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/5/29.
//

import UIKit
import CoreText
import SnapKit

class EmojiViewController: UIViewController {
    // UI 元素定义
    private let inputTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "请输入Emoji，如 U+1FAE1"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let showButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("显示", for: .normal)
        return btn
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 50)
        label.text = "😀"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.addSubview(inputTextField)
        view.addSubview(showButton)
        view.addSubview(emojiLabel)
        
        inputTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(40)
        }
        
        showButton.snp.makeConstraints { make in
            make.top.equalTo(inputTextField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        emojiLabel.snp.makeConstraints { make in
            make.top.equalTo(showButton.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupActions() {
        showButton.addTarget(self, action: #selector(showEmoji), for: .touchUpInside)
    }
    
    @objc private func showEmoji() {
        guard let input = inputTextField.text,
              input.hasPrefix("U+"),
              let emoji = parseEmoji(input) else {
            emojiLabel.text = "❓"
            return
        }
        emojiLabel.text = emoji
    }
    
    // 解析 "U+1F61D" 这样的格式为 UnicodeScalar
//    private func parseEmoji(_ text: String) -> String? {
//        let hexStr = text.uppercased().replacingOccurrences(of: "U+", with: "")
//        if let codePoint = UInt32(hexStr, radix: 16),
//           let scalar = UnicodeScalar(codePoint) {
//            return String(Character(scalar))
//        }
//        // 尝试用 Unicode 编码格式
//        if let codePoint = UInt32(hexStr, radix: 16) {
//            return String(format: "%C", codePoint)
//        }
//        return nil
//    }
    
    

    private func parseEmoji(_ text: String) -> String? {
        let hexStr = text.uppercased().replacingOccurrences(of: "U+", with: "")
        guard let codePoint = UInt32(hexStr, radix: 16),
              let scalar = UnicodeScalar(codePoint) else {
            return nil
        }
        let character = Character(scalar)
        return isEmojiSupported(character) ? String(character) : nil
    }

    private func isEmojiSupported(_ character: Character) -> Bool {
        let fontName = "AppleColorEmoji" as CFString
        let font = CTFontCreateWithName(fontName, 0, nil)
        
        var codePoints = [UniChar]()
        for scalar in character.unicodeScalars {
            codePoints.append(UniChar(scalar.value))
        }
        
        var glyphs = [CGGlyph](repeating: 0, count: codePoints.count)
        let result = CTFontGetGlyphsForCharacters(font, codePoints, &glyphs, codePoints.count)
        return result
    }
}


