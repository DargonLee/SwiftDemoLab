//
//  AppDelegate.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/5/19.
//

import UIKit
import SwiftyBeaver
let SwiftyLog = SwiftyBeaver.self

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if DEBUG
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        //for tvOS:
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/tvOSInjection.bundle")?.load()
        //Or for macOS:
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
#endif
        debugPrint(NSHomeDirectory())
        // 日志配置
        setupLog()
        
        // 检查是否由健康数据更新唤醒
        setupHealthObserve(launchOptions: launchOptions)
        
        return true
    }
    
    func setupLog() {
        // 设置 SwiftyBeaver 日志
        let console = ConsoleDestination()  // log to Xcode Console
        let file = FileDestination() // log to default swiftybeaver.log file
        console.format = "$DHH:mm:ss$d $L $M"
        console.useTerminalColors = true
        SwiftyLog.addDestination(console)
        SwiftyLog.addDestination(file)
    }
    
    func setupHealthObserve(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let options = launchOptions,
           options[.location] == nil, // 排除位置更新唤醒
           options[.bluetoothCentrals] == nil {
            // 可能是健康数据更新触发
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

