//
//  TrendsCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SnapKit

class TrendsCell: UITableViewCell {
    var trendsContainView:UIView!   //最底层容器
    /******************顶部工具栏******************/
    var trendsTopToolsContainView:TrendsTopToolsContainView!    //顶部工具栏容器
    /******************发布内容区域******************/
    var trendsContentContainView:UIView!
     /******************底部工具栏******************/
    var trendsBottomToolsContainView:TrendsBottomToolsContainView!    //底部工具容器
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
//        self.trendsTopToolsContainView.backgroundColor = UIColor.orange
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
        
        self.trendsBottomToolsContainView = TrendsBottomToolsContainView()
//        self.trendsBottomToolsContainView.backgroundColor = UIColor.yellow
        self.trendsContainView.addSubview(self.trendsBottomToolsContainView)
        self.trendsBottomToolsContainView.tapThumbUpBtnBlock = {
            print("点击了点赞")
        }
        self.trendsBottomToolsContainView.tapCommentBtnBlock = {
            print("点击了评论")
        }
        self.trendsBottomToolsContainView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.trendsContainView)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.height.equalTo(46)
        }
        
        self.trendsContentContainView = UIView()
//        self.trendsContentContainView.backgroundColor = UIColor.green
        self.trendsContainView.addSubview(self.trendsContentContainView)
        self.trendsContentContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsTopToolsContainView.snp.bottom)
            make.left.equalTo(self.trendsContainView).offset(12)
            make.bottom.equalTo(self.trendsBottomToolsContainView.snp.top)
            make.right.equalTo(self.trendsContainView).offset(-12)
        }
        
        self.redPacketBtn = UIButton()
        self.redPacketBtn.setImage(UIImage.init(named: "btn_hongbao_1"), for: .normal)
        self.redPacketBtn.addTarget(self, action: #selector(dealCatchRedPacket), for: .touchUpInside)
        self.redPacketBtn.sizeToFit()
        self.trendsContainView.addSubview(redPacketBtn)
        self.redPacketBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.trendsBottomToolsContainView.snp.top).offset(-5)
            make.right.equalTo(self.trendsContainView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @objc func dealCatchRedPacket(){
        if let _catchRedPacketBlock = self.catchRedPacketBlock{
            _catchRedPacketBlock()
        }
    }
}
