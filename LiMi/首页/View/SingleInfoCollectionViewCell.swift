//
//  SingleInfoCollectionViewCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/7.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class SingleInfoCollectionViewCell: UICollectionViewCell {
    var infoLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
        
        self.infoLabel = UILabel()
        self.infoLabel.font = UIFont.systemFont(ofSize: 17)
        self.infoLabel.textColor = UIColor.white
        self.contentView.addSubview(self.infoLabel)
        self.infoLabel.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.contentView).offset(15)
            make.bottom.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
