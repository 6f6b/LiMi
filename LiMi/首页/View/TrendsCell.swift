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
let singlePictureHeightAndWidthRatio = CGFloat(0.8)

///多张图片的水平间距和垂直间距
let multiPictureSpacing = CGFloat(1.0)

///多张图片时图片高宽比
let multiPictureHeightAndWidthRatio = CGFloat(1.0)

///多媒体容器到屏幕边缘的距离
let mediaContainViewMarginToWindow = CGFloat(0.0)

///文字内容区域到屏幕边缘的距离
let textAreaMarginToWindow = CGFloat(12.0)

///动态内容区域到底部工具栏距离
let trendsContainViewSpacingToBottomToolsView = CGFloat(10.0)

class TrendsCell: UITableViewCell {
    var model:TrendModel?
    weak var tableView:UITableView?
    var indexPath:IndexPath?
    var cellStyle:TrendsCellStyle = .normal
    
    var trendsBottomToolsContainViewBottomDividerHeightConstraint:Constraint?
    /************************部分变量****************************/
    ///容器到屏幕两边的距离
    var trendsContainViewMarginToWindow = CGFloat(0)
    ///内容区域到容器的两边距离
    var trendsContentContainViewMarginToTrendsContainView = CGFloat(0)
    ///顶部工具栏到容器两边的距离
    var topToolsContainViewMarginToTrendsContainView = CGFloat(0)
    ///底部工具栏到容器两边的距离
    var bottomToolsContainViewMarginToTrendsContainView = CGFloat(0)
    /****************************************************/

    ///最底层容器上分隔带
    var trendsContainViewTopDivider:UIView!
    
    ///最底层容器
    var trendsContainView:UIView!   //最底层容器
    
    ///最底层容器下分隔带
    var trendsContainViewBottomDivider:UIView!
    
    /****************************************************/
    
    /// 顶部工具栏上分隔带
    var trendsTopToolsContainViewTopDivider:UIView!
    
    /// 顶部工具栏容器
    var trendsTopToolsContainView:TrendsTopToolsContainView!    //顶部工具栏容器
    
    ///顶部工具栏下分隔带
    var trendsTopToolsContainViewBottomDivider:UIView!
    
    /****************************************************/
    
    /// 发布内容区域
    var trendsContentContainView:UIView!
    
    /****************************************************/
    
    ///底部工具栏上分隔带
    var trendsBottomToolsContainViewTopDivider:UIView!
    
    /// 底部工具栏容器
    var trendsBottomToolsContainView:TrendsBottomToolsContainView!    //底部工具容器
    
    ///底部工具栏下分隔带
    var trendsBottomToolsContainViewBottomDivider:UIView!
    
    ///底部灰色分隔bar
    var grayBar:UIView!
    
    var redPacketBtn:UIButton!
    var  catchRedPacketBlock:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.backgroundColor = UIColor.groupTableViewBackground
        
        self.trendsContainViewTopDivider = UIView()
        self.contentView.addSubview(self.trendsContainViewTopDivider)
        self.trendsContainViewTopDivider.snp.makeConstraints { [unowned self] (make) in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(0)
        }
        
        self.trendsContainView = UIView()
        self.trendsContainView.backgroundColor = UIColor.white
        self.contentView.addSubview(trendsContainView)
        self.trendsContainView.snp.makeConstraints {[unowned self]  (make) in
            make.top.equalTo(self.trendsContainViewTopDivider.snp.bottom)
            make.left.equalTo(self.contentView).offset(self.trendsContainViewMarginToWindow)
            //make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-self.trendsContainViewMarginToWindow)

        }
        
        self.trendsContainViewBottomDivider = UIView()
        self.contentView.addSubview(self.trendsContainViewBottomDivider)
        self.trendsContainViewBottomDivider.snp.makeConstraints {[unowned self]   (make) in
            make.top.equalTo(self.trendsContainView.snp.bottom)
            make.left.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(0)
        }
        
        self.trendsTopToolsContainViewTopDivider = UIView()
        self.trendsContainView.addSubview(self.trendsTopToolsContainViewTopDivider)
        self.trendsTopToolsContainViewTopDivider.snp.makeConstraints {[unowned self]    (make) in
            make.top.equalTo(self.trendsContainView)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.height.equalTo(0)
        }
        
        self.trendsTopToolsContainView = TrendsTopToolsContainView()
        self.trendsContainView.addSubview(self.trendsTopToolsContainView)
        self.trendsTopToolsContainView.tapHeadBtnBlock = {
            print("点击了头像")
        }
        self.trendsTopToolsContainView.tapMoreOperationBtnBlock = {btn in
            print("点击了更多")
        }
        self.trendsTopToolsContainView.snp.makeConstraints {[unowned self]    (make) in
            make.top.equalTo(self.self.trendsTopToolsContainViewTopDivider.snp.bottom)
            make.left.equalTo(self.trendsContainView).offset(self.topToolsContainViewMarginToTrendsContainView)
            make.right.equalTo(self.trendsContainView).offset(-self.topToolsContainViewMarginToTrendsContainView)
        }
        
