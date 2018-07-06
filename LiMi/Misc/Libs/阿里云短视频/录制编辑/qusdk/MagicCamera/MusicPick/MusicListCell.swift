//
//  MusicListCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol MusicListCellDelegate {
    func musicListCell(_ musicListCell:MusicListCell,indexPath:IndexPath,clickedPickMusicButton pickMusicButton:UIButton)
    func musicListCell(_ musicListCell:MusicListCell,indexPath:IndexPath,clickedCutButton cutButton:UIButton)
    func musicListCell(_ musicListCell:MusicListCell,indexPath:IndexPath,clickedCollectButton collectButton:UIButton)
    func musicListCell(_ musicListCell:MusicListCell,indexPath:IndexPath,clickedRankButton rankButton:UIButton)
}

class MusicListCell: UITableViewCell {
    @IBOutlet weak var musicPicture: UIImageView!
    @IBOutlet weak var pickMusicButton: UIButton!
    @IBOutlet weak var musicPlayStatus: UIImageView!
    @IBOutlet weak var rankButton: UIButton!
    @IBOutlet weak var collectButton: UIButton!
    @IBOutlet weak var cutButton: UIButton!
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var singerName: UILabel!
    @IBOutlet weak var musicTime: UILabel!
    
    var indexPath:IndexPath?
    var delegate:MusicListCellDelegate?
    var musicModel:MusicModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        let gradientLayer = CAGradientLayer()
        let alpha = CGFloat(1)
        gradientLayer.colors = [RGBA(r: 255, g: 90, b: 0, a: alpha).cgColor,RGBA(r: 144, g: 0, b: 218, a: alpha).cgColor]
        gradientLayer.locations = [0.0,1.0]
        gradientLayer.startPoint = CGPoint.init(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 0, y: 1)
        gradientLayer.frame = SCREEN_RECT
        self.pickMusicButton.layer.addSublayer(gradientLayer)
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configWith(model: MusicModel, indexPath: IndexPath,beSeleted:Bool,status:PlayerStatus?){
        self.musicModel = model
        self.indexPath = indexPath
        if beSeleted{
           print("展示选择按钮")
        }
        self.pickMusicButton.isHidden = !beSeleted
        self.musicPlayStatus.isHidden = !beSeleted
        var playStatusImage = "music_ic_zanting"
        if status == .pause{
            playStatusImage = "music_ic_bofang"
        }
        self.musicPlayStatus.image = UIImage.init(named: playStatusImage)

        if let _musicPic = model.pic{
            self.musicPicture.kf.setImage(with: URL.init(string: _musicPic))
        }
        self.musicName.text = model.name
        self.singerName.text = model.singer
        
        let secondes = model.time ?? 0
        let timeStr = String.init(format: "%02d:%02d", secondes/60,secondes%60)
        self.musicTime.text = timeStr
        
        self.collectButton.isSelected = model.is_collect!
    }
    
    //MARK: - actions
    @IBAction func clickedPickMusicButton(_ sender: Any) {
        let button = sender as! UIButton
        if let _indexPath = self.indexPath{
            self.delegate?.musicListCell(self, indexPath:_indexPath , clickedPickMusicButton: button)

        }
    }
    @IBAction func clickedCutButton(_ sender: Any) {
        let button = sender as! UIButton
        if let _indexPath = self.indexPath{
            self.delegate?.musicListCell(self, indexPath: _indexPath, clickedCutButton: button)
        }
    }
    @IBAction func clickedCollectButton(_ sender: Any) {
        let button = sender as! UIButton
        if let _indexPath = self.indexPath{
            self.delegate?.musicListCell(self, indexPath: _indexPath, clickedCollectButton: button)
        }
    }
    @IBAction func clickedRankButton(_ sender: Any) {
        let button = sender as! UIButton
        if let _indexPath = self.indexPath{
            self.delegate?.musicListCell(self, indexPath: _indexPath, clickedRankButton: button)
        }
    }
    
}
