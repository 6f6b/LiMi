//
//  WeekendTourSubjectCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class WeekendTourSubjectCell: UITableViewCell {
    @IBOutlet weak var backImageV: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var personNum: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        self.backImageV.layer.cornerRadius = 10
        self.backImageV.clipsToBounds = true
    }

    func configWith(model:WeekendTourModel?){
//        var feature:String?
//        var id:Int?
//        var name:String?
//        var num:Int?
//        var pic:String?
//        var price:String?
//        var time:String?
//        var to:String?
        if let _pic = model?.pic{
            self.backImageV.kf.setImage(with: URL.init(string: _pic), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        var nameText = ""
        if let _name = model?.name{
            nameText = _name
        }
        if let _feature = model?.feature{
            nameText = nameText + "|\(_feature)"
        }
        self.name.text = nameText
        if let _time = model?.time,let _address = model?.to{
            self.time.text = "\(_time)|\(_address)"
        }
        if let _num = model?.num{
            self.personNum.text = "参与人数：\(_num)"
        }
        
        if let _price = model?.price{
            self.priceLabel.text = "¥\(_price.decimalValue())"
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
