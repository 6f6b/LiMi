//
//  VideoInChallengeCollectionCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/3.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class VideoInChallengeCollectionCell: UICollectionViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    var videoTrendModel:VideoTrendModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configWith(model:VideoTrendModel?){
        self.videoTrendModel = model
        if let _coverImage = videoTrendModel?.video?.cover{
            self.coverImageView.kf.setImage(with: URL.init(string: _coverImage))
        }
    }
    
}
