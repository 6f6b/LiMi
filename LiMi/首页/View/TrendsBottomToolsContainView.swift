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
            make.height.equalTo(7)
        }
        
        self.topToolsContainView = UIView()
        self.addSubview(self.topToolsContainView)
        self.topToolsContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.bottom.equalTo(self.grayBar.snp.top)
            make.right.equalTo(self)
        }
        
        self.viewNum = UILabel()
        self.topToolsContainView.addSubview(self.viewNum)
        self.viewNum.text = "浏览 2500"
        self.viewNum.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.viewNum.font = UIFont.systemFont(ofSize: 12)
        self.viewNum.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.topToolsContainView)
            make.left.equalTo(self.topToolsContainView).offset(12)
        }
        
        self.thumbsUpBtn = SuitableHotSpaceButton(type: .custom)
        self.topToolsContainView.addSubview(self.thumbsUpBtn)
        self.thumbsUpBtn.setImage(UIImage.init(named: "btn_zan_nor"), for: .normal)
        self.thumbsUpBtn.setImage(UIImage.init(named: "btn_zan_pre"), for: .selected)
        self.thumbsUpBtn.addTarget(self, action: #selector(dealTapThumbUpBtn), for: .touchUpInside)
        self.thumbsUpBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.viewNum)
            make.right.equalTo(self.topToolsContainView).offset(-150)
        }
        
        self.thumbsNum = UILabel()
        self.topToolsContainView.addSubview(self.thumbsNum)
        self.thumbsNum.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.thumbsNum.font = UIFont.systemFont(ofSize: 12)
        self.thumbsNum.text = "666"
        self.thumbsNum.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.thumbsUpBtn)
            make.left.equalTo(self.thumbsUpBtn.snp.right).offset(4)
        }
        
        self.commentBtn = SuitableHotSpaceButton()
        self.topToolsContainView.addSubview(self.commentBtn)
        self.commentBtn.setImage(UIImage.init(named: "icon_pinglun"), for: .normal)
        self.commentBtn.addTarget(self, action: #selector(dealTapCommentBtn), for: .touchUpInside)
        self.commentBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.thumbsUpBtn)
            make.right.equalTo(self.topToolsContainView).offset(-50)
        }
        
        self.commentNum = UILabel()
        self.topToolsContainView.addSubview(self.commentNum)
        self.commentNum.font = UIFont.systemFont(ofSize: 12)
        self.commentNum.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        self.commentNum.text = "666"
        self.commentNum.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.commentBtn)
            make.left.equalTo(self.commentBtn.snp.right).offset(4)
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
            self.viewNum.text = "浏览 " + _viewNum
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
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let thumbUp = ThumbUp(action_id: trendModel?.action_id?.stringValue())
        _ = moyaProvider.rx.request(.targetWith(target: thumbUp)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            HandleResultWith(model: resultModel)
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
            SVProgressHUD.showErrorWith(model: resultModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    /// 评论
    @objc func dealTapCommentBtn(){
        if let _tapCommentBtnBlock = self.tapCommentBtnBlock{
            _tapCommentBtnBlock()
        }
    }
}
