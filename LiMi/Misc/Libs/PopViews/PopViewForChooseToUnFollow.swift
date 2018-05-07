//
//  PopViewForChooseToUnFollow.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class PopViewForChooseToUnFollow: PopViewForUnAuthenticated {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.meaningLessImageView.image = UIImage.init(named: "tc_qxgz")
        self.infoLabel.text = "您真的要取消对我的关注吗？"
        self.notNowBtn.setTitle("还是算了", for: .normal)
        self.authenticateNowBtn.setTitle("坚决取消", for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
