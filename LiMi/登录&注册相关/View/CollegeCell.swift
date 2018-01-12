//
//  CollegeCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/12.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class CollegeCell: UITableViewCell {
    @IBOutlet weak var collegeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configWithTitle(title:String?){
        self.collegeName.text = title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
