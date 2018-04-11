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
import  AVKit
import PushKit
import UserNotifications
import Toast
import Bugly

let NTESNotificationLogout = Notification.Name.init("NTESNotificationLogout")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var sdkConfigDelegate:NTESSDKConfigDelegate? = nil
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //腾讯统计
        Bugly.start(withAppId: "e0501ff656")
        //百度统计
        let statTracker = BaiduMobStat.default()
        statTracker?.shortAppVersion = APP_VERSION
        statTracker?.enableDebugOn = false
        statTracker?.start(withAppId: "3572f7dc26")
        
        self.window?.backgroundColor = UIColor.white
        UIApplication.shared.statusBarStyle = .lightContent
        SVProgressHUD.setMaximumDismissTimeInterval(3)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        let keyboardShareManager = IQKeyboardManager.sharedManager()
        keyboardShareManager.enable = true
        keyboardShareManager.shouldResignOnTouchOutside = true  //控制点击背景是否收起键盘
        keyboardShareManager.keyboardDistanceFromTextField = 50 //输入框距离键盘的距离
        
        NotificationCenter.default.addObserver(self, selector: #selector(logOut(notification:)), name: LOGOUT_NOTIFICATION, object: nil)
        WXApi.registerApp(WECHAT_APP_ID)

        self.commonInitListenEvents()
        self.setupNIMSDK()
        self.setupServices()
        self.registerPushService()
        self.setupMainViewController()
        NTESRedPacketManager.shared().application(application, didFinishLaunchingWithOptions: launchOptions)
        LocationManager.shared.startLocateWith(success: nil, failed: nil)
        
        
        return true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        NIMSDK.shared().loginManager.remove(self)
    }
    
    //MARK: - app state
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let conversationUnreadcount = AppManager.shared.conversationManager.allUnreadCount()
//        let systemUnreadCount = AppManager.shared.systemNotificationManager.allUnreadCount()
//        let customSystemUnreadCount = AppManager.shared.customSystemMessageManager.allCustomSystemMessageUnreadCount()
        UIApplication.shared.applicationIconBadgeNumber = conversationUnreadcount
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
        print("receive remote notification:\(userInfo)")
        if let nim = userInfo["nim"] as? String{
            if nim == "1"{
                if let tbController = UIApplication.shared.keyWindow?.rootViewController as? TabBarController{
                    tbController.selectedIndex = 3
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NIMSDK.shared().updateApnsToken(deviceToken)
        print("didRegisterForRemoteNotificationsWithDeviceToken：\(deviceToken)")
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("fail to get apns token:\(error)")
    }
    //MARK: - URL Open
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        //支付宝回调
        if url.host == "safepay"{
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (result) in
                NotificationCenter.default.post(name: FINISHED_ALIPAY_NOTIFICATION, object: nil, userInfo: result)
            })
        }
        //微信回调
        if url.host == "pay"{
            WXApi.handleOpen(url, delegate: PayManager.shared)
        }
        //云信红包回调
        if let _options = options as? [String:Any]{
            NTESRedPacketManager.shared().application(app, open: url, options: _options)
        }
        return true
    }
    
    //MARK: - logic impl
    func setupServices(){
        NTESLogManager.shared().start()
        NTESNotificationCenter.shared().start()
        //订阅关闭
        //NTESSubscribeManager.shared().start()
        NTESRedPacketManager.shared().start()
    }
    
    func setupNIMSDK(){
        //在注册 NIMSDK appKey 之前先进行配置信息的注册，如是否使用新路径,是否要忽略某些通知，是否需要多端同步未读数等
        self.sdkConfigDelegate = NTESSDKConfigDelegate.init()
        NIMSDKConfig.shared().delegate = self.sdkConfigDelegate
        NIMSDKConfig.shared().shouldSyncUnreadCount = true  //是否需要多端同步未读数
        NIMSDKConfig.shared().maxAutoLoginRetryTimes = 10   //自动登录重试数
        NIMSDKConfig.shared().maximumLogDays = NTESBundleSetting.sharedConfig().maximumLogDays() //本地log存活期
        NIMSDKConfig.shared().shouldCountTeamNotification = NTESBundleSetting.sharedConfig().countTeamNotification() //是否将群统计计入未读
        
        //appkey 是应用的标识，不同应用之间的数据（用户、消息、群组等）是完全隔离的。
        //并请对应更换 Demo 代码中的获取好友列表、个人信息等网易云信 SDK 未提供的接口。
        let appKey = NTESConfig.shared().appKey
        let option = NIMSDKOption(appKey: appKey!)
        option.apnsCername = NTESConfig.shared().apnsCername //云信apns推送证书名
        option.pkCername = NTESConfig.shared().pkCername//云信pushkit推送证书名
        NIMSDK.shared().register(with: option)
        
        //注册自定义消息的解析器
        NIMCustomObject.registerCustomDecoder(NTESCustomAttachmentDecoder.init())
        //注册 NIMKit 自定义排版配置
        NIMKit.shared().registerLayoutConfig(NTESCellLayoutConfig.init())
        
    }
}

