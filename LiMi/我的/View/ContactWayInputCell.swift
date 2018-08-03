//
//  ContactWayInputCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ContactWayInputCell: UITableViewCell {
    @IBOutlet weak var contactInfo: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contactInfo.setValue(RGBA(r: 114, g: 114, b: 114, a: 1), forKeyPath: "_placeholderLabel.textColor")
        contactInfo.placeholder = "选填，便于我们与您联系"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
