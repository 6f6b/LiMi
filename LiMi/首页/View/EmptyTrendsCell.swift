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
    @IBOutlet weak var imgV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
//    enum TrendsCellStyle {
//        case normal //正常
//        case inPersonCenter   //用户主页中
//        case inMyTrendList   //我的动态列表中
//    }
    func configWith(info:String?,style:TrendsCellStyle = .normal){
        if let _info = info{
            self.info.text = _info
        }else{
            self.info.text = "太低调了，还没有发需求"
        }
        if style == .normal{
            self.imgV.image = UIImage.init(named: "qsy_img_nopl")
        }
        if style == .inPersonCenter{
            self.imgV.image = UIImage.init(named: "qsy_img_nodt")
        }
        if style == .inTopicCircleList{
            self.imgV.image = UIImage.init(named: "qsy_img_nodt")
            self.backgroundColor = UIColor.clear
//            self.contentView.backgroundColor = RGBA(r: 239, g: 239, b: 239, a: 1)
        }
    }
    
}
