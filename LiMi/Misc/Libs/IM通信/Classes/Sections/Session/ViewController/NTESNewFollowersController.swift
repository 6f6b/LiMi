//
//  NTESNewFollowersController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/28.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class NTESNewFollowersController: FollowerListController {
    @objc var session:NIMSession!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关注通知"
        self.view.backgroundColor = UIColor.white
        NIMSDK.shared().conversationManager.markAllMessagesRead(in: self.session)
    }

    override init(followType: FollowType) {
        super.init(followType: followType)
    }

    @objc convenience init() {
        self.init(followType: .recentFollowers)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
