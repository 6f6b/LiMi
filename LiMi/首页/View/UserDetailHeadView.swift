//
//  UserDetailHeadView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class UserDetailHeadView: UIView {
    @IBOutlet weak var headImgContainView: UIView!
    @IBOutlet weak var headImgV: UIImageView!
    @IBOutlet weak var userInfoContainView: UIView!
    @IBOutlet weak var headIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var sexImg: UIImageView!
    
    override func awakeFromNib() {
        self.userInfoContainView.layer.cornerRadius = 15
//        self.userInfoContainView.clipsToBounds = true
        self.headIcon.layer.cornerRadius = 45
        self.headIcon.clipsToBounds = true
    }
    
    func configWith(model:UserInfoModel?){
        if let headPic = model?.head_pic{
            self.headIcon.kf.setImage(with: URL.init(string: headPic), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        if model?.sex == "女"{
            self.sexImg.image = UIImage.init(named: "girl")
        }else{
            self.sexImg.image = UIImage.init(named: "boy")
        }
        self.userName.text = model?.true_name
        if let college = model?.college,let grade = model?.grade,let academy = model?.school{
            self.userInfo.text = "\(college)|\(grade)  \(academy)"
        }else{self.userInfo.text = "个人资料待认证"}
    }
}
