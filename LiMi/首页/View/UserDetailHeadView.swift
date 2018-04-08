//
//  UserDetailHeadView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class UserDetailHeadView: UIView {
    @IBOutlet weak var backImageView: UIImageView!
    
    //头像
    @IBOutlet weak var headImgBtn: UIButton!
    //昵称
    @IBOutlet weak var nickName: UILabel!
    //性别
    @IBOutlet weak var sexImg: UIImageView!
    
    //认证状态
    @IBOutlet weak var authenticationState: UILabel!
    
    //个性签名
    @IBOutlet weak var signature: UILabel!
    //关注
    @IBOutlet weak var follows: UILabel!
    //粉丝
    @IBOutlet weak var followers: UILabel!
    
    var userInfoModel:UserInfoModel?
    override func awakeFromNib() {

        self.headImgBtn.addTarget(self, action: #selector(dealTap), for: .touchUpInside)
    }
    
    func configWith(model:UserInfoModel?){
        self.userInfoModel = model
        if let headPic = model?.head_pic{
            self.headImgBtn.kf.setImage(with: URL.init(string: headPic), for: .normal, placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        if model?.sex == "女"{
            self.sexImg.image = UIImage.init(named: "ic_girl")
        }else{
            self.sexImg.image = UIImage.init(named: "ic_boy")
        }
        self.nickName.text = model?.nickname
        self.signature.text = model?.signature
        if let followsNum = model?.attention_num,let followersNum = model?.fans_num{
            let followsNumAttr = NSMutableAttributedString.init(string: followsNum, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 20),NSAttributedStringKey.foregroundColor:UIColor.white])
            let followsNumLabel = NSAttributedString.init(string: "  关注", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:UIColor.white])
            followsNumAttr.append(followsNumLabel)
            self.follows.attributedText = followsNumAttr
            
            let followersNumAttr = NSMutableAttributedString.init(string: followersNum, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 20),NSAttributedStringKey.foregroundColor:UIColor.white])
            let followersNumLabel = NSAttributedString.init(string: "  粉丝", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:UIColor.white])
            followersNumAttr.append(followersNumLabel)
            self.followers.attributedText = followersNumAttr
        }
        if let backPic = model?.back_pic{
            self.backImageView.kf.setImage(with: URL.init(string: backPic), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        if model?.is_access == 2{
            self.authenticationState.text = "已认证"
            self.authenticationState.textColor = UIColor.white
            self.authenticationState.backgroundColor = APP_THEME_COLOR
        }else{
            self.authenticationState.text = "未认证"
            self.authenticationState.textColor = UIColor.white
            self.authenticationState.backgroundColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        }
    }
    
    @objc func dealTap(){
        if let _ = self.userInfoModel?.head_pic,let _ = self.headImgBtn.imageView?.image{
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
        return self.headImgBtn.imageView?.image
    }
    
    func photoBrowser(_ browser: XLPhotoBrowser!, sourceImageViewFor index: Int) -> UIImageView! {
        return self.headImgBtn.imageView
    }
    
    func photoBrowser(_ browser: XLPhotoBrowser!, highQualityImageURLFor index: Int) -> URL! {
        let url = URL.init(string: (self.userInfoModel?.head_pic)!)
        return url
    }
}
