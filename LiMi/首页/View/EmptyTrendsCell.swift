//
//  EmptyTrendsCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class EmptyTrendsCell: UITableViewCell {
    @IBOutlet weak var info: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configWith(info:String?){
        if let _info = info{
            self.info.text = _info
        }else{
            self.info.text = "太低调了，还没有发需求"
        }
    }
    
}
