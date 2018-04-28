//
//  SubCommentCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/17.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import YYText

class SubCommentCell: UITableViewCell {
    var subCommentModel:SubCommentModel?
    var commentLabel:YYLabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = RGBA(r: 250, g: 250, b: 250, a: 1)
        
        self.commentLabel = YYLabel.init()
        //self.commentLabel.backgroundColor = UIColor.purple
        self.commentLabel.numberOfLines = 0
        self.commentLabel.lineBreakMode = .byCharWrapping
        self.commentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH-62-12-30
        self.commentLabel.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(self.commentLabel)
        self.commentLabel.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-10)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    //MARK: - misc
    
    //点击了user
    @objc func dealTapUser(){
        
    }
    //短点击评论
    @objc func dealTapComment(){
        
    }
    //长按评论
    @objc func dealLongPressComment(){
        
    }
    
    //配置
    func configWith(model:SubCommentModel?){
        self.subCommentModel = model
        if let commentContent = model?.content,let commentPersonName = model?.nickname,let beCommentedPersonName = model?.parent_name{
            //评论人名
            let attCommentPersonName = NSMutableAttributedString.init(string: commentPersonName)
            attCommentPersonName.yy_setAttributes([NSAttributedStringKey.font.rawValue:UIFont.systemFont(ofSize: 15)])
            let nsCommentPersonName = NSString.init(string: commentPersonName)
            let attCommentPersonNameRange = nsCommentPersonName.range(of: commentPersonName)
            attCommentPersonName.yy_setTextHighlight(attCommentPersonNameRange, color: APP_THEME_COLOR, backgroundColor: nil, userInfo: nil, tapAction: { (view, nsAttStr, range, rect) in
                NotificationCenter.default.post(name: TAPED_COMMENT_PERSON_NAME_NOTIFICATION, object: nil, userInfo: [COMMENT_MODEL_KEY:self.subCommentModel])
                print("短点击：\(nsAttStr)")
            }, longPressAction: { (view, nsAttStr, range, rect) in
                print("长按：\(nsAttStr)")
            })
            
            //评论内容
            let attCommentContent = NSMutableAttributedString.init(string: commentContent)
            attCommentContent.yy_setAttributes([NSAttributedStringKey.font.rawValue:UIFont.systemFont(ofSize: 15),NSAttributedStringKey.foregroundColor.rawValue:RGBA(r: 51, g: 51, b: 51, a: 51)])
//            let nsCommentContent = NSString.init(string: commentContent)
//            let attCommentContentRange = nsCommentContent.range(of: commentContent)
//            attCommentContent.yy_setTextHighlight(attCommentContentRange, color: RGBA(r: 51, g: 51, b: 51, a: 1), backgroundColor: nil, userInfo: nil, tapAction: { (view, nsAttStr, range, rect) in
//                NotificationCenter.default.post(name: TAPED_COMMENT_NOTIFICATION, object: nil, userInfo: [COMMENT_MODEL_KEY:self.subCommentModel])
//                print("短点击：\(nsAttStr)")
//            }, longPressAction: { (view, nsAttStr, range, rect) in
//                NotificationCenter.default.post(name: LONGPRESS_COMMENT_NOTIFICATION, object: nil, userInfo: [COMMENT_MODEL_KEY:self.subCommentModel])
//                print("长按：\(nsAttStr)")
//            })
            
            //单纯评论
            if model?.parent_id == model?.group_id{
                //冒号
                let attColon = NSMutableAttributedString.init(string: ":")
                attColon.yy_setAttributes([NSAttributedStringKey.font.rawValue:UIFont.systemFont(ofSize: 15),NSAttributedStringKey.foregroundColor.rawValue:RGBA(r: 51, g: 51, b: 51, a: 51)])
                
                attCommentPersonName.append(attColon)
                attCommentPersonName.append(attCommentContent)
                self.commentLabel.attributedText = attCommentPersonName
            }
            //回复
            if model?.parent_id != model?.group_id{
                //回复 @ person ：
                let assReplay = NSMutableAttributedString.init(string: "  回复 @ \(beCommentedPersonName) :")
                assReplay.yy_setAttributes([NSAttributedStringKey.font.rawValue:UIFont.systemFont(ofSize: 15),NSAttributedStringKey.foregroundColor.rawValue:RGBA(r: 51, g: 51, b: 51, a: 51)])
                
                attCommentPersonName.append(assReplay)
                attCommentPersonName.append(attCommentContent)
                self.commentLabel.attributedText = attCommentPersonName
            }
        }
    }
    
    
}
