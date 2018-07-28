//
//  TopMsgContainView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/26.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol TopMsgContainViewDelegate : class{
    func topMsgContainView(containView:TopMsgContainView,clickedNewFansButton:UIButton)
    func topMsgContainView(containView:TopMsgContainView,clickedClickLikeButton:UIButton)
    func topMsgContainView(containView:TopMsgContainView,clickedCommentButton:UIButton)
    func topMsgContainView(containView:TopMsgContainView,clickedRemindButton:UIButton)
}

class TopMsgContainView: UIView {
    weak var delegate:TopMsgContainViewDelegate?
    //粉丝
    var newFansButton:UIButton!
    var newFansMsgNumLabel:UILabel!
    
    //点赞
    var clickLikeButton:UIButton!
    var clickLikeMsgNumLabel:UILabel!
    
    //评论
    var commentButton:UIButton!
    var commentMsgNumLabel:UILabel!
    
    //@
    var remindButton:UIButton!
    var remindMsgNumLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let marginDistance = CGFloat(15)
        let spacing = (SCREEN_WIDTH-marginDistance*2-50*4)/3
        
        newFansButton = creatButtonWith(frame: CGRect.init(x: marginDistance, y: 10, width: 50, height: 77), image: "xx_ic_fensi", title: "粉丝")
        newFansButton.addTarget(self, action: #selector(clickedNewFansButton), for: .touchUpInside)
        newFansMsgNumLabel = creatLabelWith(button: newFansButton)
        
        clickLikeButton = creatButtonWith(frame: CGRect.init(x: newFansButton.frame.maxX+spacing, y: 10, width: 50, height: 77), image: "xx_ic_dianzan", title: "点赞")
        clickLikeButton.addTarget(self, action: #selector(clickedClickLikeButton), for: .touchUpInside)
        clickLikeMsgNumLabel = creatLabelWith(button: clickLikeButton)
        
        commentButton = creatButtonWith(frame: CGRect.init(x: clickLikeButton.frame.maxX+spacing, y: 10, width: 50, height: 77), image: "xx_ic_pinglun", title: "评论")
        commentButton.addTarget(self, action: #selector(clickedCommentButton), for: .touchUpInside)
        commentMsgNumLabel = creatLabelWith(button: commentButton)
        
        remindButton = creatButtonWith(frame: CGRect.init(x: commentButton.frame.maxX+spacing, y: 10, width: 50, height: 77), image: "xx_ic_@me", title: "@我")
        remindButton.addTarget(self, action: #selector(clickedRemindButton), for: .touchUpInside)
        remindMsgNumLabel = creatLabelWith(button: remindButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(customMessageUnreadCountChanged), name: customSystemMessageUnreadCountChanged, object: nil)
        self.refreshMsgNum()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func refreshMsgNum(){
        self.newFansMsgNumLabel.isHidden = AppManager.shared.customSystemMessageManager.customSystemMessageUnreadCount(type: .fans) == 0 ? true : false
        self.newFansMsgNumLabel.text = "\(AppManager.shared.customSystemMessageManager.customSystemMessageUnreadCount(type: .fans))"
        
        self.clickLikeMsgNumLabel.isHidden = AppManager.shared.customSystemMessageManager.customSystemMessageUnreadCount(type: .thumbUp) == 0 ? true : false
        self.clickLikeMsgNumLabel.text = "\(AppManager.shared.customSystemMessageManager.customSystemMessageUnreadCount(type: .thumbUp))"
        
        self.commentMsgNumLabel.isHidden = AppManager.shared.customSystemMessageManager.customSystemMessageUnreadCount(type: .comment) == 0 ? true : false
        self.commentMsgNumLabel.text = "\(AppManager.shared.customSystemMessageManager.customSystemMessageUnreadCount(type: .comment))"
        
        self.remindMsgNumLabel.isHidden = AppManager.shared.customSystemMessageManager.customSystemMessageUnreadCount(type: .remind) == 0 ? true : false
        self.remindMsgNumLabel.text = "\(AppManager.shared.customSystemMessageManager.customSystemMessageUnreadCount(type: .remind))"
    }
    
    @objc func customMessageUnreadCountChanged(){
        self.refreshMsgNum()
    }
    
    func creatButtonWith(frame:CGRect,image:String,title:String)->UIButton{
        let button = UIButton.init(frame: frame)
        button.setImage(UIImage.init(named: image), for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.sizeToFitTitleBelowImageWith(distance: 12)
        self.addSubview(button)
        return button
    }
    
    func creatLabelWith(button:UIButton)->UILabel{
        let label = UILabel.init(frame: CGRect.init(x: button.frame.maxX-18, y: button.frame.minY, width: 18, height: 18))
        label.backgroundColor = UIColor.red
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        self.addSubview(label)
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - actions
    @objc func clickedNewFansButton(){
        self.delegate?.topMsgContainView(containView: self, clickedNewFansButton: self.newFansButton)
        AppManager.shared.customSystemMessageManager.markCustomSystemMessageRead(type: .fans)
    }
    @objc func clickedClickLikeButton(){
        self.delegate?.topMsgContainView(containView: self, clickedClickLikeButton: self.clickLikeButton)
        AppManager.shared.customSystemMessageManager.markCustomSystemMessageRead(type: .thumbUp)
    }
    @objc func clickedCommentButton(){
        self.delegate?.topMsgContainView(containView: self, clickedCommentButton: self.commentButton)
        AppManager.shared.customSystemMessageManager.markCustomSystemMessageRead(type: .comment)

    }
    @objc func clickedRemindButton(){
        self.delegate?.topMsgContainView(containView: self, clickedRemindButton: self.remindButton)
        AppManager.shared.customSystemMessageManager.markCustomSystemMessageRead(type: .remind)

    }
}
