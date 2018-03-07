//
//  TrendsCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SnapKit

///动态只有一张的图片的时候的图片宽高比
let singlePictureHeightAndWidthRatio = 0.75

///多张图片的水平间距和垂直间距
let multiPictureSpacing = 3.0

///多张图片时图片高宽比
let multiPictureHeightAndWidthRatio = 1.0

///多媒体容器到屏幕边缘的距离
let mediaContainViewMarginToWindow = 0.0

///文字内容区域到屏幕边缘的距离
let textAreaMarginToWindow = 12.0

///动态内容区域到底部工具栏距离
let trendsContainViewSpacingToBottomToolsView = 10.0

class TrendsCell: UITableViewCell {
    var model:TrendModel?
    var cellStyle:TrendsCellStyle = .normal
    
    var trendsContainView:UIView!   //最底层容器
    
    /// 顶部工具栏容器
    var trendsTopToolsContainView:TrendsTopToolsContainView!    //顶部工具栏容器
    
    /// 发布内容区域
    var trendsContentContainView:UIView!
    
    /// 底部工具栏容器
    var trendsBottomToolsContainView:TrendsBottomToolsContainView!    //底部工具容器
    
    ///底部灰色分隔bar
    var grayBar:UIView!
    
    var redPacketBtn:UIButton!
    var  catchRedPacketBlock:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.trendsContainView = UIView()
//        self.trendsContainView.backgroundColor = UIColor.red
        self.contentView.addSubview(trendsContainView)
        self.trendsContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
        }
        
        self.trendsTopToolsContainView = TrendsTopToolsContainView()
        self.trendsContainView.addSubview(self.trendsTopToolsContainView)
        self.trendsTopToolsContainView.tapHeadBtnBlock = {
            print("点击了头像")
        }
        self.trendsTopToolsContainView.tapMoreOperationBtnBlock = {
            print("点击了更多")
        }
        self.trendsTopToolsContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsContainView)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.height.equalTo(60)
        }
        
        self.grayBar = UIView()
        self.trendsContainView.addSubview(self.grayBar)
        self.grayBar.backgroundColor = UIColor.groupTableViewBackground
        self.grayBar.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.trendsContainView)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.height.equalTo(7)
        }
        
        self.trendsBottomToolsContainView = TrendsBottomToolsContainView()
        self.trendsContainView.addSubview(self.trendsBottomToolsContainView)
        self.trendsBottomToolsContainView.tapCommentBtnBlock = {
            print("点击了评论")
        }
        self.trendsBottomToolsContainView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.grayBar.snp.top)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.height.equalTo(36)
        }
        
        self.trendsContentContainView = UIView()
//        self.trendsContentContainView.backgroundColor = UIColor.green
        self.trendsContainView.addSubview(self.trendsContentContainView)
        self.trendsContentContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsTopToolsContainView.snp.bottom)
            make.left.equalTo(self.trendsContainView)
            make.bottom.equalTo(self.trendsBottomToolsContainView.snp.top).offset(-trendsContainViewSpacingToBottomToolsView)
            make.right.equalTo(self.trendsContainView)
        }
        
        self.redPacketBtn = UIButton()
        self.redPacketBtn.isHidden = true
        self.redPacketBtn.setImage(UIImage.init(named: "btn_hongbao_1"), for: .normal)
        self.redPacketBtn.addTarget(self, action: #selector(dealCatchRedPacket), for: .touchUpInside)
        self.redPacketBtn.sizeToFit()
        self.trendsContainView.addSubview(redPacketBtn)
        self.redPacketBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.trendsBottomToolsContainView).offset(-15)
            make.right.equalTo(self.trendsContainView)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealCatchedRedPacket(notification:)), name: CATCHED_RED_PACKET_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealThumbsUp(notification:)), name: THUMBS_UP_NOTIFICATION, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: CATCHED_RED_PACKET_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: THUMBS_UP_NOTIFICATION, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    //MARK: - misc
    func configWith(model:TrendModel?){
        self.model = model
        self.trendsTopToolsContainView.configWith(model: model,cellStyle: self.cellStyle)
        if let _redType = model?.red_type{
            self.redPacketBtn.isHidden = false
            var imgName = "btn_hongbao_all"
            if _redType == "0"{imgName = "btn_hongbao_girl"}  //女性专属
            if _redType == "1"{imgName = "btn_hongbao_boy"}   //男性专属
            if _redType == "2"{imgName = "btn_hongbao_all"}   //所有人都可领
            if _redType == "3"{imgName = "btn_hongbao_qiangguo"}  //已经领过了
            if _redType == "4"{imgName = "btn_hongbao_qiangguo"}  //过期
            if _redType == "5"{imgName = "btn_hongbao_qiangguo"} //抢光了
            if _redType == "null"{self.redPacketBtn.isHidden = true }   //没有红包
            self.redPacketBtn.setImage(UIImage.init(named: imgName), for: .normal)
        }else{
          self.redPacketBtn.isHidden = true //没有红包
        }
        self.trendsBottomToolsContainView.configWith(model: model)
    }
    
    @objc func dealCatchRedPacket(){
        if let _catchRedPacketBlock = self.catchRedPacketBlock{
            _catchRedPacketBlock()
        }
    }
    
    @objc func dealCatchedRedPacket(notification:Notification){
        if let userInfo = notification.userInfo{
            if let trendModel = userInfo[TREND_MODEL_KEY] as? TrendModel{
                if self.model?.action_id == trendModel.action_id && self.model?.red_token == trendModel.red_token{
                    self.model?.red_type = trendModel.red_type
                    self.configWith(model: self.model)
                }
            }
        }
    }
    
    @objc func dealThumbsUp(notification:Notification){
        if let userInfo = notification.userInfo{
            if let trendModel = userInfo[TREND_MODEL_KEY] as? TrendModel{
                if self.model?.action_id == trendModel.action_id{
                    if self.model?.topic_action_id == trendModel.topic_action_id{
                        self.model?.is_click = trendModel.is_click
                        self.model?.click_num = trendModel.click_num
                        self.configWith(model: self.model)
                    }
                }
            }
        }
    }
}
