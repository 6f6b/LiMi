//
//  WeekendTourDetailCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class WeekendTourDetailCell: UITableViewCell {
    @IBOutlet weak var tourDescription: UILabel!
    @IBOutlet weak var tourFlow: UILabel!
    @IBOutlet weak var costContain: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configWith(model:WeekendTourDetailModel?){
        self.tourDescription.text = model?.content
        self.tourFlow.text = model?.flow
        self.costContain.text = model?.cost
    }
}
