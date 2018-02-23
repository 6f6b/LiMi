//
//  MsgController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class MsgController: ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ignoreBtn = UIButton.init(type: .custom)
        let ignoreBtnAttributeTitle = NSAttributedString.init(string: "忽略未读", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        ignoreBtn.setAttributedTitle(ignoreBtnAttributeTitle, for: .normal)
        ignoreBtn.sizeToFit()
        ignoreBtn.addTarget(self, action: #selector(dealIgnore), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: ignoreBtn)
        
        let sessionListController = NTESSessionListViewController()
        sessionListController.view.frame = self.view.frame
        self.addChildViewController(sessionListController)
        self.view.addSubview(sessionListController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func dealIgnore(){
        NIMSDK.shared().conversationManager.markAllMessagesRead()
        NotificationCenter.default.post(name: ALL_UNREAD_COUNT_CHANGED_NOTIFICATION, object: nil)
    }
}
