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
    var tapMoreOperationBtnBlock:(()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.headImgBtn = UIButton()
        self.addSubview(headImgBtn)
        self.headImgBtn.layer.cornerRadius = 20
        self.headImgBtn.clipsToBounds = true
        self.headImgBtn.setImage(UIImage.init(named: "touxiang1"), for: .normal)
        self.headImgBtn.addTarget(self, action: #selector(dealTapHeadBtn), for: .touchUpInside)
        self.headImgBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(9)
            make.left.equalTo(self).offset(12)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
        
        self.userName = UILabel()
        self.addSubview(self.userName)
        self.userName.font = UIFont.boldSystemFont(ofSize: 14)
        self.userName.text = "张学友"
        self.userName.snp.makeConstraints { (make) in
            make.top.equalTo(self.headImgBtn)
            make.left.equalTo(self.headImgBtn.snp.right).offset(10)
        }
        
        self.sexImg = UIImageView()
        self.addSubview(self.sexImg)
        self.sexImg.image = UIImage.init(named: "boy")
        self.sexImg.snp.makeConstraints { (make) in
            make.left.equalTo(self.userName.snp.right).offset(10)
            make.centerY.equalTo(self.userName)
        }
        
        self.userInfo = UILabel()
        self.addSubview(self.userInfo)
        self.userInfo.font = UIFont.systemFont(ofSize: 12)
        self.userInfo.text = "电机工程学院"
        self.userInfo.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.userInfo.snp.makeConstraints { (make) in
            make.left.equalTo(self.headImgBtn.snp.right).offset(10)
            make.top.equalTo(self.userName.snp.bottom).offset(8)
        }
        
        self.moreOperationBtn = UIButton()
        self.addSubview(self.moreOperationBtn)
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
        self.userName.text = model?.true_name
        //性别
        if cellStyle == .inMyTrendList{self.sexImg.isHidden = true}
        if model?.sex == "男"{
            self.sexImg.image = UIImage.init(named: "boy")
        }else{
            self.sexImg.image = UIImage.init(named: "girl")
        }
        //个人资料
        if cellStyle == .inMyTrendList{
            self.userInfo.text = model?.create_time
        }
        if cellStyle == .inPersonCenter{
            self.userInfo.text = model?.create_time
        }
        if cellStyle == .normal{
            if let college = model?.college,let academy = model?.school{
                self.userInfo.text = "\(college)|\(academy)"
            }else{self.userInfo.text = "个人资料待认证"}
        }
        //发布时间
        if cellStyle == .inMyTrendList{self.releaseTime.isHidden = true}
        self.releaseTime.text = model?.create_time
        //更多操作
    }
    
    func configWith(commentModel:CommentModel?){
        if let headImgUrl = commentModel?.head_pic{
            self.headImgBtn.kf.setImage(with: URL.init(string: headImgUrl), for: .normal)
        }
        self.userName.text = commentModel?.true_name
        if commentModel?.sex == "男"{
            self.sexImg.image = UIImage.init(named: "boy")
        }else{
            self.sexImg.image = UIImage.init(named: "girl")
        }
        if let _college = commentModel?.college,let _academy = commentModel?.school{
            self.userInfo.text = "\(_college)|\(_academy)"
        }
        self.releaseTime.text = commentModel?.create_time
    }
    
    /// 点击了头像
   @objc func dealTapHeadBtn(){
        if let _tapHeadBtnBlock = self.tapHeadBtnBlock{
            _tapHeadBtnBlock()
        }
    }
    
    @objc func dealTapMoreOperationBtn(){
        if let _tapMoreOperationBtnBlock = self.tapMoreOperationBtnBlock{
            _tapMoreOperationBtnBlock()
        }
    }
}
