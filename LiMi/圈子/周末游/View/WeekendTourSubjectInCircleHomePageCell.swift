//
//  WeekendTourSubjectInCircleHomePageCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class WeekendTourSubjectInCircleHomePageCell: UITableViewCell {
    @IBOutlet weak var backImgV: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.backImgV.layer.cornerRadius = 5
        self.backImgV.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configWith(model:WeekendTourModel?){
        if let _pic = model?.pic{
            self.backImgV.kf.setImage(with: URL.init(string: _pic), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.name.text = model?.name
        if let _price = model?.price{
            self.price.text = "¥ \(_price.decimalValue())"
        }
    }
}
