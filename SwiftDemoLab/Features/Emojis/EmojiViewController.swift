//
//  EmojiViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/5/29.
//

import UIKit
import CoreText
import SnapKit

// MARK: - Emoji 工具类
struct EmojiParser {
    static func parse(from text: String) -> String? {
        let hexStr = text.uppercased().replacingOccurrences(of: "U+", with: "")
        guard let codePoint = UInt32(hexStr, radix: 16),
              let scalar = UnicodeScalar(codePoint) else {
            return nil
        }
        let character = Character(scalar)
        return isEmojiSupported(character) ? String(character) : nil
    }
    
    private static func isEmojiSupported(_ character: Character) -> Bool {
        let fontName = "AppleColorEmoji" as CFString
        let font = CTFontCreateWithName(fontName, 0, nil)
        
        let codePoints = character.unicodeScalars.map { UniChar($0.value) }
        var glyphs = [CGGlyph](repeating: 0, count: codePoints.count)
        
        return CTFontGetGlyphsForCharacters(
            font, codePoints, &glyphs, codePoints.count
        )
    }
}

// MARK: - 状态枚举
private enum AlphaState {
    case opaque
    case transparent
    
    var title: String {
        switch self {
        case .opaque: return "透明度测试-【0】"
        case .transparent: return "透明度测试-【1】"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .opaque: return .systemRed
        case .transparent: return .systemGreen
        }
    }
    
    var labelAlpha: CGFloat {
        switch self {
        case .opaque: return 0.0
        case .transparent: return 1.0
        }
    }
    
    mutating func toggle() {
        self = (self == .opaque) ? .transparent : .opaque
    }
}

// MARK: - 主控制器
class EmojiViewController: UIViewController {
    
    // MARK: - UI 元素
    private let inputTextField = EmojiViewController.makeTextField(
        placeholder: "请输入Emoji，如 U+1FAE1"
    )
    
    private let showButton = EmojiViewController.makeButton(title: "显示")
    
    private let alphaButton = EmojiViewController.makeButton(title: "")
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 50)
        label.text = "😀测试👿"
        return label
    }()
    
    // MARK: - 状态
    private var alphaState: AlphaState = .opaque {
        didSet {
            updateAlphaButtonAppearance()
        }
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupActions()
        updateAlphaButtonAppearance()
    }
    
    // MARK: - UI 配置
    private func setupUI() {
        [inputTextField, showButton, alphaButton, emojiLabel]
            .forEach(view.addSubview)
        
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
        
        alphaButton.snp.makeConstraints { make in
            make.top.equalTo(emojiLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
    }
    
    private func setupActions() {
        showButton.addTarget(self, action: #selector(showEmoji), for: .touchUpInside)
        alphaButton.addTarget(self, action: #selector(toggleAlpha), for: .touchUpInside)
    }
    
    // MARK: - 动作
    @objc private func showEmoji() {
        guard let input = inputTextField.text,
              input.hasPrefix("U+"),
              let emoji = EmojiParser.parse(from: input) else {
            emojiLabel.text = "❓"
            return
        }
        emojiLabel.text = emoji
    }
    
    @objc private func toggleAlpha() {
        alphaState.toggle()
        
    }
    
    // MARK: - UI 更新
    private func updateAlphaButtonAppearance() {
        alphaButton.setTitle(alphaState.title, for: .normal)
        alphaButton.backgroundColor = alphaState.backgroundColor
        UIView.animate(withDuration: 0.25) {
            self.emojiLabel.alpha = self.alphaState.labelAlpha
        }
    }
}

// MARK: - UI 工厂方法
private extension EmojiViewController {
    static func makeTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        return tf
    }
    
    static func makeButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.layer.cornerRadius = 6
        btn.clipsToBounds = true
        return btn
    }
}



