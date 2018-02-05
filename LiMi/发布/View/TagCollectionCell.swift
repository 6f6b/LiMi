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

    func configWith(skillModel:SkillModel?){
        self.tagTitle.text = skillModel?.skill
        if let _skillModel = skillModel{
            self.showWith(isSelectedStatus: _skillModel.isSelected)
        }
    }
    func showWith(isSelectedStatus:Bool){
        if isSelectedStatus{
            self.contentView.backgroundColor = APP_THEME_COLOR
            self.tagTitle.textColor = UIColor.white
        }
        if !isSelectedStatus{
            self.contentView.backgroundColor = RGBA(r: 240, g: 240, b: 240, a: 1)
            self.tagTitle.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
        }
    }
}
