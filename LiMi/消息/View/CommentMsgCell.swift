//
//  CommentMsgCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/26.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class CommentMsgCell: UITableViewCell {
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentContent: UILabel!
    @IBOutlet weak var videoPreviewImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func configWith(model:ThumbUpAndCommentMessageModel){
        if let _headPic = model.head_pic{
            self.headImageView.kf.setImage(with: URL.init(string: _headPic))
        }
        self.userName.text = model.nickname
        self.timeLabel.text = model.time
        self.commentContent.text = model.msg
        if let _videoPreImage = model.img{
            self.videoPreviewImageView.kf.setImage(with: URL.init(string: _videoPreImage))
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
