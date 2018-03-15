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
        
        self.labe1.text = "提交订单后，商家将会在24小时内通过手机号与您联系，请保持电话通畅；"
        self.label3.text = "退订流程：拨打退款热线--工作人员核实退款情况--1~3个工作日内将退款打到您的支付账户"

        let phoneText = "若订单出现任何问题，欢迎致电与我们联系：服务及退款热线（\(PHONE_NUMBER)）；"
        let nsPhoneText = NSString.init(string: phoneText)
        let phoneNumRange = nsPhoneText.range(of: PHONE_NUMBER)
        let attrPhoneText = NSMutableAttributedString.init(string: phoneText)
        attrPhoneText.yy_font = self.label2.font
        attrPhoneText.yy_color = self.label2.textColor
        attrPhoneText.yy_setTextHighlight(phoneNumRange, color: APP_THEME_COLOR, backgroundColor: nil) { (view, str, range, rect) in
            
        }
        self.label2.attributedText = attrPhoneText
        self.label2.yb_addAttributeTapAction(with: [PHONE_NUMBER], delegate: self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension WeekendTourBookingInfoCell:YBAttributeTapActionDelegate{
    func yb_attributeTapReturn(_ string: String!, range: NSRange, index: Int) {
            UIApplication.shared.openURL(URL(string: "tel:\(PHONE_NUMBER)")!)
    }
}
