//
//  VideoListInPersonCenterCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/7.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class VideoListInPersonCenterCell: UICollectionViewCell {
    @IBOutlet weak var videoCoverImage: UIImageView!
    @IBOutlet weak var clickNumLabel: UILabel!
    
    var model:VideoTrendModel?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configWith(model:VideoTrendModel){
        self.model = model
        if let coverImage = model.video_cover{
            self.videoCoverImage.kf.setImage(with: URL.init(string: coverImage), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }else{
            self.videoCoverImage.image = nil
        }
        self.clickNumLabel.text = model.click_num?.suitableStringValue()
    }

}
