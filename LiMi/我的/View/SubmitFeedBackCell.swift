//
//  SubmitFeedbackCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SubmitFeedbackCell: UITableViewCell {
    @IBOutlet weak var submitBtn: UIButton!
    var submitBlock:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.submitBtn.layer.cornerRadius = 5
        self.submitBtn.clipsToBounds = true
    }

    @IBAction func dealSubmit(_ sender: Any) {
        if let _submitBlock = self.submitBlock{
            _submitBlock()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
