//
//  TrendCommentWithSubCommentCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/17.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TrendCommentWithSubCommentCell: TrendCommentCell {
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
            make.right.equalTo(self.commentContentContainView)
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
        self.subCommentTableView.separatorStyle = .none
        self.subCommentTableView.delegate = self
        self.subCommentTableView.dataSource = self
        self.subCommentTableView.estimatedRowHeight = 100
        self.subCommentTableView.register(SubCommentCell.self, forCellReuseIdentifier: "SubCommentCell")
        self.subCommentTableView.register(CheckMoreSubCommentCell.self, forCellReuseIdentifier: "CheckMoreSubCommentCell")
        self.subCommentContainView.addSubview(self.subCommentTableView)
        self.subCommentTableView.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.subCommentContainView).offset(15)
            make.bottom.equalTo(self.subCommentContainView).offset(-15)
            make.left.equalTo(self.subCommentContainView).offset(15)
            make.right.equalTo(self.subCommentContainView).offset(-15)

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - misc
    override func configWith(model: CommentModel?) {
        super.configWith(model: model)
        self.subCommentTableView.reloadData()
        let delayTime:TimeInterval = 0.001
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delayTime, execute: {
            let tableViewHeight = self.subCommentTableView.contentSize.height
            self.subCommentTableView.snp.remakeConstraints {[unowned self] (make) in
                make.top.equalTo(self.subCommentContainView).offset(15)
                make.bottom.equalTo(self.subCommentContainView).offset(-15)
                make.left.equalTo(self.subCommentContainView).offset(15)
                make.right.equalTo(self.subCommentContainView).offset(-15)
                make.height.equalTo(tableViewHeight)
            }
        })
    }

}

extension TrendCommentWithSubCommentCell:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let count = self.commentModel?.child?.count{
            if count > 2{return 2}
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if let count = self.commentModel?.child?.count{
                return count > 2 ? 2 :count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let subCommentModel = self.commentModel?.child![indexPath.row]
            let subCommentCell = tableView.dequeueReusableCell(withIdentifier: "SubCommentCell", for: indexPath) as! SubCommentCell
            subCommentCell.configWith(model: subCommentModel)
            return subCommentCell
        }
        if indexPath.section == 1{
            let checkMoreSubCommentCell = tableView.dequeueReusableCell(withIdentifier: "CheckMoreSubCommentCell", for: indexPath)
            return checkMoreSubCommentCell
        }
        return UITableViewCell()
    }
}
