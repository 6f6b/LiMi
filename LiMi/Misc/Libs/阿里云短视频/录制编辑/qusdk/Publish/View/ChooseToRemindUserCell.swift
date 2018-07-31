//
//  ChooseToRemindUserCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/30.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class ChooseToRemindUserCell: UITableViewCell {
    var userInfoModel:UserInfoModel?
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var headPic: UIImageView!
    @IBOutlet weak var collegeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configWith(model:UserInfoModel?){
        self.userInfoModel = model
        self.nickName.text = model?.nickname
        if let headPic = model?.head_pic{
            self.headPic.kf.setImage(with: URL.init(string: headPic), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.collegeName.text = model?.college?.name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
