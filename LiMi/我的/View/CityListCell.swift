//
//  CityListCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/3.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class CityListCell: UITableViewCell {
    @IBOutlet weak var city: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configWith(model:CityModel){
        self.city.text = model.name
    }
    
}
