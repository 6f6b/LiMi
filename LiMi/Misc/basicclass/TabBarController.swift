//
//  TabBarController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import NIMSDK

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let homePageController = HomePageController()
        self.addControllerWith(controller: homePageController, title: "首页", tbImg: "home_ic_sy", tbSelectedImg: "home_ic_sypre")
        let circleController = CircleController()
         self.addControllerWith(controller: circleController, title: "圈子", tbImg: "home_ic_qz", tbSelectedImg: "home_ic_qzpre")
        
        let blankController = ViewController()
        self.addControllerWith(controller: blankController, title: "", tbImg: "home_ic_fb", tbSelectedImg: "home_ic_fb")
        
        let msgController = MsgController()
         self.addControllerWith(controller: msgController, title: "消息", tbImg: "home_ic_im", tbSelectedImg: "home_ic_impre")
        let personCenterController = GetViewControllerFrom(sbName: .personalCenter, sbID: "PersonCenterController")
        self.addControllerWith(controller: personCenterController, title: "我的", tbImg: "home_ic_me", tbSelectedImg: "home_ic_mepre")
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealPostATrendSuccess), name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
        
        //系统通知代理
        NIMSDK.shared().systemNotificationManager.add(self)
        //会话消息通知代理
        NIMSDK.shared().conversationManager.add(self)
        NotificationCenter.default.addObserver(self, selector: #selector(customMessageUnreadCountChanged), name: customSystemMessageUnreadCountChanged, object: nil)
        self.refreshMyMessageBadge()
        
        self.tabBar.backgroundColor = UIColor.white
        self.tabBar.barTintColor = UIColor.white
        self.tabBar.shadowImage = GetImgWith(size: CGSize.init(width: SCREEN_WIDTH, height: 1), color: RGBA(r: 228, g: 228, b: 228, a: 1))
        self.tabBar.backgroundImage = UIImage()
    }

    deinit{
        NotificationCenter.default.removeObserver(self, name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: customSystemMessageUnreadCountChanged, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    
    ///刷新Tabbar上的未读数
    func refreshMyMessageBadge(){
        //自定义系统消息
        if AppManager.shared.customSystemMessageManager.allCustomSystemMessageUnreadCount() == 0{
            self.tabBar.hiddenBageOnItemAt(index: 0)
        }else{
            self.tabBar.showBadgeOnItemAt(index: 0)
        }
//        let homeNav = self.viewControllers![0] as! NavigationController
//        if #available(iOS 10.0, *) {
//            homeNav.tabBarItem.setBadgeTextAttributes([NSAttributedStringKey.font.rawValue:UIFont.systemFont(ofSize: 80),NSAttributedStringKey.foregroundColor.rawValue:UIColor.red,NSAttributedStringKey.backgroundColor.rawValue:UIColor.red], for: .normal)
//        } else {
//        }
//        homeNav.tabBarItem.badgeValue = AppManager.shared.systemUnreadCount == 0 ? nil : " "

        //会话消息
        if AppManager.shared.conversationManager.allUnreadCount() == 0{
            self.tabBar.hiddenBageOnItemAt(index: 3)
        }else{
            self.tabBar.showBadgeOnItemAt(index: 3)
        }
//        let mscNav = self.viewControllers![3] as! NavigationController
//        if #available(iOS 10.0, *) {
//            mscNav.tabBarItem.setBadgeTextAttributes([NSAttributedStringKey.font.rawValue:UIFont.systemFont(ofSize: 160),NSAttributedStringKey.foregroundColor.rawValue:UIColor.red], for: .normal)
//            mscNav.tabBarItem.badgeColor = RGBA(r: 255, g: 255, b: 255, a: 0)
//        } else {
//        }
//        mscNav.tabBarItem.badgeValue = AppManager.shared.conversationUnreadCount == 0 ? nil : "."
        //mscNav.tabBarItem.badgeValue = self.conversationUnreadCount == 0 ? nil : "\(self.conversationUnreadCount)"
    }
    
    @objc func dealPostATrendSuccess(){
        self.selectedIndex = 0
    }
    
    func addControllerWith(controller:UIViewController!,title:String!,tbImg:String!,tbSelectedImg:String!){
        controller.title = title
        let navController = NavigationController(rootViewController: controller)
        navController.tabBarItem.image = UIImage.init(named: tbImg)?.withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.selectedImage = UIImage.init(named: tbSelectedImg)?.withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.title = nil
        navController.tabBarItem.imageInsets = UIEdgeInsets.init(top: 5, left: 0, bottom: -5, right: 0)
        self.addChildViewController(navController)
    }
    
}

extension TabBarController:UITabBarControllerDelegate{
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let items = tabBar.items{
            for i in 0..<items.count{
                if item == items[i]{
                    NotificationCenter.default.post(name: TAPED_TABBAR_NOTIFICATION, object: nil, userInfo: [TABBAR_INDEX_KEY:i])
                    return
                }
            }
        }
    }
    //控制是否跳转
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == self.viewControllers![2]{
            if !AppManager.shared.checkUserStatus(){return false}

            let releaseController = ReleaseController()
            let releaseNav = NavigationController(rootViewController: releaseController)
            self.present(releaseNav, animated: true, completion: nil)
            return false
        }
        if viewController == self.viewControllers![3]{
            if !AppManager.shared.checkUserStatus(){
                return false
            }
        }
        if viewController == self.viewControllers![4]{
            //登录则可以进入
            if Defaults[.userId] == nil{
                NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil)
                return false
            }
        }
        return true
    }
}

//MARK: - NIMConversationManagerDelegate    会话代理方法
extension TabBarController:NIMConversationManagerDelegate{
    ///增加最近会话的回调
    func didAdd(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        //AppManager.shared.conversationUnreadCount = totalUnreadCount
        self.refreshMyMessageBadge()
    }

    ///最近会话修改回调
    func didUpdate(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        //AppManager.shared.conversationUnreadCount = totalUnreadCount
        self.refreshMyMessageBadge()
    }
    
    ///删除最近会话的回调
    func didRemove(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        //AppManager.shared.conversationUnreadCount = NIMSDK.shared().conversationManager.allUnreadCount()
        self.refreshMyMessageBadge()
    }
    
    ///单个会话里所有消息被删除的回调
    func messagesDeleted(in session: NIMSession) {
        //AppManager.shared.conversationUnreadCount = NIMSDK.shared().conversationManager.allUnreadCount()
        self.refreshMyMessageBadge()
    }
    
    ///所有消息被删除的回调
    func allMessagesDeleted() {
        //AppManager.shared.conversationUnreadCount = 0;
        self.refreshMyMessageBadge()
    }
    
    ///所有回话消息已读
    func allMessagesRead() {
        //AppManager.shared.conversationUnreadCount = 0
        self.refreshMyMessageBadge()
    }
}

//MARK: - 系统通知代理方法
extension TabBarController:NIMSystemNotificationManagerDelegate{
    ///系统通知数量变化
    func onSystemNotificationCountChanged(_ unreadCount: Int) {
        //AppManager.shared.systemUnreadCount = unreadCount
        self.refreshMyMessageBadge()
    }
    
    ///收到自定义系统消息
    func onReceive(_ notification: NIMCustomSystemNotification) {
        AppManager.shared.customSystemMessageManager.addCustomSystemMessageWith(nimCustomSystemNotification: notification)
    }
    
    
}

//MARK: - Notification  通知
extension TabBarController{
    //自定义系统消息未读数改变
    @objc func  customMessageUnreadCountChanged(){
        self.refreshMyMessageBadge()
    }
}





