//
//  WeekendTourASimpleInfoInOrderCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class WeekendTourASimpleInfoInOrderCell: UITableViewCell {
    @IBOutlet weak var backImgV: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tourDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configWith(model:WeekendTourModel?){
        if let _pic = model?.pic{
            self.backImgV.kf.setImage(with: URL.init(string: _pic), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.name.text = model?.name
        self.tourDescription.text = model?.feature
    }
}
