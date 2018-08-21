//
//  TrendsTopToolsContainView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TrendsTopToolsContainView: UIView {
    var headImgBtn:UIButton!    //头像按钮
    var userName:UILabel!   //用户名称
    var sexImg:UIImageView! //用户性别图标
    var userInfo:UILabel! //用户基本信息
    var moreOperationBtn:UIButton!   //更多操作按钮
    var releaseTime:UILabel!    //发布时间
    
    var tapHeadBtnBlock:(()->Void)?
    var tapMoreOperationBtnBlock:((UIView?)->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.headImgBtn = UIButton()
        self.addSubview(headImgBtn)
        self.headImgBtn.layer.cornerRadius = 20
        self.headImgBtn.clipsToBounds = true
        self.headImgBtn.setImage(UIImage.init(named: "touxiang"), for: .normal)
        self.headImgBtn.addTarget(self, action: #selector(dealTapHeadBtn), for: .touchUpInside)
        self.headImgBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(15)
            make.left.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-15)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
        
        self.userName = UILabel()
        self.userName.textColor = APP_THEME_COLOR_2
        self.addSubview(self.userName)
        self.userName.font = UIFont.boldSystemFont(ofSize: 14)
        self.userName.text = ""
        self.userName.snp.makeConstraints { (make) in
            make.top.equalTo(self.headImgBtn)
            make.left.equalTo(self.headImgBtn.snp.right).offset(10)
        }
        
        self.sexImg = UIImageView()
        self.addSubview(self.sexImg)
        self.sexImg.image = nil
        self.sexImg.snp.makeConstraints { (make) in
            make.left.equalTo(self.userName.snp.right).offset(10)
            make.centerY.equalTo(self.userName)
        }
        
        self.userInfo = UILabel()
        self.addSubview(self.userInfo)
        self.userInfo.font = UIFont.systemFont(ofSize: 12)
        self.userInfo.text = ""
        self.userInfo.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.userInfo.snp.makeConstraints { (make) in
            make.left.equalTo(self.headImgBtn.snp.right).offset(10)
            make.top.equalTo(self.userName.snp.bottom).offset(8)
        }
        
        self.moreOperationBtn = UIButton()
        self.addSubview(self.moreOperationBtn)
        self.moreOperationBtn.contentMode = .right
        self.moreOperationBtn.setImage(UIImage.init(named: "btn_jubao"), for: .normal)
        self.moreOperationBtn.addTarget(self, action: #selector(dealTapMoreOperationBtn), for: .touchUpInside)
        self.moreOperationBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.sexImg)
            make.right.equalTo(self).offset(-12)
        }
        
        self.releaseTime = UILabel()
        self.addSubview(self.releaseTime)
        self.releaseTime.font = UIFont.systemFont(ofSize: 12)
        self.releaseTime.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.releaseTime.text = "5分钟前"
        self.releaseTime.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.userInfo)
            make.right.equalTo(self).offset(-12)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - misc
    func configWith(model:TrendModel?,cellStyle:TrendsCellStyle = .normal){
        
//        var headImgBtn:UIButton!    //头像按钮
//        var userName:UILabel!   //用户名称
//        var sexImg:UIImageView! //用户性别图标
//        var userInfo:UILabel! //用户基本信息
//        var moreOperationBtn:UIButton!   //更多操作按钮
//        var releaseTime:UILabel!    //发布时间
        //头像
        if let headImgUrl = model?.head_pic{
            self.headImgBtn.kf.setImage(with: URL.init(string: headImgUrl), for: .normal)
        }
        //姓名
        self.userName.text = model?.nickname
        //性别
        if cellStyle == .inMyTrendList{self.sexImg.isHidden = true}
        if cellStyle == .inPersonCenter{self.sexImg.isHidden = true}
        if model?.sex == "男"{
            self.sexImg.image = UIImage.init(named: "ic_boy")
        }else{
            self.sexImg.image = UIImage.init(named: "ic_girl")
        }
        //个人资料
        if cellStyle == .inMyTrendList{
            self.userInfo.text = model?.create_time
        }
        if cellStyle == .inPersonCenter{
            self.userInfo.text = model?.create_time
        }
        if cellStyle == .normal || cellStyle == .inCommentList{
            if let college = model?.college,let academy = model?.school{
                self.userInfo.text = "\(college)|\(academy)"
            }else{self.userInfo.text = "个人资料待认证"}
        }
        //发布时间
        if cellStyle == .inMyTrendList{self.releaseTime.isHidden = true}
        self.releaseTime.text = model?.create_time
        //更多操作
    }
    
    func configWith(topicCircleModel:TopicCircleModel?){
//        var id:Int?
//        var status:Int?
//        var user_id:Int?
//        var title:String?
//        var content:String?
//        var head_pic:String?
//        var true_name:String?
//        var pics:[String]?
//        var pics_num:Int?
        //头像
        if let headImgUrl = topicCircleModel?.head_pic{
            self.headImgBtn.kf.setImage(with: URL.init(string: headImgUrl), for: .normal)
        }
        //姓名
        self.userName.text = topicCircleModel?.title
        //性别
        self.sexImg.isHidden = true

        //个人资料
        if let _trueName = topicCircleModel?.nickname{
            self.userInfo.text = "基于“\(_trueName)”推荐"
        }else{
            self.userInfo.text = "官方推荐"
            self.headImgBtn.setImage(UIImage.init(named: "ic_touxiang"), for: .normal)
        }

        //发布时间
        self.releaseTime.isHidden = true
        //更多操作
    }
    
    func configWith(commentModel:CommentModel?){
        if let headImgUrl = commentModel?.head_pic{
            self.headImgBtn.kf.setImage(with: URL.init(string: headImgUrl), for: .normal, placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.userName.text = commentModel?.nickname
        if commentModel?.sex == "男"{
            self.sexImg.image = UIImage.init(named: "ic_boy")
        }else{
            self.sexImg.image = UIImage.init(named: "ic_girl")
        }
        self.userInfo.text = commentModel?.create_time
//        if let _college = commentModel?.college,let _academy = commentModel?.school{
//            self.userInfo.text = "\(_college)|\(_academy)"
//        }
        self.releaseTime.isHidden = true
        //self.releaseTime.text = commentModel?.create_time
    }
    
    /// 点击了头像
   @objc func dealTapHeadBtn(){
        if let _tapHeadBtnBlock = self.tapHeadBtnBlock{
            _tapHeadBtnBlock()
        }
    }
    
    @objc func dealTapMoreOperationBtn(){
        if let _tapMoreOperationBtnBlock = self.tapMoreOperationBtnBlock{
            _tapMoreOperationBtnBlock(self.moreOperationBtn)
        }
    }
}
