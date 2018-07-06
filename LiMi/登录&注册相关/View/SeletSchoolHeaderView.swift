//
//  SeletSchoolHeaderView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/2.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class SeletSchoolHeaderView: UICollectionReusableView {
    var infoLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = APP_THEME_COLOR_1
        self.infoLabel = UILabel.init(frame: CGRect.init(x: 26, y: 0, width: 300, height: 30))
        self.infoLabel.textColor = UIColor.white
        self.infoLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        self.infoLabel.text = "选择你就读的大学"
        self.addSubview(self.infoLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
