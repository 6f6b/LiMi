//
//  WeekendTourSeparateCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
enum WeekendTourSeparateCellType {
    case circleHome
    case weekendTourList
}
class WeekendTourSeparateCell: UITableViewCell {
    @IBOutlet weak var topConstraints: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var info: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setType(type:WeekendTourSeparateCellType){
        if type == .circleHome{
            self.topConstraints.constant = 15
            self.bottomConstraints.constant = 15
        }else{
            return
        }
    }
}
