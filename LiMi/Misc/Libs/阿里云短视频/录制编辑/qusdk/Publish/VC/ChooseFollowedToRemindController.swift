//
//  ChooseFollowedToRemindController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/24.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol ChooseFollowedToRemindControllerDelegate {
    func chooseFollowedToRemindController(controller:ChooseFollowedToRemindController, selectedUser model:UserInfoModel)
}
class ChooseFollowedToRemindController: PulishNextController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "@好友"
        self.searchTextField.placeholder = "输入要@的好友昵称"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
