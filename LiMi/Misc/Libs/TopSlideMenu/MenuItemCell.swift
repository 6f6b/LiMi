//
//  MenuItemCell.swift
//  TopSlideMenuDemo
//
//  Created by dev.liufeng on 2018/7/4.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class MenuItemCell: UICollectionViewCell {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var selectBottomLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configWith(title:String?,isSelected:Bool){
        self.infoLabel.text = title
        if isSelected{
            self.infoLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            self.infoLabel.textColor = UIColor.white
        }else{
            self.infoLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            self.infoLabel.textColor = RGBA(r: 114, g: 114, b: 114, a: 1)
        }
        self.selectImageView.isHidden = !isSelected
        self.selectBottomLine.isHidden = !isSelected
    }

}
