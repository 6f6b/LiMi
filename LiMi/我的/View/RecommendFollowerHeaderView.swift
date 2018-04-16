//
//  RecommendFollowerHeaderView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/13.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class RecommendFollowerHeaderView: UIView {

    var leftLabel:UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        self.leftLabel = UILabel.init()
        self.leftLabel.text = "推荐"
        self.leftLabel.textColor = APP_THEME_COLOR
        self.leftLabel.font = UIFont.systemFont(ofSize: 17)
        self.addSubview(self.leftLabel)
        self.leftLabel.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-15)
            make.left.equalTo(self).offset(15)
        }
        
        let bottomeLine = UIView()
        bottomeLine.backgroundColor = RGBA(r: 228, g: 228, b: 228, a: 1)
        self.addSubview(bottomeLine)
        bottomeLine.snp.makeConstraints {[unowned self] (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - mis

}
