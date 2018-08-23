//
//  PurposeItemCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/17.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class PurposeItemCell: UICollectionViewCell {
    @IBOutlet weak var purposeIcon: UIImageView!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var purposeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configWith(model:NearbyPurposeModel){
        if let _selected = model.selected{
            self.circleImage.isHidden = !_selected
            self.coverView.isHidden = _selected
            self.purposeName.textColor = _selected ? UIColor.white : RGBA(r: 114, g: 114, b: 114, a: 1)
        }
        if let image = model.image{
            self.purposeIcon.kf.setImage(with: URL.init(string: image))
        }
        self.purposeName.text = model.name

    }
}
