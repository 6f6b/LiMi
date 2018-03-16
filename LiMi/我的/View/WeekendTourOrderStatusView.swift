//
//  WeekendTourOrderStatusView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/8.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import YYText

class WeekendTourOrderStatusView: UIView {
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    var phoneLabel: YYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containView.layer.cornerRadius = 10
        self.containView.clipsToBounds = true
        
        self.phoneLabel = YYLabel.init()
        self.containView.addSubview(self.phoneLabel)
        self.phoneLabel.lineBreakMode = .byWordWrapping
        self.phoneLabel.numberOfLines = 0
        self.phoneLabel.preferredMaxLayoutWidth = self.infoLabel.frame.size.width
        self.phoneLabel.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.infoLabel.snp.bottom).offset(15)
            make.left.equalTo(self.containView).offset(30)
            make.right.equalTo(self.containView).offset(-30)
            make.bottom.equalTo(self.containView).offset(-30)
        }
    }

    func refreshUIWith(model:WeekendTourOrderModel?){
        if model?.order_status == 1{
            self.infoLabel.text = "订单已支付"
        }else{
            self.infoLabel.text = "订单已完成"
        }
        let phoneText = "若有疑问，请致电\(PHONE_NUMBER)"
        let nsPhoneText = NSString.init(string: phoneText)
        let phoneNumRange = nsPhoneText.range(of: PHONE_NUMBER)
        let attrPhoneText = NSMutableAttributedString.init(string: phoneText)
        attrPhoneText.yy_font = self.phoneLabel.font
        attrPhoneText.yy_color = self.phoneLabel.textColor
        attrPhoneText.yy_alignment = .center
        attrPhoneText.yy_setTextHighlight(phoneNumRange, color: APP_THEME_COLOR, backgroundColor: nil) { (view, str, range, rect) in
            self.removeFromSuperview()
            UIApplication.shared.openURL(URL(string: "tel:\(PHONE_NUMBER)")!)
        }
        self.phoneLabel.attributedText = attrPhoneText
    }
    
    
    
    @IBAction func dealClose(_ sender: Any) {
        self.removeFromSuperview()
    }
}

