//
//  PopViewForUnAuthenticated.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/30.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class PopViewForUnAuthenticated: PopView {
    internal var meaningLessImageView:UIImageView!
    internal var infoLabel:UILabel!
    internal var notNowBtn:UIButton!
    internal var authenticateNowBtn:UIButton!
    
    var tapLeftBlock:(()->Void)?
    var tapRightBlock:(()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.meaningLessImageView = UIImageView()
        self.meaningLessImageView.image = UIImage.init(named: "ksrz")
        self.centerContianView.addSubview(self.meaningLessImageView)
        self.meaningLessImageView.snp.makeConstraints {[unowned self] (make) in
            make.centerX.equalTo(self.centerContianView)
            make.top.equalTo(self.centerContianView).offset(15)
        }
        
        self.infoLabel = UILabel()
        self.infoLabel.text = "您还没有认证在校大学生身份，认证后即可解锁更多功能"
        self.infoLabel.font = UIFont.systemFont(ofSize: 15)
        self.infoLabel.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
        self.infoLabel.textAlignment = .center
        self.infoLabel.numberOfLines = 0
        self.infoLabel.lineBreakMode = .byWordWrapping
        self.centerContianView.addSubview(self.infoLabel)
        self.infoLabel.snp.makeConstraints {[unowned self] (make) in
            make.centerX.equalTo(self.centerContianView)
            make.left.equalTo(self.centerContianView).offset(40)
            make.top.equalTo(self.meaningLessImageView.snp.bottom).offset(15)
        }
        
        self.notNowBtn = UIButton()
        self.notNowBtn.addTarget(self, action: #selector(dealNotAuthenticateNow), for: .touchUpInside)
        self.notNowBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.notNowBtn.setTitleColor(RGBA(r: 153, g: 153, b: 153, a: 1), for: .normal)
        self.notNowBtn.backgroundColor = RGBA(r: 244, g: 244, b: 244, a: 1)
        self.notNowBtn.layer.cornerRadius = 20
        self.notNowBtn.clipsToBounds = true
        self.notNowBtn.setTitle("先去逛逛", for: .normal)
        self.centerContianView.addSubview(self.notNowBtn)
        self.notNowBtn.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.infoLabel.snp.bottom).offset(15)
            make.left.equalTo(self.centerContianView).offset(18)
            make.bottom.equalTo(self.centerContianView).offset(-15)
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
        
        self.authenticateNowBtn = UIButton()
        self.authenticateNowBtn.addTarget(self, action: #selector(dealAuthenticateNow), for: .touchUpInside)
        self.authenticateNowBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.authenticateNowBtn.titleLabel?.textColor = UIColor.white
        self.authenticateNowBtn.backgroundColor = APP_THEME_COLOR
        self.authenticateNowBtn.layer.cornerRadius = 20
        self.authenticateNowBtn.clipsToBounds = true
        self.authenticateNowBtn.setTitle("快速认证", for: .normal)
        self.centerContianView.addSubview(self.authenticateNowBtn)
        self.authenticateNowBtn.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.notNowBtn)
            make.right.equalTo(self.centerContianView).offset(-18)
            make.bottom.equalTo(self.notNowBtn)
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - misc
    @objc func dealNotAuthenticateNow(){
        if let _tapLeftBlock = self.tapLeftBlock{
            _tapLeftBlock()
        }
        self.dismiss()
    }
    
    @objc func dealAuthenticateNow(){
        if let _tapRightBlock = self.tapRightBlock{
            _tapRightBlock()
        }
        self.dismiss()
    }
}
