//
//  PulishMenuViewItemView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/24.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class PulishMenuViewItemView: UIView {
    var leftInfoLabel:UILabel!
    var rightInfoLabel:UILabel!
    var rightArrowImageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
        self.leftInfoLabel = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: 100, height: frame.size.height))
        self.leftInfoLabel.textAlignment = .left
        self.leftInfoLabel.textColor = UIColor.white
        self.leftInfoLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        self.addSubview(self.leftInfoLabel)
        
        self.rightArrowImageView = UIImageView.init(frame: CGRect.init(x: frame.size.width-15-10, y: 0, width: 10, height: 17))
        self.rightArrowImageView.image = UIImage.init(named: "rightbtn")
        self.rightArrowImageView.center.y = frame.size.height * 0.5
        self.addSubview(self.rightArrowImageView)
        
        self.rightInfoLabel = UILabel.init(frame: CGRect.init(x: self.rightArrowImageView.frame.origin.x-15-100, y: 0, width: 100, height: frame.size.height))
        self.rightInfoLabel.textAlignment = .right
        self.rightInfoLabel.textColor = UIColor.white
        self.rightInfoLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        self.addSubview(self.rightInfoLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTarget(target:Any?,action:Selector){
        let tapG = UITapGestureRecognizer.init(target: target, action: action)
        self.addGestureRecognizer(tapG)
    }
}
