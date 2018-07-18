//
//  NoMoreDataFooterView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class NoMoreDataFooterView: UIView {
    private var infoLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.infoLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 50))
        self.infoLabel.textColor = APP_THEME_COLOR_1
        self.infoLabel.font = UIFont.systemFont(ofSize: 15)
        self.infoLabel.text = "无更多数据"
        self.addSubview(self.infoLabel)
        self.infoLabel.sizeToFit()
        self.infoLabel.center = self.center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
