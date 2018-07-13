//
//  VideoListCollectionViewCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class VideoListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var videoCoverImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userHeadButton: UIButton!
    @IBOutlet weak var publishTimeLabel: UILabel!
    
    var model:VideoTrendModel?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configWith(model:VideoTrendModel){
        self.model = model
        if let headPic = model.user?.head_pic{
            self.userHeadButton.kf.setImage(with: URL.init(string: headPic), for: .normal, placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }else{
            self.userHeadButton.setImage(UIImage.init(named: "touxiang"), for: .normal)
        }
        if let coverImage = model.video?.cover{
            self.videoCoverImageView.kf.setImage(with: URL.init(string: coverImage), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }else{
            self.videoCoverImageView.image = nil
        }
        self.userNameLabel.text = model.user?.nickname
        self.publishTimeLabel.text = model.video?.v_create_time
    }
}

