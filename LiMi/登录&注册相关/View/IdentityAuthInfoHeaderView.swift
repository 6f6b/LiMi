//
//  IdentityAuthInfoHeaderView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class IdentityAuthInfoHeaderView: UIView {
    var deleteBlock:(()->Void)?
    @IBOutlet weak var noticeLabel: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!

    override func awakeFromNib() {
        self.deleteBtn.layer.cornerRadius = 7
        self.deleteBtn.clipsToBounds = true
    }

    @IBAction func dealDelete(_ sender: Any) {
        if let deleteBlock = self.deleteBlock{
            deleteBlock()
        }
    }
}
