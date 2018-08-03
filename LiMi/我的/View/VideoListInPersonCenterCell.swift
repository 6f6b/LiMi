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
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var firstPulishLabel: UILabel!
    
    var model:VideoTrendModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.videoCoverImage.clipsToBounds = true
    }
    
    func configWith(model:VideoTrendModel,indexPath:IndexPath? = nil){
        self.model = model
        if let _indexPath = indexPath{
            self.rankImageView.isHidden = _indexPath.row < 3 ? false : true
            if indexPath?.row == 0{
                self.rankImageView.image = UIImage.init(named: "pstk_ic_first")
            }
            if indexPath?.row == 1{
                self.rankImageView.image = UIImage.init(named: "pstk_ic_second")
            }
            if indexPath?.row == 2{
                self.rankImageView.image = UIImage.init(named: "pstk_ic_third")
            }
        }else{
            self.rankImageView.isHidden = true
        }
        if let coverImage = model.video?.cover{
            self.videoCoverImage.kf.setImage(with: URL.init(string: coverImage), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }else{
            self.videoCoverImage.image = nil
        }
        self.clickNumLabel.text = model.click_num?.suitableStringValue()
        self.firstPulishLabel.isHidden = model.is_first == true ? false : true
    }

}
