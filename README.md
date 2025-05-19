# SwiftDemoLab

SwiftDemoLab 是一个用于 iOS 开发的轻量级、独立 Demo 集合工程，主要用于在实际项目集成前，快速开发和验证 UI 组件或功能模块。

## 项目用途
- 快速开发和调试 UI 或功能 Demo，无需依赖真实项目的复杂逻辑。
- 便于将已验证的代码直接迁移到实际业务项目中。
- 适合团队协作和代码复用。

## 推荐项目结构
```
SwiftDemoLab/
  ├── App/                # 应用入口相关（AppDelegate、SceneDelegate、主入口 ViewController）
  ├── Features/           # 各功能模块 Demo（如登录、个人中心等）
  ├── Components/         # 可复用的 UI 组件
  ├── Utils/              # 工具类、扩展等
  ├── Resources/          # 资源文件（图片、Info.plist、Assets 等）
  ├── Storyboards/        # 各模块 Storyboard 文件（可选，当前在 Base.lproj 下）
  └── ...
```

## 现有结构说明
- `App/`：包含 AppDelegate.swift、SceneDelegate.swift、MainViewController.swift。
- `Resources/`：包含 Info.plist、Assets.xcassets 等资源。
- `Storyboards/Base.lproj/`：包含 Main.storyboard、LaunchScreen.storyboard。
- 其他文件夹可根据实际需求扩展。

## 开发建议
- 每个 Demo 或功能模块建议独立文件夹，便于管理和迁移。
- 通用组件、工具类建议放在 Components、Utils 目录下。
- Storyboard 文件可统一放在 Storyboards 目录，或按模块分文件夹。
- 主入口 ViewController 建议放在 App 目录。

---
如需更多结构建议或模板代码，可随时补充！
