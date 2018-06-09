//
//  CutomWithNavigationBarAndStatusBarView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class CutomWithNavigationBarAndStatusBarView: UIView {
    //var statusBarView:CustomStatusBarView!
    var navigationBarView:CustomNavigationBarView!

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT))
        //self.navigationBarView = CustomNavigationBarView.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
