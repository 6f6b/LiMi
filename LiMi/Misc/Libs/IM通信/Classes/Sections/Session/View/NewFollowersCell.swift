//
//  NewFollowersCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class NewFollowersCell: UITableViewCell {
    @IBOutlet weak var headPic: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configWith(model:UserInfoModel?){
        if let _headPic = model?.head_pic{
            self.headPic.kf.setImage(with: URL.init(string: _headPic), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.nickName.text = model?.nickname
        self.timeLabel.text = model?.time
    }
}