//MARK: -  PKPushRegistryDelegate
extension AppDelegate:PKPushRegistryDelegate{
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        if type == PKPushType.voIP{
            NIMSDK.shared().updatePushKitToken(pushCredentials.token)
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        if let aps = payload.dictionaryPayload["aps"] as? [String:Any]{
            if let badge = aps["badge"] as? NSNumber{
                UIApplication.shared.applicationIconBadgeNumber = badge.intValue
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        
    }
}

//MARK: -  NIMLoginManagerDelegate
extension AppDelegate:NIMLoginManagerDelegate{
    func onKick(_ code: NIMKickReason, clientType: NIMLoginClientType) {
        var reason = "你被踢下线"
        switch code {
        case NIMKickReason.byClient:
            let clientName = NTESClientUtil.clientName(clientType)
            if let _clientName = clientName{
                if _clientName.count > 0{
                    reason = "你的账号在其他\(_clientName)端登录，请注意账号信息安全"
                }
            }
            break
        case NIMKickReason.byClientManually:
            let clientName = NTESClientUtil.clientName(clientType)
            if let _clientName = clientName{
                if _clientName.count > 0{
                    reason = "你的账号在其他\(_clientName)端登录，请注意账号信息安全"
                }
            }
        case NIMKickReason.byServer:
            reason = "你被服务器踢下线"
            break
        default:
            break
        }
        NIMSDK.shared().loginManager.logout { (error) in
            let alterController = UIAlertController.init(title: "下线通知", message: reason, preferredStyle: .alert)
            let acttionOK = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
                NotificationCenter.default.post(name: NTESNotificationLogout, object: nil, userInfo: nil)
            })
            alterController.addAction(acttionOK)
            UIApplication.shared.keyWindow?.rootViewController?.present(alterController, animated: true, completion: nil)
        }
        
        func onAutoLoginFailed(error:Error){
            //只有连接发生严重错误才会走这个回调，在这个回调里应该登出，返回界面等待用户手动重新登录。
            self.showAutoLoginErrorAlert(error: error)
        }
        
        func onLogin(step:NIMLoginStep){
            print("####################")
            print(step)
            print("*******************************")
        }
        
    }
    
    
}

//MARK: -  misc
extension AppDelegate{
    func showAutoLoginErrorAlert(error:Error){
        let message = NTESSessionUtil.formatAutoLoginMessage(error) ?? "自动登录失败"
        let alertController = UIAlertController.init(title: "自动登录失败", message: message, preferredStyle: .alert)
        let actionRetry = UIAlertAction.init(title: "重试", style: .default) { _ in
            AppManager.shared.loginIM()
        }
        let actionLogOut = UIAlertAction.init(title: "注销", style: .destructive) { _ in
            NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil)
        }
        alertController.addAction(actionLogOut)
        alertController.addAction(actionRetry)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    
    func setupMainViewController(){
        self.window?.rootViewController = TabBarController()
    }
    
    func commonInitListenEvents(){
        NotificationCenter.default.addObserver(self, selector: #selector(logOut(notification:)), name: NTESNotificationLogout, object: nil)
        NIMSDK.shared().loginManager.add(self)
    }
    
    func registerPushService(){
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [UNAuthorizationOptions.badge,UNAuthorizationOptions.sound,UNAuthorizationOptions.alert]) { (granted, error) in
                if granted{
                    let alertController = UIAlertController(title: "请开启推送功能否则无法收到推送通知", message: nil, preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "确定", style: .cancel, handler: nil)
                    alertController.addAction(actionOK)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                    //SVProgressHUD.showInfo(withStatus: "请开启推送功能否则无法收到推送通知")
                }
            }
        } else {
            let types = UInt8(UIUserNotificationType.badge.rawValue)|UInt8(UIUserNotificationType.sound.rawValue)|UInt8(UIUserNotificationType.alert.rawValue)
            let settings = UIUserNotificationSettings(types: UIUserNotificationType(rawValue: UIUserNotificationType.RawValue(types)), categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        //pushkit
        let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        pushRegistry.delegate = self    //PKPushRegistryDelegate
        pushRegistry.desiredPushTypes = NSSet(array: [PKPushType.voIP]) as? Set<PKPushType>
        
    }
    
    @objc func logOut(notification:Notification){
        AppManager.shared.resetAllLoginInfo()
        var msg:String?
        if let userInfo = notification.userInfo{
            if let _msg = userInfo[LOG_OUT_MESSAGE_KEY] as? String{
                msg = _msg
            }
        }
        if msg != nil{
            let alertVC = UIAlertController.init(title: msg, message: nil, preferredStyle: .alert)
            let actionOK = UIAlertAction.init(title: "确定", style: .default) {_ in
                let loginController = LoginController()
                let logNav = NavigationController(rootViewController: loginController)
                self.window?.rootViewController?.present(logNav, animated: true, completion: nil)
            }
            alertVC.addAction(actionOK)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
        }else{
            let loginController = LoginController()
            let logNav = NavigationController(rootViewController: loginController)
            self.window?.rootViewController?.present(logNav, animated: true, completion: nil)
        }
    }
}
