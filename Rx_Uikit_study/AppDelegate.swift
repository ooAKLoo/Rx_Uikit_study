//
//  AppDelegate.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/4/21.
//

//import UIKit
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    var window: UIWindow?
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = CounterViewController()
//        window?.makeKeyAndVisible()
//        return true
//    }
//}


import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = ViewController() // 使用ViewController作为根视图控制器
        window?.rootViewController = Mini_ViewController() // 使用ViewController作为根视图控制器
//        window?.rootViewController = Mini_TransferViewController() // 使用ViewController作为根视图控制器
        window?.makeKeyAndVisible()
        return true
    }
}