        self.trendsTopToolsContainViewBottomDivider = UIView()
        self.trendsContainView.addSubview(self.trendsTopToolsContainViewBottomDivider)
        self.trendsTopToolsContainViewBottomDivider.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsTopToolsContainView.snp.bottom)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.height.equalTo(0)
        }
        
        self.grayBar = UIView()
        self.trendsContainView.addSubview(self.grayBar)
        self.grayBar.backgroundColor = UIColor.groupTableViewBackground
        self.grayBar.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.trendsContainView)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.height.equalTo(0)
        }
        
        self.trendsContentContainView = UIView()
        //        self.trendsContentContainView.backgroundColor = UIColor.green
        self.trendsContainView.addSubview(self.trendsContentContainView)
        self.trendsContentContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsTopToolsContainViewBottomDivider.snp.bottom)
            make.left.equalTo(self.trendsContainView).offset(self.trendsContentContainViewMarginToTrendsContainView)
            make.right.equalTo(self.trendsContainView).offset(-self.trendsContentContainViewMarginToTrendsContainView)
        }
        
        self.trendsBottomToolsContainViewTopDivider = UIView()
        self.trendsContainView.addSubview(self.trendsBottomToolsContainViewTopDivider)
        self.trendsBottomToolsContainViewTopDivider.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsContentContainView.snp.bottom)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.height.equalTo(0)
        }
        
        self.trendsBottomToolsContainView = TrendsBottomToolsContainView()
        self.trendsContainView.addSubview(self.trendsBottomToolsContainView)
        self.trendsBottomToolsContainView.tapCommentBtnBlock = {
            print("点击了评论")
        }
        self.trendsBottomToolsContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsBottomToolsContainViewTopDivider.snp.bottom)
            make.left.equalTo(self.trendsContainView).offset(self.bottomToolsContainViewMarginToTrendsContainView)
            make.right.equalTo(self.trendsContainView).offset(-self.bottomToolsContainViewMarginToTrendsContainView)
        }
        
        self.trendsBottomToolsContainViewBottomDivider = UIView()
        self.trendsBottomToolsContainViewBottomDivider.backgroundColor = UIColor.groupTableViewBackground
        self.trendsContainView.addSubview(self.trendsBottomToolsContainViewBottomDivider)
        self.trendsBottomToolsContainViewBottomDivider.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsBottomToolsContainView.snp.bottom)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.bottom.equalTo(self.trendsContainView)
            self.trendsBottomToolsContainViewBottomDividerHeightConstraint = make.height.equalTo(7).constraint
        }
        
        
        self.redPacketBtn = UIButton()
        self.redPacketBtn.isHidden = true
        self.redPacketBtn.setImage(UIImage.init(named: "hb_ic_pin"), for: .normal)
        self.redPacketBtn.addTarget(self, action: #selector(dealCatchRedPacket), for: .touchUpInside)
        self.redPacketBtn.sizeToFit()
        self.trendsContainView.addSubview(redPacketBtn)
        self.redPacketBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.trendsBottomToolsContainView).offset(-5)
            make.right.equalTo(self.trendsContainView).offset(-40)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealCatchedRedPacket(notification:)), name: CATCHED_RED_PACKET_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealThumbsUp(notification:)), name: THUMBS_UP_NOTIFICATION, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: CATCHED_RED_PACKET_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: THUMBS_UP_NOTIFICATION, object: nil)
        print("TrendsCell销毁")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    //MARK: - misc
    ///对约束进行更新
    func refreshUI(){
        self.trendsContainView.snp.remakeConstraints {[unowned self]  (make) in
            make.top.equalTo(self.trendsContainViewTopDivider.snp.bottom)
            make.left.equalTo(self.contentView).offset(self.trendsContainViewMarginToWindow)
            //make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-self.trendsContainViewMarginToWindow)
        }
        
        self.trendsTopToolsContainView.snp.remakeConstraints {[unowned self]    (make) in
            make.top.equalTo(self.self.trendsTopToolsContainViewTopDivider.snp.bottom)
            make.left.equalTo(self.trendsContainView).offset(self.topToolsContainViewMarginToTrendsContainView)
            make.right.equalTo(self.trendsContainView).offset(-self.topToolsContainViewMarginToTrendsContainView)
        }

        self.trendsContentContainView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.trendsTopToolsContainViewBottomDivider.snp.bottom)
            make.left.equalTo(self.trendsContainView).offset(self.trendsContentContainViewMarginToTrendsContainView)
            make.right.equalTo(self.trendsContainView).offset(-self.trendsContentContainViewMarginToTrendsContainView)
        }

        self.trendsBottomToolsContainView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.trendsBottomToolsContainViewTopDivider.snp.bottom)
            make.left.equalTo(self.trendsContainView).offset(self.bottomToolsContainViewMarginToTrendsContainView)
            make.right.equalTo(self.trendsContainView).offset(-self.bottomToolsContainViewMarginToTrendsContainView)
        }

    }
    
    func configWith(model:TrendModel?){
        self.model = model
        self.trendsTopToolsContainView.configWith(model: model,cellStyle: self.cellStyle)
        
        if self.cellStyle == .inCommentList{
            self.trendsBottomToolsContainViewBottomDividerHeightConstraint?.deactivate()
            self.trendsBottomToolsContainViewBottomDivider.snp.makeConstraints { (make) in
                make.height.equalTo(0)
            }
        }
        
        if let _redType = model?.red_type{
            self.redPacketBtn.isHidden = false
            var imgName = "hb_ic_pin"
            if _redType == "0"{imgName = "hb_ic_girl"}  //女性专属
            if _redType == "1"{imgName = "hb_ic_noy"}   //男性专属
            if _redType == "2"{imgName = "hb_ic_pin"}   //所有人都可领
            if _redType == "3"{imgName = "hb_ic_kong-1"}  //已经领过了
            if _redType == "4"{imgName = "hb_ic_kong"}  //过期
            if _redType == "5"{imgName = "hb_ic_kong"} //抢光了
            if _redType == "null"{self.redPacketBtn.isHidden = true }   //没有红包
            self.redPacketBtn.setImage(UIImage.init(named: imgName), for: .normal)
        }else{
          self.redPacketBtn.isHidden = true //没有红包
        }
        self.trendsBottomToolsContainView.configWith(model: model)
    }
    
    @objc func dealCatchRedPacket(){
        if !AppManager.shared.checkUserStatus(){return}
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
