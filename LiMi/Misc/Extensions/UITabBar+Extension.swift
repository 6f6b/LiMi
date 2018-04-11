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
        var badgeX = CGFloat(0)
        if index == 0{
            badgeX = 1/15.0*SCREEN_WIDTH
        }
        if index == 1{
            badgeX = 4/15.0*SCREEN_WIDTH
        }
        if index == 2{
            badgeX = 7/15.0*SCREEN_WIDTH
        }
        if index == 3{
            badgeX = 10/15.0*SCREEN_WIDTH
        }
        if index == 4{
            badgeX = 13/15.0*SCREEN_WIDTH
        }
        badgeX = badgeX + SCREEN_WIDTH/15.0 - 1
        let badgeY = 12.0
        let badgeWidth = 8.0
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
