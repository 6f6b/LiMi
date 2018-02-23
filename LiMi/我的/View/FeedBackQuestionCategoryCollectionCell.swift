//
//  FeedBackQuestionCategoryCollectionCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class FeedBackQuestionCategoryCollectionCell: UICollectionViewCell {
    @IBOutlet weak var categoryInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.categoryInfo.layer.cornerRadius = 5
        self.categoryInfo.layer.borderColor = APP_THEME_COLOR.cgColor
        self.categoryInfo.layer.borderWidth = 1
    }

    func configWith(model:FeedBackQuestionModel){
        self.categoryInfo.text = model.info
        let showColor = model.isSelect ? APP_THEME_COLOR : RGBA(r: 204, g: 204, b: 204, a: 1)
        self.categoryInfo.textColor = showColor
        self.categoryInfo.layer.borderColor = showColor.cgColor
    }
}
