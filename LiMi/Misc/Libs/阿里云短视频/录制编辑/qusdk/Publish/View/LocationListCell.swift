//
//  LocationListCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class LocationListCell: UITableViewCell {
    @IBOutlet weak var locationName: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func configWith(model:LocationModel){
        self.locationName.text = model.name
        self.distanceLabel.text = model.distance
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
