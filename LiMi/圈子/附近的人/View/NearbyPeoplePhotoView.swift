//
//  NearbyPeoplePhotoView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/21.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class NearbyPeoplePhotoView: UIView {
var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView = UIImageView.init(frame: self.bounds)
        self.imageView.layer.cornerRadius = 8
        self.imageView.clipsToBounds = true
        self.addSubview(self.imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configWith(model:FoolishUserInfoModel){
        if let _photo = model.photo{
            self.imageView.kf.setImage(with: URL.init(string: _photo))
        }
    }
}
