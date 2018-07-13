
//
//  MusicInfoInCollectionViewCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/9.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol MusicInfoInCollectionViewCellDelegate:NSObjectProtocol {
    func musicInfoInCollectionViewCell(palyerButtonClicked playerButton:UIButton)
}

class MusicInfoInCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gradualChangeView: UIView!
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var musicDownNum: UILabel!
    
    @IBOutlet weak var musicCoverImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    weak var delegate:MusicInfoInCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [RGBA(r: 114, g: 0, b: 218, a: 1).cgColor,RGBA(r: 255, g: 90, b: 0, a: 0).cgColor]
//        gradientLayer.startPoint = CGPoint.init(x: 0, y: 1)
//        gradientLayer.endPoint = CGPoint.init(x: 0, y: 0)
//        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 190)
//        self.bottomMaskView.layer.addSublayer(gradientLayer)
    }

    @IBAction func clickedPlayButton(_ sender: Any) {
        self.delegate?.musicInfoInCollectionViewCell(palyerButtonClicked: self.playButton)
    }
    
    func configWith(model:MusicModel?,playStatus:PlayerStatus){
        let isSelected = playStatus == .playing ? true: false
        self.playButton.isSelected = isSelected
        if let musicPic = model?.pic{
            self.musicCoverImageView.kf.setImage(with: URL.init(string: musicPic))
        }
        self.musicName.text = model?.name
        if let _downNum = model?.down_num{
            self.musicDownNum.text = "- \(_downNum)人使用 -"
        }
    }
}
