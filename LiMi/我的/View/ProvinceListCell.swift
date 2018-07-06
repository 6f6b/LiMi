//
//  ProvinceListCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/3.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class ProvinceListCell: UITableViewCell {
    @IBOutlet weak var provinceName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configWith(model:ProvinceModel){
        self.provinceName.text = model.name
    }
}
