//
//  PopViewForAuthenticateFaild.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/30.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class PopViewForAuthenticateFaild: PopViewForUnAuthenticated {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.meaningLessImageView.image = UIImage.init(named: "cxrz")
        self.infoLabel.text = "您提交的大学生信息没有通过审核，您还有1次机会重新提交"
        self.authenticateNowBtn.setTitle("重新认证", for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
