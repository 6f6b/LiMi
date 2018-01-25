//
//  UserDetailHeadView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class UserDetailHeadView: UIView {
    @IBOutlet weak var headImgContainView: UIView!
    @IBOutlet weak var headImgV: UIImageView!
    @IBOutlet weak var userInfoContainView: UIView!
    
    override func awakeFromNib() {
        self.userInfoContainView.layer.cornerRadius = 15
//        self.userInfoContainView.clipsToBounds = true
    }
}
