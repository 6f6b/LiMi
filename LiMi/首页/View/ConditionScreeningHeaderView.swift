//
//  ConditionScreeningHeaderView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/25.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ConditionScreeningHeaderView: UICollectionReusableView {
    var headImgV: UIImageView!
    var info: UILabel!
    var spreadBtn:UIButton!
    var spreadBlock:((Bool)->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.headImgV = UIImageView()
        self.addSubview(self.headImgV)
        self.headImgV.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(25)
            make.left.equalTo(self)
            make.bottom.equalTo(self).offset(-10)
//            make.height.equalTo(15)
//            make.width.equalTo(15)
        }
        
        self.info = UILabel()
        info.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
        info.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(self.info)
        self.info.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.headImgV)
            make.left.equalTo(self.headImgV.snp.right).offset(5)
        }
        
        self.spreadBtn = SuitableHotSpaceButton()
//        self.spreadBtn.backgroundColor = UIColor.red
        self.spreadBtn.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 3, bottom: 0, right: -3)
        self.spreadBtn.setImage(UIImage.init(named: "sx_btn_shouqi"), for: .normal)
        self.spreadBtn.setImage(UIImage.init(named: "sx_btn_zhankai"), for: .selected)
        self.spreadBtn.addTarget(self, action: #selector(dealSpread(btn:)), for: .touchUpInside)
        self.addSubview(self.spreadBtn)
        self.spreadBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(44)
            make.right.equalTo(self).offset(10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - misc
    @objc func dealSpread(btn:UIButton){
        self.spreadBtn.isSelected = !spreadBtn.isSelected
        if let _spreadBlock = self.spreadBlock{
            _spreadBlock(self.spreadBtn.isSelected)
        }
    }
}
