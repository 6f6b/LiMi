//
//  SchoolCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/2.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class SchoolCell: UICollectionViewCell {
    var collegeModel:CollegeModel?
    @IBOutlet weak var shoolInfoLabel: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var infoRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowRightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configWith(model:CollegeModel?,isLast:Bool,isSelected:Bool){
        self.arrow.isHidden = !isLast
        self.infoRightConstraint.constant = isLast ? 45 : 25
        self.contentView.backgroundColor = isSelected ? APP_THEME_COLOR_2 : RGBA(r: 255, g: 255, b: 255, a: 0.1)
        self.collegeModel = model
        if let name = model?.name{
            self.shoolInfoLabel.text = name
        }else{
            self.shoolInfoLabel.text = "没有你的学校？快去搜索吧"
        }
    }
}
