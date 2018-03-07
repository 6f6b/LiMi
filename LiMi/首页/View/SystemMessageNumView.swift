//
//  SystemMessageNumView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/5.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SystemMessageNumView: UIView {
    @IBOutlet weak var msgNum: UILabel!
    var tapBlock:(()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.msgNum.layer.cornerRadius = 7
        self.msgNum.clipsToBounds = true
        
    }
    
    @IBAction func dealTap(_ sender: Any) {
        if let _tapBlock = self.tapBlock{
            _tapBlock()
        }
    }
    
    func showWith(unreadSystemMsgNum:Int){
        self.msgNum.isHidden = unreadSystemMsgNum <= 0 ? true : false
        var str = ""
        if unreadSystemMsgNum >= 99{str = " 99+ "}else{
            str = " \(unreadSystemMsgNum) "
        }
        self.msgNum.text = str
    }
}
