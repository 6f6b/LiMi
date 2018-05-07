//
//  PopViewForTrueNameNotify.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class PopViewForTrueNameNotify: PopViewForUnAuthenticated {
    var okBtn:UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.meaningLessImageView.image = UIImage.init(named: "tc_zsxm")
        self.infoLabel.text = "互相关注的好友才能查看对方的真实姓名"
        self.authenticateNowBtn.setTitle("重新认证", for: .normal)
        self.notNowBtn.snp.removeConstraints()
        self.authenticateNowBtn.snp.removeConstraints()
        self.notNowBtn.isHidden = true
        self.authenticateNowBtn.isHidden = true
        
        self.okBtn = UIButton.init()
        self.okBtn.setTitle("好的", for: .normal)
        self.okBtn.setTitleColor(UIColor.white, for: .normal)
        self.okBtn.backgroundColor = APP_THEME_COLOR
        self.okBtn.layer.cornerRadius = 20
        self.okBtn.clipsToBounds = true
        self.okBtn.addTarget(self, action: #selector(dealOK), for: .touchUpInside)
        self.centerContianView.addSubview(self.okBtn)
        self.okBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerX.equalTo(self.centerContianView)
            make.height.equalTo(40)
            make.width.equalTo(260)
            make.top.greaterThanOrEqualTo(self.infoLabel.snp.bottom).offset(15)
            make.bottom.equalTo(self.centerContianView).offset(-15)
        }
        
        
    }
    
    @objc func dealOK(){
        self.dismiss()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
