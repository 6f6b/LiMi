//
//  WeekendTourBookingInfoCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import YYText

class WeekendTourBookingInfoCell: UITableViewCell {
    @IBOutlet var pointViews: [UIView]!
    @IBOutlet weak var labe1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        for pointView in  pointViews{
            pointView.layer.cornerRadius = 2.5
            pointView.clipsToBounds = true
        }
        let phoneText = "若订单出现任何问题，欢迎致电与我们联系：服务及退款热线（400-2019-2121）；"
        self.labe1.text = "提交订单后，商家将会在24小时内通过手机号与您联系，请保持电话通畅；"
        
        
        self.label3.text = "退订流程：拨打退款热线--工作人员核实退款情况--1~3个工作日内将退款打到您的支付账户"

        
        let attrPhoneText = NSMutableAttributedString.init(string: phoneText)
        attrPhoneText.yy_font = self.label2.font
        attrPhoneText.yy_color = self.label2.textColor
        attrPhoneText.yy_setTextHighlight(NSRange.init(location: 28, length: 13), color: UIColor.blue, backgroundColor: nil) { (view, str, range, rect) in
        }
        self.label2.attributedText = attrPhoneText
        self.label2.yb_addAttributeTapAction(with: ["400-2019-2121"], delegate: self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension WeekendTourBookingInfoCell:YBAttributeTapActionDelegate{
    func yb_attributeTapReturn(_ string: String!, range: NSRange, index: Int) {
            UIApplication.shared.openURL(URL(string: "tel:\(40020192121)")!)
    }
}
