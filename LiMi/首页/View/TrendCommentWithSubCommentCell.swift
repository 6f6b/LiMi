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
            make.height.equalTo(200)
        }
        
        self.subCommentTableView = UITableView()
        self.subCommentTableView.delegate = self
        self.subCommentTableView.dataSource = self
        self.subCommentTableView.register(SubCommentCell.self, forCellReuseIdentifier: "SubCommentCell")
        self.subCommentTableView.register(CheckMoreSubCommentCell.self, forCellReuseIdentifier: "CheckMoreSubCommentCell")

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension TrendCommentWithSubCommentCell:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }
        if section == 1{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
