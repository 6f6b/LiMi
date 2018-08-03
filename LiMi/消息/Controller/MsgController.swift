//
//  MsgController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class MsgController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    var moreOperationBtn:UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let moreOperationBtn = UIButton.init(type: .custom)
        self.moreOperationBtn = moreOperationBtn
        moreOperationBtn.setImage(UIImage.init(named: "xx_ic_add"), for: .normal)
        moreOperationBtn.sizeToFit()
        moreOperationBtn.addTarget(self, action: #selector(dealMoreOperation), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: moreOperationBtn)
    
        let topMsgContainViewHeight = 176-NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT
        
        let topMsgContainView = TopMsgContainView()
        topMsgContainView.delegate = self
        topMsgContainView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: topMsgContainViewHeight)
        topMsgContainView.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
        self.view.addSubview(topMsgContainView)
        
        let sessionListController = NTESSessionListViewController()
        sessionListController.view.frame = CGRect.init(x: 0, y: topMsgContainView.frame.maxY+10, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-topMsgContainView.frame.maxY-49 - 10)
        sessionListController.automaticallyAdjustsScrollViewInsets = false
        sessionListController.tableView.frame = sessionListController.view.bounds
        sessionListController.tableView.contentInset = UIEdgeInsets.init(top: STATUS_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
        self.addChildViewController(sessionListController)
        self.view.addSubview(sessionListController.view)
        
        let leftLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 54, height: 27))
        leftLabel.text = "消息"
        leftLabel.textColor = UIColor.white
        leftLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftLabel)
    }

    deinit {
        print("消息列表销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = APP_THEME_COLOR_1
        //self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: RGBA(r: 43, g: 43, b: 43, a: 1)), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 30, g: 30, b: 30, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        
    }

    @objc func dealMoreOperation(){
        let actionToMyFollow = SuspensionMenuAction.init(title: "我的关注") {
            let followerListContainController = FollowerListContainController.init(initialIndex: 0)
            self.navigationController?.pushViewController(followerListContainController, animated: true)
        }
        actionToMyFollow.image = "nav_ic_wdgz"
        let actionAddFollow = SuspensionMenuAction.init(title: "添加关注") {
            let addFollowersController = AddFollowersController()
            let nav = CustomNavigationController.init(rootViewController: addFollowersController)
            self.present(nav, animated: true, completion: nil)
        }
        actionAddFollow.image = "nav_ic_tjgz"
        let actionIgnore = SuspensionMenuAction.init(title: "忽略未读") {
            NIMSDK.shared().conversationManager.markAllMessagesRead()
            NotificationCenter.default.post(name: ALL_UNREAD_COUNT_CHANGED_NOTIFICATION, object: nil)
        }
        actionIgnore.image = "nav_ic_hlwd"
        let actions = [actionToMyFollow,actionAddFollow,actionIgnore]
        let suspensionExpandMenu = SuspensionExpandMenu.init(actions: actions)
        suspensionExpandMenu.showAround(view: self.moreOperationBtn)
    }
}

extension MsgController : TopMsgContainViewDelegate{
    func topMsgContainView(containView: TopMsgContainView, clickedNewFansButton: UIButton) {
        let newFansMsgListController = NewFansMsgListController()
        self.navigationController?.pushViewController(newFansMsgListController, animated: true)
    }
    
    func topMsgContainView(containView: TopMsgContainView, clickedClickLikeButton: UIButton) {
        let newClickLikeMsgListController = NewClickLikeMsgListController()
        self.navigationController?.pushViewController(newClickLikeMsgListController, animated: true)
    }
    
    func topMsgContainView(containView: TopMsgContainView, clickedCommentButton: UIButton) {
        let newCommentMsgListController = NewCommentMsgListController()
        self.navigationController?.pushViewController(newCommentMsgListController, animated: true)
    }
    
    func topMsgContainView(containView: TopMsgContainView, clickedRemindButton: UIButton) {
        let newRemindMsgListController = NewRemindMsgListController()
        self.navigationController?.pushViewController(newRemindMsgListController, animated: true)
    }
}
