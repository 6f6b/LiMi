//
//  SuspensionMenuAction.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/12.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SuspensionMenuAction: NSObject {
    ///文字内容
    var title:String?
    ///文字颜色
    var textColor:UIColor = UIColor.black
    ///文字大小
    var textFont:UIFont = UIFont.systemFont(ofSize: 17)
    ///动作
    var actionBlock:(()->Void)?

    init(title:String?,action:(()->Void)?) {
        super.init()
        self.title = title
        self.actionBlock = action
    }
}
