//
//  PurposeCollectionViewCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/21.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class PurposeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var targetName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configWith(name:String){
        self.targetName.text = name
    }
}
