//
//  ChallengeListCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class ChallengeListCell: UITableViewCell {
    @IBOutlet weak var challengeName: UILabel!
    @IBOutlet weak var challengeInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func configWith(model:ChallengeModel){
        self.challengeName.text = model.challenge_name
        if let _ = model.challenge_id , let useNum = model.use_num{
            self.challengeInfo.text = "\(useNum)人参与挑战"
        }else{
            self.challengeInfo.text = "无人挑战，点击发起"
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
