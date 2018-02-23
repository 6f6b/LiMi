//
//  FeedBackHeaderView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SnapKit

class FeedBackHeaderView: UIView {
    var infoLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.groupTableViewBackground
        
        self.infoLabel = UILabel()
        self.infoLabel.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.infoLabel.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(self.infoLabel)
        self.infoLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
