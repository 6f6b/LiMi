//
//  TrendsBottomToolsContainView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import Moya
import ObjectMapper

class TrendsBottomToolsContainView: UIView {
    var topToolsContainView:UIView!  //顶部工具栏容器
    var viewNumIcon:UIImageView!    //浏览量图标
    var viewNum:UILabel!    //浏览量
    var thumbsUpBtn:UIButton!   //点赞按钮
    var thumbsNum:UILabel!  //点赞数量
    var commentBtn:UIButton! //评论按钮
    var commentNum:UILabel! //评论数量
    var grayBar:UIView! //底部灰色长条

    var trendModel:TrendModel?  //动态模型
    var tapCommentBtnBlock:(()->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.grayBar = UIView()
        self.addSubview(self.grayBar)
        self.grayBar.backgroundColor = UIColor.groupTableViewBackground
        self.grayBar.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(0)
        }
        
        self.topToolsContainView = UIView()
        self.addSubview(self.topToolsContainView)
        self.topToolsContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.bottom.equalTo(self.grayBar.snp.top)
            make.right.equalTo(self)
        }
        
        self.viewNumIcon = UIImageView()
        self.viewNumIcon.image = UIImage.init(named: "home_ic_liulan")
        self.viewNumIcon.sizeToFit()
        self.topToolsContainView.addSubview(self.viewNumIcon)
        self.viewNumIcon.snp.makeConstraints { (make) in
            make.top.equalTo(self.topToolsContainView).offset(15)
            make.left.equalTo(self.topToolsContainView).offset(15)
            make.centerY.equalTo(self.topToolsContainView)
        }
        
        self.viewNum = UILabel()
        self.topToolsContainView.addSubview(self.viewNum)
        self.viewNum.text = "-++-"
        self.viewNum.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.viewNum.font = UIFont.systemFont(ofSize: 12)
        self.viewNum.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.topToolsContainView)
            make.left.equalTo(self.viewNumIcon.snp.right).offset(5)
        }
        
        self.thumbsUpBtn = SuitableHotSpaceButton(type: .custom)
        self.topToolsContainView.addSubview(self.thumbsUpBtn)
        self.thumbsUpBtn.setImage(UIImage.init(named: "home_ic_zan_nol"), for: .normal)
        self.thumbsUpBtn.setImage(UIImage.init(named: "home_ic_zan_pre"), for: .selected)
        self.thumbsUpBtn.addTarget(self, action: #selector(dealTapThumbUpBtn), for: .touchUpInside)
        self.thumbsUpBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.viewNum)
            make.left.equalTo(self.viewNum.snp.right).offset(25)
        }
        
        self.thumbsNum = UILabel()
        self.topToolsContainView.addSubview(self.thumbsNum)
        self.thumbsNum.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.thumbsNum.font = UIFont.systemFont(ofSize: 12)
        self.thumbsNum.text = "--"
        self.thumbsNum.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.thumbsUpBtn)
            make.left.equalTo(self.thumbsUpBtn.snp.right).offset(5)
        }
        
        self.commentBtn = SuitableHotSpaceButton()
        self.topToolsContainView.addSubview(self.commentBtn)
        self.commentBtn.setImage(UIImage.init(named: "home_ic_pl"), for: .normal)
        self.commentBtn.addTarget(self, action: #selector(dealTapCommentBtn), for: .touchUpInside)
        self.commentBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.thumbsUpBtn)
            make.left.equalTo(self.thumbsNum.snp.right).offset(25)
        }
        
        self.commentNum = UILabel()
        self.topToolsContainView.addSubview(self.commentNum)
        self.commentNum.font = UIFont.systemFont(ofSize: 12)
        self.commentNum.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.commentNum.text = "--"
        self.commentNum.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.commentBtn)
            make.left.equalTo(self.commentBtn.snp.right).offset(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - misc
    func configWith(model:TrendModel?){
        self.trendModel = model
//        var topToolsContainView:UIView!  //顶部工具栏容器
//        var viewNum:UILabel!    //浏览量
//        var thumbsUpBtn:UIButton!   //点赞按钮
//        var thumbsNum:UILabel!  //点赞数量
//        var commentBtn:UIButton! //评论按钮
//        var commentNum:UILabel! //评论数量
//        var grayBar:UIView! //底部灰色长条
        if let _viewNum = model?.view_num{
            self.viewNum.text = _viewNum
        }
        self.thumbsNum.text = model?.click_num?.stringValue()
        self.commentNum.text = model?.discuss_num?.stringValue()
        var isSelected = false
        if let _isClick = model?.is_click{
            if _isClick == 1{isSelected = true}
        }
        self.thumbsUpBtn.isSelected = isSelected
    }
    
    /// 点赞
    @objc func dealTapThumbUpBtn(){
        if !AppManager.shared.checkUserStatus(){return}
        //判断动态种类
        var body:TargetType!
        if self.trendModel?.topic_action_id != nil{
            body = ClickAction(topic_action_id: trendModel?.action_id)
        }else{
            body = ThumbUp(action_id: trendModel?.action_id?.stringValue())
        }
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: body)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                self.thumbsUpBtn.isSelected = !self.thumbsUpBtn.isSelected
                if self.thumbsUpBtn.isSelected{
                    self.trendModel?.click_num! += 1
                    self.trendModel?.is_click = 1
                }else{
                    self.trendModel?.click_num! -= 1
                    self.trendModel?.is_click = 0
                }
                NotificationCenter.default.post(name: THUMBS_UP_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:self.trendModel])
            }
            Toast.showErrorWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    /// 评论
    @objc func dealTapCommentBtn(){
        if !AppManager.shared.checkUserStatus(){return}

        if let _tapCommentBtnBlock = self.tapCommentBtnBlock{
            _tapCommentBtnBlock()
        }
    }
}
