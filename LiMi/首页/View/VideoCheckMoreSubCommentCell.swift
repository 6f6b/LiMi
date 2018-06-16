//
//  VideoCheckMoreSubCommentCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/6.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class VideoCheckMoreSubCommentCell: UITableViewCell {
    var commentNumInfo:UILabel!
    var spreadImageView:UIImageView!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
        
        self.commentNumInfo = UILabel()
        //self.commentNumInfo.backgroundColor = UIColor.orange
        self.commentNumInfo.textColor = RGBA(r: 114, g: 114, b: 114, a: 1)
        self.commentNumInfo.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(self.commentNumInfo)
        self.commentNumInfo.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            
        }
        
        self.spreadImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 11, height: 11))
        self.spreadImageView.backgroundColor = UIColor.red
        self.spreadImageView.image = UIImage.init(named: "pl_xiala")
        self.contentView.addSubview(self.spreadImageView)
        self.spreadImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.commentNumInfo)
            make.left.equalTo(self.commentNumInfo.snp.right).offset(9)
            make.height.equalTo(11)
            make.width.equalTo(11)
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
    
    func configWith(num:Int?,isSpread:Bool){
        if isSpread{
            self.commentNumInfo.text = "收起"
        }else{
            if let _num = num{
                self.commentNumInfo.text = "查看\(_num)条回复"
            }
        }
        
    }
    
}
