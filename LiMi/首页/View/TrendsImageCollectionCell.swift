//
//  TrendsImageCollectionCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TrendsImageCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imgV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configWith(picUrl:String?){
        if let _picUrl = picUrl{
            let placeHolderImg = UIImage.init(named: "guanyu_icon")
            self.imgV.kf.setImage(with: URL.init(string: _picUrl), placeholder: placeHolderImg, options: nil, progressBlock: nil, completionHandler: nil)
//            self.imgV.kf.setImage(with: URL.init(string: _picUrl))
        }
    }
}
