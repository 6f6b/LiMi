//
//  UserDetailSingleInfoWithQuestionCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/7.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class UserDetailSingleInfoWithQuestionCell: UserDetailSingleInfoCell {
    var questionBtn:UIButton!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func dealTapQuestion(){
        let popViewForTrueName = PopViewForTrueNameNotify.init(frame: SCREEN_RECT)
        popViewForTrueName.show()
    }
}
