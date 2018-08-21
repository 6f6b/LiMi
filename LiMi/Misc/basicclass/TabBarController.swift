
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
        
        let homeContainViewController = HomeContainViewController()
        self.addControllerWith(controller: homeContainViewController, title: "首页", tbImg: "home_ic_sy", tbSelectedImg: "home_ic_sypre")
        
        let circleController = CircleController()
         self.addControllerWith(controller: circleController, title: "圈子", tbImg: "home_ic_qz", tbSelectedImg: "home_ic_qzpre")
        
        let blankController = UIViewController()
        self.addControllerWith(controller: blankController, title: "", tbImg: "home_ps", tbSelectedImg: "home_ps",imageInsets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
        
        let msgController = MsgController()
         self.addControllerWith(controller: msgController, title: "", tbImg: "home_ic_xx", tbSelectedImg: "home_ic_xxpre")

        let personCenterController = UserDetailsController()
        personCenterController.userInfoHeaderViewType = .inMyPersonCenter
        self.addControllerWith(controller: personCenterController, title: "", tbImg: "home_ic_me", tbSelectedImg: "home_ic_mepre")
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealPostATrendSuccess), name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(registerFinished), name: REGISTER_FINISHED_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMyMessageBadge), name: LOGIN_IM_SUCCESS_NOTIFICATION, object: nil)

        //系统通知代理
        NIMSDK.shared().systemNotificationManager.add(self)
        //会话消息通知代理
        NIMSDK.shared().conversationManager.add(self)
        NotificationCenter.default.addObserver(self, selector: #selector(customMessageUnreadCountChanged), name: customSystemMessageUnreadCountChanged, object: nil)
        
        self.tabBar.backgroundColor = UIColor.clear
        self.tabBar.barTintColor = UIColor.white
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()
        //self.tabBar.shadowImage = GetImgWith(size: CGSize.init(width: SCREEN_WIDTH, height: 1), color: RGBA(r: 228, g: 228, b: 228, a: 1))
    }

    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    
    ///刷新Tabbar上的未读数
    @objc func refreshMyMessageBadge(){
        //会话消息
        let totoalUnreadCount = AppManager.shared.conversationManager.allUnreadCount() + AppManager.shared.customSystemMessageManager.customSystemMessageUnreadCount(type: .all)
        if totoalUnreadCount == 0{
            self.tabBar.hiddenBageOnItemAt(index: 3)
        }else{
            self.tabBar.showBadgeOnItemAt(index: 3)
        }
        let mscNav = self.viewControllers![3] as! CustomNavigationController
        if #available(iOS 10.0, *) {
            mscNav.tabBarItem.setBadgeTextAttributes([NSAttributedStringKey.font.rawValue:UIFont.systemFont(ofSize: 160),NSAttributedStringKey.foregroundColor.rawValue:UIColor.red], for: .normal)
            mscNav.tabBarItem.badgeColor = RGBA(r: 255, g: 255, b: 255, a: 0)
        } else {
        }
        //mscNav.tabBarItem.badgeValue = totoalUnreadCount == 0 ? nil : "\(totoalUnreadCount)"
    }
    
    @objc func dealPostATrendSuccess(){
        self.selectedIndex = 0
    }
    
    func addControllerWith(controller:UIViewController!,title:String!,tbImg:String!,tbSelectedImg:String!,imageInsets:UIEdgeInsets = UIEdgeInsets.init(top: 5, left: 0, bottom: -5, right: 0)){
        controller.loadViewIfNeeded()
        controller.title = title
        let navController = CustomNavigationController.init(rootViewController: controller)
        navController.tabBarItem.image = UIImage.init(named: tbImg)?.withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.selectedImage = UIImage.init(named: tbSelectedImg)?.withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.title = nil
        navController.tabBarItem.imageInsets = imageInsets
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
        /*判断发布按钮*/
        if viewController == self.viewControllers![2]{
            if !AppManager.shared.checkUserStatus(){return false}

            print("\(NSDate.init())")
            let mediaContainController = MediaContainController()
            print("\(NSDate.init())")
            let mediaContainControllerNav = CustomNavigationController.init(rootViewController: mediaContainController)
            self.present(mediaContainControllerNav, animated: true, completion: nil)
            return false
        }
        
        /*其他*/
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
        /*颜色改变*/
        if viewController == self.viewControllers![0]{
            tabBarController.tabBar.backgroundColor = UIColor.clear
        }else{
            tabBarController.tabBar.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
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
    
    @objc func registerFinished(){
        self.dismiss(animated: true, completion: nil)
    }
    
}





