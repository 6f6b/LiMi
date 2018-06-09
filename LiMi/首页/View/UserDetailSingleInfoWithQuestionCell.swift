//
//  UserDetailSingleInfoWithQuestionCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/7.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class UserDetailSingleInfoWithQuestionCell: SingleInfoCollectionViewCell {
    var questionBtn:UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.questionBtn = UIButton()
        self.questionBtn.setImage(UIImage.init(named: "zsxm"), for: .normal)
        self.contentView.addSubview(self.questionBtn)
        self.questionBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.infoLabel)
            make.left.equalTo(self.infoLabel.snp.right).offset(10)
        }
        
        self.questionBtn.addTarget(self, action: #selector(dealTapQuestion), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    @objc func dealTapQuestion(){
        let popViewForTrueName = PopViewForTrueNameNotify.init(frame: SCREEN_RECT)
        popViewForTrueName.show()
    }
}
