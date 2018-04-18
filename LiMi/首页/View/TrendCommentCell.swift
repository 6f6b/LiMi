//
//  TrendCommentCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TrendCommentCell: UITableViewCell {
    ///最底层容器
    var commentContainView:UIView!
    
    /******************顶部工具栏******************/
    var commentTopToolsContainView:CommentTopToolsContainView!    //顶部工具栏容器
    
    /******************发布内容区域******************/
    var commentContentContainView:UIView!
    
    var comment:UILabel!    //内容
    var commentModel:CommentModel?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.commentContainView = UIView()
        //self.commentContainView.backgroundColor = UIColor.red
        self.contentView.addSubview(commentContainView)
        self.commentContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
        }
        
        self.commentTopToolsContainView = CommentTopToolsContainView()
        self.commentTopToolsContainView.moreOperationBtn.isHidden = true
        //self.commentTopToolsContainView.backgroundColor = UIColor.orange
        self.commentContainView.addSubview(self.commentTopToolsContainView)
        self.commentTopToolsContainView.tapHeadBtnBlock = {
            print("点击了头像")
        }
        self.commentTopToolsContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.commentContainView)
            make.left.equalTo(self.commentContainView)
            make.right.equalTo(self.commentContainView)
        }
        
        self.commentContentContainView = UIView()
        //self.commentContentContainView.backgroundColor = UIColor.green
        self.commentContainView.addSubview(self.commentContentContainView)
        self.commentContentContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.commentTopToolsContainView.snp.bottom)
            make.left.equalTo(self.commentContainView).offset(62)
            make.bottom.equalTo(self.commentContainView).offset(-15)
            make.right.equalTo(self.commentContainView).offset(-12)
        }
        
        self.comment = UILabel()
        self.comment.text = nil
        self.comment.font = UIFont.systemFont(ofSize: 14)
        self.comment.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
        self.comment.numberOfLines = 0
        self.comment.lineBreakMode = .byWordWrapping
        self.commentContentContainView.addSubview(self.comment)
        self.comment.snp.makeConstraints { (make) in
            make.top.equalTo(self.commentContentContainView)
            make.left.equalTo(self.commentContentContainView)
            make.bottom.equalTo(self.commentContentContainView)
            make.right.equalTo(self.commentContentContainView)
        }
        
        let separateLine = UIView()
        separateLine.backgroundColor = RGBA(r: 228, g: 228, b: 228, a: 1)
        self.commentContainView.addSubview(separateLine)
        separateLine.snp.makeConstraints { (make) in
            make.left.equalTo(self.commentContainView)
            make.bottom.equalTo(self.commentContainView)
            make.right.equalTo(self.commentContainView)
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - misc
    func configWith(model:CommentModel?){
        self.commentModel = model
        self.commentTopToolsContainView.configWith(commentModel: model)
        self.comment.text = model?.content
    }

}
