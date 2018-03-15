//
//  SuspensionMenuItemCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/13.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SuspensionMenuItemCell: UITableViewCell {
    @IBOutlet weak var itemTitle: UILabel!
    var actionModel:SuspensionMenuAction?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - misc
//    @IBAction func dealTap(_ sender: Any) {
//        if let _block = self.actionModel?.actionBlock{
//            _block()
//        }
//    }
    func configWith(model:SuspensionMenuAction?){
        self.actionModel = model
        self.itemTitle.text = model?.title
        self.itemTitle.textColor = model?.textColor
    }
}
