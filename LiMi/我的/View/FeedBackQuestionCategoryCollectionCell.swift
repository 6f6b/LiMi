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
        self.categoryInfo.layer.borderColor = RGBA(r: 53, g: 53, b: 53, a: 1).cgColor
        self.categoryInfo.layer.borderWidth = 1
    }

    func configWith(model:FeedBackQuestionModel){
        self.categoryInfo.text = model.info
        let showColor = model.isSelect ? UIColor.white : RGBA(r: 53, g: 53, b: 53, a: 1)
        self.categoryInfo.textColor = model.isSelect ? UIColor.white : RGBA(r: 114, g: 114, b: 114, a: 1)
        self.categoryInfo.layer.borderColor = showColor.cgColor
    }
}
