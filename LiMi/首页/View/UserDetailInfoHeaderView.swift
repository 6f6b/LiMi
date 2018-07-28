//
//  UserDetailInfoHeaderView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/28.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
enum UserDetailInfoHeaderViewType {
    case inMyPersonCenter
    case inOtherPersonCenter
}

protocol UserDetailInfoHeaderViewDelegate : class{
    func userDetailInfoHeaderView(userHeadImageViewBeClicked model:UserInfoModel?,imageView:UIImageView)
    func userDetailInfoHeaderView(editButtonBeClicked model:UserInfoModel?)
    func userDetailInfoHeaderView(moreSettingButtonBeClicked model:UserInfoModel?)
    func userDetailInfoHeaderView(sentMsgButtonBeClicked model:UserInfoModel?)
    func userDetailInfoHeaderView(followRelationshipBeClicked model:UserInfoModel?,followRelationshipButton:UIButton)
    func userDetailInfoHeaderView(thumUpButtonBeClicked model:UserInfoModel?)
    func userDetailInfoHeaderView(followButtonBeClicked model:UserInfoModel?)
    func userDetailInfoHeaderView(followerButtonBeClicked model:UserInfoModel?)
    func userDetailInfoHeaderView(tapedAuthenticateBackView model:UserInfoModel?)
}
class UserDetailInfoHeaderView: UICollectionReusableView {
    @IBOutlet weak var userHeadImageView: UIImageView!
    @IBOutlet weak var userNameLabel:UILabel!
    @IBOutlet weak var limiNumLabel:UILabel!
    @IBOutlet weak var schoolNameLabel:UILabel!
    @IBOutlet weak var authenticationBackgroundView: UIView!
    @IBOutlet weak var authenticationStateLabel:UILabel!
    @IBOutlet weak var authenticationIcon:UIImageView!
    
    @IBOutlet weak var userSexImageView:UIImageView!
    @IBOutlet weak var ageLabel:UILabel!
    @IBOutlet weak var reginLabel:UILabel!
    @IBOutlet weak var constellationLabel:UILabel!
    
    @IBOutlet weak var signatureLabel:UILabel!
    @IBOutlet weak var clickedNumButton:UIButton!
    @IBOutlet weak var followedNumButton:UIButton!
    @IBOutlet weak var followerNumButton:UIButton!

    @IBOutlet weak var sendMsgButton:UIButton!
    @IBOutlet weak var followRelationshipButton:UIButton!
    
    @IBOutlet weak var editUserInfoButton:UIButton!
    @IBOutlet weak var moreSettingsButton:UIButton!

    @IBOutlet weak var sexContainView: UIView!
    @IBOutlet weak var ageLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var ageContainView: UIView!
    @IBOutlet weak var regionLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var regionContainView: UIView!
    @IBOutlet weak var constellationLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var constellationContainView: UIView!
    
    @IBOutlet weak var followRelationshipWidhtConstraint: NSLayoutConstraint!
    
