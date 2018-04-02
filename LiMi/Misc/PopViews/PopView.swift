//
//  PopView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/30.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class PopView: View {
    ///中央容器视图
    var centerContianView:UIView!

    convenience init() {
        self.init(frame: SCREEN_RECT)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = RGBA(r: 51, g: 51, b: 51, a: 0.5)
        
        self.centerContianView = UIView()
        self.centerContianView.backgroundColor = UIColor.white
        self.centerContianView.layer.cornerRadius = 10
        self.centerContianView.clipsToBounds = true
        self.addSubview(self.centerContianView)
        self.centerContianView.snp.makeConstraints {[unowned self] (make) in
            make.center.equalTo(self)
            make.width.equalTo(295)
            make.height.greaterThanOrEqualTo(265)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:  - misc
    func dismiss(){
        self.removeFromSuperview()
    }
    
    func show(){
        UIApplication.shared.keyWindow?.addSubview(self)
    }

}
