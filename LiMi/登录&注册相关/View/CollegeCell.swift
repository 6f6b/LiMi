//
//  CollegeCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/12.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
enum CollegeCellStyle {
    case defaultStyle
    case black
}
class CollegeCell: UITableViewCell {
    @IBOutlet weak var collegeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configWithTitle(title:String?,style:CollegeCellStyle = .defaultStyle){
        self.collegeName.text = title
        if style == .black{
            self.collegeName.textColor = UIColor.white
            self.contentView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
