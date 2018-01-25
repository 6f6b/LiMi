//
//  AppDelegate.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/8.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import  IQKeyboardManagerSwift
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window?.backgroundColor = APP_THEME_COLOR
        UIApplication.shared.statusBarStyle = .lightContent
        SVProgressHUD.setMaximumDismissTimeInterval(3)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        
        let keyboardShareManager = IQKeyboardManager.sharedManager()
        keyboardShareManager.enable = true
        keyboardShareManager.shouldResignOnTouchOutside = true  //控制点击背景是否收起键盘
        keyboardShareManager.keyboardDistanceFromTextField = 50 //输入框距离键盘的距离
        
        self.window?.rootViewController = TabBarController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(logOut), name: Notification.Name.init("logout"), object: nil)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    //MARK: - Notification
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    //MARK - Open Url
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return false
    }
    
    //MARK: - misc
    @objc func logOut(){
        Defaults[.userId] = nil //置空本地userid
        Defaults[.userToken] = nil  //指控本地usertoken
        let loginController = LoginController()
        let logNav = NavigationController(rootViewController: loginController)
        self.window?.rootViewController?.present(logNav, animated: true, completion: nil)
    }
}

