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
            self.imgV.kf.setImage(with: URL.init(string: _picUrl))
        }
    }
}
