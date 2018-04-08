//
//  UserDetailChooseHiddenOrNotView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/6.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class UserDetailChooseHiddenOrNotView: UIView {
    var leftLabel:UILabel!
    var rightBtn:UIButton!
    var tapBtnBlock:((UIButton)->Void)?
    convenience init(isSpread:Bool) {
        self.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 0))
        self.rightBtn.isSelected = !isSpread

    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.leftLabel = UILabel.init()
        self.leftLabel.text = "个人资料"
        self.leftLabel.textColor = APP_THEME_COLOR
        self.leftLabel.font = UIFont.systemFont(ofSize: 17)
        self.addSubview(self.leftLabel)
        self.leftLabel.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(15)
            make.top.equalTo(self).offset(15)
        }
        
        self.rightBtn = UIButton()
        self.rightBtn.setImage(UIImage.init(named: "sx_btn_zhankai"), for: .normal)
        self.rightBtn.setImage(UIImage.init(named: "sx_btn_shouqi"), for: .selected)
        self.rightBtn.addTarget(self, action: #selector(dealTapBtn), for: .touchUpInside)
        self.addSubview(self.rightBtn)
        self.rightBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - mis
    @objc func dealTapBtn(){
        self.rightBtn.isSelected = !self.rightBtn.isSelected
        if let _tapBtnBlock = self.tapBtnBlock{
            _tapBtnBlock(self.rightBtn)
        }
    }
}
