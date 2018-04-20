//
//  CheckMoreSubCommentCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/17.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class CheckMoreSubCommentCell: UITableViewCell {
    var commentNumInfo:UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.backgroundColor = RGBA(r: 250, g: 250, b: 250, a: 1)
        
        self.commentNumInfo = UILabel()
        //self.commentNumInfo.backgroundColor = UIColor.orange
        self.commentNumInfo.textColor = APP_THEME_COLOR
        self.commentNumInfo.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(self.commentNumInfo)
        self.commentNumInfo.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
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
    
    func configWith(num:Int?){
        if let _num = num{
            self.commentNumInfo.text = "查看\(_num)条回复"
        }
    }

}
