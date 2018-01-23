//
//  TagCollectionCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TagCollectionCell: UICollectionViewCell {
    @IBOutlet weak var tagTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 13
        contentView.clipsToBounds = true
        contentView.layer.borderColor = APP_THEME_COLOR.cgColor
        contentView.layer.borderWidth = 1
    }

}
