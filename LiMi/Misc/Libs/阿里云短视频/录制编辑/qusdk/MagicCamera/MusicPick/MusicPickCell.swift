//
//  MusicPickCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/28.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class MusicPickCell: UICollectionViewCell {
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var zantingImageView: UIImageView!
    
    @IBOutlet weak var musicLength: UILabel!
    @IBOutlet weak var musicImageView: UIImageView!
    var musicModel:MusicModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.musicLength.layer.cornerRadius = 6
        self.musicLength.clipsToBounds = true;
        
    }

    func configWith(musicModel:MusicModel?,pauseImageHidden:Bool = true){
        self.zantingImageView.isHidden = pauseImageHidden;
        self.musicModel = musicModel;
        self.musicImageView.setImageWith(imageURL: musicModel?.pic, placeholder: nil);
        self.musicName.text = musicModel?.name;
        if let duration = musicModel?.duration{
            self.musicLength.text = self.timeFormatted(totalSeconds: Int(duration))
        }
    }
    
    func timeFormatted(totalSeconds:Int)->String{
        let seconds = totalSeconds%60
        let minutes = (totalSeconds/60)%60
        let time = String.init(format: "%2d:%2d", minutes,seconds)
        return time
    }

}
