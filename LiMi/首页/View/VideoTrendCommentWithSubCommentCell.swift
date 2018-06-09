//
//  VideoTrendCommentWithSubCommentCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/6.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
///子评论区域最大显示条数
//let maxSubCommentsNum = 3
class VideoTrendCommentWithSubCommentCell: VideoTrendCommentCell {
    ///子评论容器
    var subCommentContainView:UIView!
    ///子评论列表
    var subCommentTableView:UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.comment.snp.remakeConstraints {[unowned self] (make) in
            make.top.equalTo(self.commentContentContainView)
            make.left.equalTo(self.commentContentContainView)
            make.right.lessThanOrEqualTo(self.commentContainView)
            //make.right.equalTo(self.commentContentContainView)
        }
        
        self.subCommentContainView = UIView.init()
        self.subCommentContainView.backgroundColor = RGBA(r: 250, g: 250, b: 250, a: 1)
        self.subCommentContainView.layer.cornerRadius = 5
        self.subCommentContainView.clipsToBounds = true
        self.commentContentContainView.addSubview(self.subCommentContainView)
        self.subCommentContainView.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.comment.snp.bottom).offset(15)
            make.left.equalTo(self.commentContentContainView)
            make.bottom.equalTo(self.commentContentContainView)
            make.right.equalTo(self.commentContentContainView)
        }
        
        self.subCommentTableView = UITableView()
        //self.subCommentTableView.estimatedRowHeight = 100
        self.subCommentTableView.backgroundColor = self.subCommentContainView.backgroundColor
        self.subCommentTableView.isScrollEnabled = false
        self.subCommentTableView.separatorStyle = .none
        self.subCommentTableView.delegate = self
        self.subCommentTableView.dataSource = self
        self.subCommentTableView.register(VideoSubCommentCell.self, forCellReuseIdentifier: "VideoSubCommentCell")
        self.subCommentTableView.register(VideoCheckMoreSubCommentCell.self, forCellReuseIdentifier: "VideoCheckMoreSubCommentCell")
        self.subCommentContainView.addSubview(self.subCommentTableView)
        self.subCommentTableView.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.subCommentContainView).offset(15)
            make.bottom.equalTo(self.subCommentContainView).offset(-15)
            make.left.equalTo(self.subCommentContainView).offset(15)
            make.right.equalTo(self.subCommentContainView).offset(-15)
        }
        self.subCommentTableView.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
        self.subCommentContainView.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    //MARK: - misc
    override func configWith(model: CommentModel?, isForSubComment: Bool) {
        super.configWith(model: model)
        self.subCommentTableView.reloadData()
        let tableViewHeight = self.tableViewHeightWith(model: model)
        //        let tableViewHeight = self.subCommentTableView.contentSize.height
        self.subCommentTableView.snp.remakeConstraints {[unowned self] (make) in
            make.top.equalTo(self.subCommentContainView).offset(15)
            make.bottom.equalTo(self.subCommentContainView).offset(-15)
            make.left.equalTo(self.subCommentContainView).offset(15)
            make.right.equalTo(self.subCommentContainView).offset(-15)
            print(tableViewHeight)
            make.height.equalTo(tableViewHeight)
        }
    }
    
    ////根据评论模型计算tableview高度
    func tableViewHeightWith(model:CommentModel?)->CGFloat{
        var tableViewHeight:CGFloat = 0.0
        let limitWidth = SCREEN_WIDTH-62-30-12
        if let childs = model?.child,let childNum = model?.child_num{
            if childNum > maxSubCommentsNum{
                for i in 0..<maxSubCommentsNum{
                    if let _str = self.subCommentTextWith(model: childs[i]){
                        let size = _str.sizeWith(limitWidth: limitWidth, font: 15)
                        tableViewHeight += size.height
                        tableViewHeight += 10
                    }
                }
                tableViewHeight += "LIMI".sizeWith(limitWidth: limitWidth, font: 15).height
            }
            if childNum <= maxSubCommentsNum{
                for child in childs{
                    if let _str = self.subCommentTextWith(model: child){
                        let size = _str.sizeWith(limitWidth: limitWidth, font: 15)
                        tableViewHeight += size.height
                        tableViewHeight += 10
                    }
                }
            }
        }
        return tableViewHeight
    }
}

extension VideoTrendCommentWithSubCommentCell:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let count = self.commentModel?.child_num{
            if count > maxSubCommentsNum{return 2}
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if let count = self.commentModel?.child_num{
                return count > maxSubCommentsNum ? maxSubCommentsNum :count
            }
        }
        if section == 1{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if let childs = self.commentModel?.child{
                if let str = self.subCommentTextWith(model: childs[indexPath.row]){
                    let size = str.sizeWith(limitWidth: (SCREEN_WIDTH-62-30-12), font: 15)
                    return size.height + 10
                }
            }
        }
        if indexPath.section == 1{
            return "limi".sizeWith(limitWidth: 100, font: 15).height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let subCommentModel = self.commentModel?.child![indexPath.row]
            let subCommentCell = tableView.dequeueReusableCell(withIdentifier: "VideoSubCommentCell", for: indexPath) as! VideoSubCommentCell
            subCommentCell.configWith(model: subCommentModel)
            return subCommentCell
        }
        if indexPath.section == 1{
            let checkMoreSubCommentCell = tableView.dequeueReusableCell(withIdentifier: "VideoCheckMoreSubCommentCell", for: indexPath) as! VideoCheckMoreSubCommentCell
            checkMoreSubCommentCell.configWith(num: self.commentModel?.child_num)
            return checkMoreSubCommentCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: CHECK_MORE_SUB_COMMENT_NOTIFICATION, object: nil, userInfo: [COMMENT_MODEL_KEY:self.commentModel])
    }
    
    func subCommentTextWith(model:SubCommentModel?)->String?{
        if let commentContent = model?.content,let commentPersonName = model?.nickname,let beCommentedPersonName = model?.parent_name{
            //单纯评论
            if model?.parent_id == model?.group_id{
                //冒号
                let colon = ":"
                return commentPersonName + ":" + commentContent
            }
            //回复
            if model?.parent_id != model?.group_id{
                //回复 @ person ：
                let reply = "  回复 @ \(beCommentedPersonName) :"
                return commentPersonName + reply + commentContent
            }
        }
        return nil
    }
}