    private var type:UserDetailInfoHeaderViewType?
    private var userInfoModel:UserInfoModel?
    weak var delegate:UserDetailInfoHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapUserHeadImageView = UITapGestureRecognizer.init(target: self, action: #selector(clickedUserHeadImageView))
        self.userHeadImageView.addGestureRecognizer(tapUserHeadImageView)
        
        let tapAuthenticate = UITapGestureRecognizer.init(target: self, action: #selector(tapAuthentication(_:)))
        self.authenticationBackgroundView.addGestureRecognizer(tapAuthenticate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configWith(model:UserInfoModel?,type:UserDetailInfoHeaderViewType = .inOtherPersonCenter){
        self.userInfoModel = model
        self.type = type
    
        let isInOtherPersonCenter = type == .inOtherPersonCenter ? true : false
        self.sendMsgButton.isHidden = !isInOtherPersonCenter
        self.followRelationshipButton.isHidden = !isInOtherPersonCenter
        self.editUserInfoButton.isHidden = isInOtherPersonCenter
        self.moreSettingsButton.isHidden = isInOtherPersonCenter
        
        if let headPic = model?.head_pic{
            self.userHeadImageView.kf.setImage(with: URL.init(string: headPic), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        //性别
        if let _sex = model?.sex{
            self.sexContainView.isHidden = false
            if _sex == 0{
                self.userSexImageView?.image = UIImage.init(named: "me_ic_girl")
            }else{
                self.userSexImageView?.image = UIImage.init(named: "me_ic_boy")
            }
        }else{
//            self.sexContainView.isHidden = true
            self.sexContainView.isHidden = false

        }
        //年龄星座
        
        if let _birthday = model?.birthday{
            self.ageContainView.isHidden = false
            self.ageLeftConstraint.constant = 8
            self.constellationLabel.isHidden = false
            self.constellationLeftConstraint.constant = 8
            
            let date = Date.init(timeIntervalSinceNow: TimeInterval.init(_birthday))
            self.ageLabel.text = date.getAge().stringValue() + "岁"
            self.constellationLabel.text = date.getConstellation()
        }else{
            self.ageContainView.isHidden = false
            self.ageLeftConstraint.constant = 8
            self.constellationLabel.isHidden = false
            self.constellationLeftConstraint.constant = 8
            self.ageLabel.text = "年龄"
            self.constellationLabel.text = "星座"
//            self.ageContainView.isHidden = true
//            self.ageLeftConstraint.constant = 0
//            self.constellationContainView.isHidden = true
//            self.constellationLeftConstraint.constant = 0
        }
        
        //地区
        if let _region = model?.city?.name{
            self.regionContainView.isHidden = false
            self.regionLeftConstraint.constant = 8
            self.reginLabel.text = _region
        }else{
            self.regionContainView.isHidden = false
            self.regionLeftConstraint.constant = 8
            self.reginLabel.text = "地区"
//            self.regionContainView.isHidden = true
//            self.regionLeftConstraint.constant = 0
        }
        self.userNameLabel.text = model?.nickname
        if let limiCode = model?.id_code{
            self.limiNumLabel.text = "粒米号：" + limiCode
        }
        let signature = model?.signature ?? "暂无签名"
        self.signatureLabel.text = signature
        if let followsNum = model?.attention_num,let followersNum = model?.fans_num,let clickNum = model?.click_num{
            let followsNumAttr = NSMutableAttributedString.init(string: followsNum.suitableStringValue(), attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17, weight: .bold),NSAttributedStringKey.foregroundColor:UIColor.white])
            let followsNumLabel = NSAttributedString.init(string: "  关注", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17, weight: .bold),NSAttributedStringKey.foregroundColor:UIColor.white])
            followsNumAttr.append(followsNumLabel)
            self.followedNumButton.setAttributedTitle(followsNumAttr, for: .normal)
            
            let followersNumAttr = NSMutableAttributedString.init(string: followersNum.suitableStringValue(), attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17, weight: .bold),NSAttributedStringKey.foregroundColor:UIColor.white])
            let followersNumLabel = NSAttributedString.init(string: "  粉丝", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17, weight: .bold),NSAttributedStringKey.foregroundColor:UIColor.white])
            followersNumAttr.append(followersNumLabel)
            self.followerNumButton.setAttributedTitle(followersNumAttr, for: .normal)
            
            let beLikedNumAttr = NSMutableAttributedString.init(string: clickNum.suitableStringValue(), attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17, weight: .bold),NSAttributedStringKey.foregroundColor:UIColor.white])
            let beLikedNumLabel = NSAttributedString.init(string: "  获赞", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17, weight: .bold),NSAttributedStringKey.foregroundColor:UIColor.white])
            beLikedNumAttr.append(beLikedNumLabel)
            self.clickedNumButton.setAttributedTitle(beLikedNumAttr, for: .normal)
        }
        self.schoolNameLabel.text = model?.college?.name
        
