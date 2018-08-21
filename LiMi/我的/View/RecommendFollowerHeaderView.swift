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
        
        self.backgroundColor = APP_THEME_COLOR_1
        
        self.leftLabel = UILabel.init()
        self.leftLabel.text = "推荐"
        self.leftLabel.textColor = UIColor.white
        self.leftLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        self.addSubview(self.leftLabel)
        self.leftLabel.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-15)
            make.left.equalTo(self).offset(15)
        }
        
        let bottomeLine = UIView()
        bottomeLine.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
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
