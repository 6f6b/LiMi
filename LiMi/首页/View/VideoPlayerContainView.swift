//
//  VideoPlayerContainView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/14.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
protocol VideoPlayerContainViewDelegate : class {
    func videoPlayerViewClickedPlayButton()
    func videoPlayerViewBeTaped()
    func videoPlayerViewBePanWith(ges:UIPanGestureRecognizer)
}

class VideoPlayerContainView: UIView {
//    var videoContainView:UIView!
    var playButton:UIButton!
    weak var player:AliyunVodPlayer?
    weak var delegate:VideoPlayerContainViewDelegate?
    var videoPreImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        player?.playerState()
//        videoContainView = UIView.init(frame: frame)
//        self.addSubview(videoContainView)
//        videoContainView.snp.makeConstraints {[unowned self]  (make) in
//            make.top.equalTo(self)
//            make.left.equalTo(self)
//            make.bottom.equalTo(self)
//            make.right.equalTo(self)
//        }
        
        self.videoPreImageView = UIImageView.init(frame: frame)
        self.addSubview(self.videoPreImageView)
        self.videoPreImageView.contentMode = .scaleAspectFill
        self.videoPreImageView.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
            
        }
        
        self.playButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 22, height: 22))
        self.playButton.setImage(UIImage.init(named: "music_ic_bofang"), for: .normal)
        self.playButton.setImage(UIImage.init(named: "music_ic_zanting"), for: .selected)
        
        self.addSubview(self.playButton)
        self.playButton.snp.makeConstraints {(make) in
            make.height.equalTo(22)
            make.width.equalTo(22)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
        self.playButton.addTarget(self, action: #selector(clickedPlayButton), for: .touchUpInside)
        
        //点击手势
        let tapG = UITapGestureRecognizer.init(target: self, action: #selector(dealTapSelf))
        self.addGestureRecognizer(tapG)
        //拖动手势
        let panG = UIPanGestureRecognizer.init(target: self, action: #selector(dealPanSelf(ges:)))
        self.addGestureRecognizer(panG)
    }
    
    @objc func dealTapSelf(){
        self.delegate?.videoPlayerViewBeTaped()
    }
    
    @objc func dealPanSelf(ges:UIPanGestureRecognizer){
        self.delegate?.videoPlayerViewBePanWith(ges: ges)
    }
    
    func configWith(model:VideoTrendModel?){
        if let  _preImage = model?.video?.cover{
            self.videoPreImageView.kf.setImage(with: URL.init(string: _preImage))
        }
        self.playButton.isSelected = false
    }
    
    func installPlayerView(playerView:UIView){
        //self.insertSubview(playerView, aboveSubview: self.videoPreImageView)
        self.insertSubview(playerView, at: 1)
        playerView.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - actions
    @objc func clickedPlayButton(){
        //        AliyunVodPlayerStateIdle = 0,           //空转，闲时，静态
        //        AliyunVodPlayerStateError,              //错误
        //        AliyunVodPlayerStatePrepared,           //已准备好
        //        AliyunVodPlayerStatePlay,               //播放
        //        AliyunVodPlayerStatePause,              //暂停
        //        AliyunVodPlayerStateStop,               //停止
        //        AliyunVodPlayerStateFinish,             //播放完成
        //        AliyunVodPlayerStateLoading             //加载中
        self.delegate?.videoPlayerViewClickedPlayButton()
        //        if let playerState = self.delegate?.videoPlayerViewClickedPlayButton(){
        //            if playerState == .play{
        //                self.playButton.isSelected = true
        //            }else{
        //                self.playButton.isSelected = false
        //            }
        //        }
    }
}

