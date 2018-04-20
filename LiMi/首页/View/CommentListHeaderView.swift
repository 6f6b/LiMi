//
//  CommentListHeaderView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class CommentListHeaderView: UIView {
    var infoLabel:UILabel!
     override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = RGBA(r: 245, g: 245, b: 245, a: 1)
        
        self.infoLabel = UILabel()
        self.infoLabel.font = UIFont.systemFont(ofSize: 14)
        self.infoLabel.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.infoLabel.text = "评论"
        self.addSubview(self.infoLabel)
        self.infoLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.top.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-15)
            make.left.equalTo(self).offset(12)
        }
        
        let separateLine = UIView()
        separateLine.backgroundColor = RGBA(r: 228, g: 228, b: 228, a: 1)
        self.addSubview(separateLine)
        separateLine.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
