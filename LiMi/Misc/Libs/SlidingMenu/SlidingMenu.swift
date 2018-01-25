//
//  SlidingMenu.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SlidingMenu: NSObject {
    var menuBar:UIView!
    var menuContainView:UIScrollView!
    
    override init() {
        super.init()
    }
    
    convenience init(titles:[String],subViews:[UIView]) {
        self.init()
//        self.menuBar = UIScrollView
    }
}
