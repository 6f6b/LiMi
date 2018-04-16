//
//  SystemMsgWithThumUpOrCommentsCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/5.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SystemMsgWithThumUpOrCommentsCell: UITableViewCell {
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var sexImg: UIImageView!
    @IBOutlet weak var contentText: UILabel!
    @IBOutlet weak var trendsImg: UIImageView!
    @IBOutlet weak var trendsContentText: UILabel!
    var tapHeadImgBlock:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.headImage.layer.cornerRadius = 20
        self.headImage.clipsToBounds = true
        
        self.headImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dealTapHeadImg))
        self.headImage.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func dealTapHeadImg(){
        if let _tapBlock = self.tapHeadImgBlock{
            _tapBlock()
        }
    }
    
    func configWith(model:ThumbUpAndCommentMessageModel?){
        if let _headPic = model?.head_pic{
            self.headImage.kf.setImage(with: URL.init(string: _headPic))
        }
        self.userName.text = model?.nickname
        self.time.text = model?.time
        if model?.sex == "0"{
            self.sexImg.image = UIImage.init(named: "ic_girl")
        }else{
            self.sexImg.image = UIImage.init(named: "ic_boy")
        }
        self.contentText.text = model?.msg
        if let _trendsImg = model?.img{
            self.trendsImg.kf.setImage(with: URL.init(string: _trendsImg))
        }
        self.trendsContentText.text = model?.text
    }
}
