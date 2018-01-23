//
//  SelectPayWayView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SelectPayWayView: UIView {
    @IBOutlet weak var containView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containView.layer.cornerRadius = 20
        containView.clipsToBounds = true
    }

    @IBAction func dealChoseWeChatPay(_ sender: Any) {
    }
    
    @IBAction func dealChoseAlipay(_ sender: Any) {
    }
    
    @IBAction func dealClose(_ sender: Any) {
        self.removeFromSuperview()
    }
}