//        var authenticationTitle = ""
//        if self.userInfoModel?.is_access == 0{
//            //未认证
//            authenticationTitle = "未认证"
//        }
//        if self.userInfoModel?.is_access == 1{
//            //认证中
//            authenticationTitle = "认证中"
//            self.authenticationButton.isUserInteractionEnabled = false
//        }
//        if self.userInfoModel?.is_access == 2{
//            //认证通过
//            authenticationTitle = "认证通过"
//            self.authenticationButton.isUserInteractionEnabled = false
//        }
//        if self.userInfoModel?.is_access == 3{
//            //认证失败
//            authenticationTitle = "认证失败"
//        }
        
        if model?.is_access == 0{
            self.authenticationStateLabel.text = "未认证"
            self.authenticationBackgroundView.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
            self.authenticationBackgroundView.isUserInteractionEnabled = true
        }
        if model?.is_access == 1{
            self.authenticationStateLabel.text = "认证中"
            self.authenticationBackgroundView.backgroundColor = APP_THEME_COLOR_2
            self.authenticationBackgroundView.isUserInteractionEnabled = false
        }
        if model?.is_access == 2{
            self.authenticationStateLabel.text = "已认证"
            self.authenticationBackgroundView.backgroundColor = APP_THEME_COLOR_2
            self.authenticationBackgroundView.isUserInteractionEnabled = false
        }
        if model?.is_access == 3{
            self.authenticationStateLabel.text = "认证失败"
            self.authenticationBackgroundView.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
            self.authenticationBackgroundView.isUserInteractionEnabled = true
        }
        
//        if model?.is_access == 2{
//            self.authenticationStateLabel.text = "已认证"
//            self.authenticationBackgroundView.backgroundColor = APP_THEME_COLOR_2
//        }else{
//            self.authenticationStateLabel.text = "未认证"
//            self.authenticationBackgroundView.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
//        }
        
        self.followRelationshipWidhtConstraint.constant = 80
        if model?.is_attention == 0{
            self.followRelationshipButton.setTitle("关注", for: .normal)
            self.followRelationshipButton.setImage(UIImage.init(named: "user_ic_follow"), for: .normal)
        }
        if model?.is_attention == 1{
            self.followRelationshipButton.setTitle("已关注", for: .normal)
            self.followRelationshipButton.setImage(UIImage.init(named: "user_ic_follow2"), for: .normal)
        }
        if model?.is_attention == 2{
            self.followRelationshipButton.setTitle("互相关注", for: .normal)
            self.followRelationshipButton.setImage(UIImage.init(named: "user_ic_follow3"), for: .normal)
            self.followRelationshipWidhtConstraint.constant = 115
        }
        self.followRelationshipButton.sizeToFit()
    }
    
    //MARK: - actions
    
    //点击了认证背景
    @objc func tapAuthentication(_ sender:Any){
        if let _type = self.type{
            if _type == .inMyPersonCenter{
                self.delegate?.userDetailInfoHeaderView(tapedAuthenticateBackView: self.userInfoModel)
            }
        }
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        self.delegate?.userDetailInfoHeaderView(editButtonBeClicked: self.userInfoModel)
    }
    @IBAction func moreSettingsClicked(_ sender: Any) {
        self.delegate?.userDetailInfoHeaderView(moreSettingButtonBeClicked: self.userInfoModel)
    }
    @IBAction func sentMsgButtonClicked(_ sender: Any) {
        self.delegate?.userDetailInfoHeaderView(sentMsgButtonBeClicked: self.userInfoModel)

    }
    @IBAction func followRelationShipButtonClicked(_ sender: Any) {
        self.delegate?.userDetailInfoHeaderView(followRelationshipBeClicked: self.userInfoModel, followRelationshipButton: self.followRelationshipButton)
    }
    
    @IBAction func thumUpButtonClicked(_ sender: Any) {
        self.delegate?.userDetailInfoHeaderView(thumUpButtonBeClicked: self.userInfoModel)

    }
    
    @IBAction func followButtonClicked(_ sender: Any) {
        self.delegate?.userDetailInfoHeaderView(followButtonBeClicked: self.userInfoModel)

    }
    
    @IBAction func followerButtonClicked(_ sender: Any) {
        self.delegate?.userDetailInfoHeaderView(followerButtonBeClicked: self.userInfoModel)

    }
    @objc func clickedUserHeadImageView(){
        self.delegate?.userDetailInfoHeaderView(userHeadImageViewBeClicked: self.userInfoModel,imageView:self.userHeadImageView)

    }
}
