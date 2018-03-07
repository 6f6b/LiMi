//
//  WeekendTourOrderPayWayCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit


class WeekendTourOrderPayWayCell: UITableViewCell {
    @IBOutlet var btns: [UIButton]!
    var payWay:PayWay = .wechatPay
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func dealSelectPayWay(_ sender: Any) {
        let btn = sender as! UIButton
        for btn in btns{
            btn.isSelected = false
        }
        btn.isSelected = true
        if btn.tag == 0{self.selectWith(payWay: .wechatPay)}
        if btn.tag == 1{self.selectWith(payWay: .alipay)}
    }
    
    func selectWith(payWay:PayWay){
        self.payWay = payWay
    }
}
