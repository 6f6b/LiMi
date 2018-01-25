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
    
    var spreadBlock:(()->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.headImgV = UIImageView()
        self.addSubview(self.headImgV)
        self.headImgV.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(25)
            make.left.equalTo(self)
            make.bottom.equalTo(self).offset(-10)
            make.height.equalTo(15)
            make.width.equalTo(15)
        }
        
        self.info = UILabel()
        info.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
        info.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(self.info)
        self.info.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.headImgV)
            make.left.equalTo(self.headImgV.snp.right).offset(5)
        }
        
        self.spreadBtn = UIButton()
        self.spreadBtn.setImage(UIImage.init(named: "sx_btn_zhankai"), for: .normal)
        self.spreadBtn.addTarget(self, action: #selector(dealSpread), for: .touchUpInside)
        self.addSubview(self.spreadBtn)
        self.spreadBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - misc
    @objc func dealSpread(){
        if let _spreadBlock = self.spreadBlock{
            _spreadBlock()
        }
    }
}
