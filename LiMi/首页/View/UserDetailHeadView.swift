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
    var userInfoModel:UserInfoModel?
    override func awakeFromNib() {
        self.userInfoContainView.layer.cornerRadius = 15
//        self.userInfoContainView.clipsToBounds = true
        self.headIcon.layer.cornerRadius = 45
        self.headIcon.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dealTap))
        self.headIcon.addGestureRecognizer(tap)
    }
    
    func configWith(model:UserInfoModel?){
        self.userInfoModel = model
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
    
    @objc func dealTap(){
        if let _ = self.userInfoModel?.head_pic,let _ = self.headIcon.image{
            let photoBroswer = XLPhotoBrowser.show(withCurrentImageIndex: 0, imageCount: 1, datasource: self)
            photoBroswer?.browserStyle = .indexLabel
            photoBroswer?.setActionSheeWith(self)
        }
    }
}

extension UserDetailHeadView:XLPhotoBrowserDelegate,XLPhotoBrowserDatasource{
    func photoBrowser(_ browser: XLPhotoBrowser!, clickActionSheetIndex actionSheetindex: Int, currentImageIndex: Int) {
        browser.saveCurrentShowImage()
    }
    
    func photoBrowser(_ browser: XLPhotoBrowser!, placeholderImageFor index: Int) -> UIImage! {
        return self.headIcon.image!
    }
    
    func photoBrowser(_ browser: XLPhotoBrowser!, sourceImageViewFor index: Int) -> UIImageView! {
        return self.headIcon
    }
    
    func photoBrowser(_ browser: XLPhotoBrowser!, highQualityImageURLFor index: Int) -> URL! {
        let url = URL.init(string: (self.userInfoModel?.head_pic)!)
        return url
    }
}
