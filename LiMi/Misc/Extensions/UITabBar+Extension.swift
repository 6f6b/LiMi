//
//  UITabBar+Extension.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/7.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation

extension UITabBar{
    func showBadgeOnItemAt(index:Int){
        let tapFrame = self.frame
        let badgeX = CGFloat(index+1)/CGFloat(5) + CGFloat(10)
        let badgeY = 10.0
        let badgeWidth = 3.0
        let badgeHeight = badgeWidth
        let bageFrame = CGRect.init(x: Double(badgeX), y: badgeY, width: badgeWidth, height: badgeHeight)
        let badgeView = UIView.init(frame: bageFrame)
        badgeView.backgroundColor = UIColor.red
        badgeView.layer.cornerRadius = CGFloat(badgeWidth*0.5)
        badgeView.clipsToBounds = true
        badgeView.tag = 888 + index
        self.addSubview(badgeView)
        
    }
    
    func hiddenBageOnItemAt(index:Int){
        self.removeBageOnItemAt(index: index)
    }
    
    func removeBageOnItemAt(index:Int){
        for v in self.subviews{
            if v.tag ==  888 + index{
                v.removeFromSuperview()
            }
        }
    }
}
