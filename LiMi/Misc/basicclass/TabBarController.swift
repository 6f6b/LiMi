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
    ///未读系统消息数
    var systemUnreadCount:Int = 0
    ///未读会话消息
    var conversationUnreadCount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let homePageController = HomePageController()
        self.addControllerWith(controller: homePageController, title: "首页", tbImg: "icon_shouye", tbSelectedImg: "icon_shouye_highlight")
        let circleController = CircleController()
         self.addControllerWith(controller: circleController, title: "圈子", tbImg: "icon_quanzi", tbSelectedImg: "icon_quanzi_highlight")
        
        let blankController = ViewController()
        self.addControllerWith(controller: blankController, title: "", tbImg: "icon_fabu", tbSelectedImg: "icon_fabu")
        
        let msgController = MsgController()
         self.addControllerWith(controller: msgController, title: "消息", tbImg: "icon_xiaoxi", tbSelectedImg: "icon_xiaoxi_highlight")
        let personCenterController = GetViewControllerFrom(sbName: .personalCenter, sbID: "PersonCenterController")
        self.addControllerWith(controller: personCenterController, title: "我的", tbImg: "icon_wode", tbSelectedImg: "icon_wode_highlight")
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealPostATrendSuccess), name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
        
        //系统通知代理
        NIMSDK.shared().systemNotificationManager.add(self)
        //会话消息通知代理
        NIMSDK.shared().conversationManager.add(self)
        NotificationCenter.default.addObserver(self, selector: #selector(onCustomNotifyChanged(notification:)), name: NSNotification.Name(rawValue: ""), object: nil)
        self.refreshMyMessageBadge()
    }

    deinit{
        NotificationCenter.default.removeObserver(self, name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
//        NotificationCenter.default.removeObserver(<#T##observer: Any##Any#>, name: <#T##NSNotification.Name?#>, object: <#T##Any?#>)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    ///刷新Tabbar上的未读数
    func refreshMyMessageBadge(){
        let mscNav = self.viewControllers![3] as! NavigationController
        mscNav.tabBarItem.badgeValue = self.conversationUnreadCount == 0 ? nil : "\(self.conversationUnreadCount)"
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
    //控制是否跳转
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == self.viewControllers![2]{
            if let _ = Defaults[.userId],let _ = Defaults[.userToken]{
                let releaseController = ReleaseController()
                let releaseNav = NavigationController(rootViewController: releaseController)
                self.present(releaseNav, animated: true, completion: nil)
            }else{
                PostLogOutNotificationWith(msg: nil)
            }
            return false
        }
        if viewController == self.viewControllers![4]{
            if let _ = Defaults[.userId],let _ = Defaults[.userToken]{
                return true
            }else{
                PostLogOutNotificationWith(msg: nil)
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
        self.conversationUnreadCount = totalUnreadCount
        self.refreshMyMessageBadge()
    }

    ///最近会话修改回调
    func didUpdate(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        self.conversationUnreadCount = totalUnreadCount
        self.refreshMyMessageBadge()
    }
    
    ///删除最近会话的回调
    func didRemove(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        self.conversationUnreadCount = NIMSDK.shared().conversationManager.allUnreadCount()
        self.refreshMyMessageBadge()
    }
    
    ///单个会话里所有消息被删除的回调
    func messagesDeleted(in session: NIMSession) {
        self.conversationUnreadCount = NIMSDK.shared().conversationManager.allUnreadCount()
        self.refreshMyMessageBadge()
    }
    
    ///所有消息被删除的回调
    func allMessagesDeleted() {
        self.conversationUnreadCount = 0;
        self.refreshMyMessageBadge()
    }
    
    ///所有回话消息已读
    func allMessagesRead() {
        self.conversationUnreadCount = 0
        self.refreshMyMessageBadge()
    }
}

//MARK: - 系统通知代理方法
extension TabBarController:NIMSystemNotificationManagerDelegate{
    ///系统通知数量变化
    func onSystemNotificationCountChanged(_ unreadCount: Int) {
        self.systemUnreadCount = unreadCount
        self.refreshMyMessageBadge()
    }
}

//MARK: - Notification  通知
extension TabBarController{
    @objc func onCustomNotifyChanged(notification:Notification){
//        NTESCustomNotificationDB *db = [NTESCustomNotificationDB sharedInstance];
//        self.customSystemUnreadCount = db.unreadCount;
//        [self refreshSettingBadge];
    }
}





