//
//  WeekendTourUnitPriceCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class WeekendTourUnitPriceCell: UITableViewCell {
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configWith(model:WeekendTourModel?){
        if let _price = model?.price{
            self.price.text = "¥\(_price.decimalValue())"
        }
    }
}
