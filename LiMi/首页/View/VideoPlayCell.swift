//
//  VideoPlayCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class VideoPlayCell: UICollectionViewCell {
    var player:AliyunVodPlayer!
    
    //用户头像
    var userHeadButton:UIButton!
    //加关注
    var addFollowButton:UIButton!
    //点赞
    var thumbsUpButton:UIButton!
    //评论
    var commentButton:UIButton!
    //更多操作
    var moreOperationButton:UIButton!
//
//    //用户名字
//    var userNameLabel:UILabel?
//    //视频title
//    var videoTitleLabel:UILabel?
//    //音乐
//    var musicInfoView:MusicInfoView?
//
    var playButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.yellow
        self.player = AliyunVodPlayer.init()
        self.player.delegate = self
        self.player.playerView.frame = SCREEN_RECT
        self.contentView.addSubview(self.player.playerView)

        let x = SCREEN_WIDTH-15-44
        let userHeadButtonY = CGFloat(233)
        self.userHeadButton = UIButton.init(frame: CGRect.init(x: x, y: userHeadButtonY, width: 44, height: 44))
        self.userHeadButton.setImage(UIImage.init(named: "touxiang"), for: .normal)
        self.contentView.addSubview(self.userHeadButton)
        
        self.addFollowButton = UIButton.init(frame: CGRect.init(x: x, y: self.userHeadButton.frame.maxY-10, width: 28, height: 16))
        self.addFollowButton.setImage(UIImage.init(named: "home_gz"), for: .normal)
        self.calibrationCenterXWith(referButton: userHeadButton, calibrationButton: addFollowButton)
        self.contentView.addSubview(self.addFollowButton)
    
        self.thumbsUpButton = UIButton.init(frame: CGRect.init(x: x, y: self.userHeadButton.frame.maxY+30, width: 36, height: 36))
        self.thumbsUpButton.setTitle("1.1W", for: .normal)
        self.thumbsUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.thumbsUpButton.setImage(UIImage.init(named: "home_like"), for: .normal)
        self.thumbsUpButton.setImage(UIImage.init(named: "home_likepre"), for: .selected)
        self.thumbsUpButton.sizeToFitTitleBelowImageWith(distance: 8)
        self.calibrationCenterXWith(referButton: userHeadButton, calibrationButton: thumbsUpButton)
        self.contentView.addSubview(self.thumbsUpButton)
        
        self.commentButton = UIButton.init(frame: CGRect.init(x: x, y: self.thumbsUpButton.frame.maxY+20, width: 36, height: 36))
        self.commentButton.setTitle("1.1W", for: .normal)
        self.commentButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.commentButton.setImage(UIImage.init(named: "home_pl"), for: .normal)
        self.commentButton.sizeToFitTitleBelowImageWith(distance: 8)
        self.calibrationCenterXWith(referButton: userHeadButton, calibrationButton: commentButton)
        self.contentView.addSubview(self.commentButton)
        
        self.moreOperationButton = UIButton.init(frame: CGRect.init(x: x, y: self.commentButton.frame.maxY+20, width: 36, height: 36))
        self.moreOperationButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.moreOperationButton.setImage(UIImage.init(named: "home_more"), for: .normal)
        self.calibrationCenterXWith(referButton: userHeadButton, calibrationButton: moreOperationButton)
        self.contentView.addSubview(self.moreOperationButton)
        
        self.playButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        self.playButton.setImage(UIImage.init(named: "home_ic_bofang"), for: .normal)
        self.playButton.center = self.contentView.center
        self.contentView.addSubview(self.playButton);
    }
    

    func calibrationCenterXWith(referButton:UIButton,calibrationButton:UIButton){
        var center = calibrationButton.center
        center.x = referButton.center.x
        calibrationButton.center = center
    }
}

extension VideoPlayCell:AliyunVodPlayerDelegate{
    /**
     * 功能：播放事件协议方法,主要内容 AliyunVodPlayerEventPrepareDone状态下，此时获取到播放视频数据（时长、当前播放数据、视频宽高等）
     * 参数：event 视频事件
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, onEventCallback event: AliyunVodPlayerEvent) {
        
    }
    
    /**
     * 功能：播放器播放时发生错误时，回调信息
     * 参数：errorModel 播放器报错时提供的错误信息对象
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, playBack errorModel: AliyunPlayerVideoErrorModel!) {
        
    }
    
    //@optional
    
    /**
     * 功能：播放器播放即将切换清晰度时
     * 参数：quality ： vid+playauth播放方式、vid+sts播放方式时的清晰度
     videoDefinition ： 媒体转码播放方式的清晰度
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, willSwitchTo quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
    /**
     * 功能：播放器播放切换清晰度完成
     * 参数：quality ： vid+playauth播放方式、vid+sts播放方式时的清晰度
     videoDefinition ： 媒体转码播放方式的清晰度
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, didSwitchTo quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
    /**
     * 功能：播放器播放切换清晰度失败
     * 参数：quality ： vid+playauth播放方式、vid+sts播放方式时的清晰度
     videoDefinition ： 媒体转码播放方式的清晰度
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, failSwitchTo quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
    /**
     * 功能：1.播放器设置了循环播放，此代理方法才会有效。2.播放器播放完成后，开始循环播放后，此协议被调用
     */
    func onCircleStart(with vodPlayer: AliyunVodPlayer!) {
        
    }
    /*
     *功能：播放器请求时，通知用户传入的参数鉴权过期。
     */
    func onTimeExpiredError(with vodPlayer: AliyunVodPlayer!) {
        
    }
    /*
     *功能：播放地址将要过期时，提示用户当前播放地址过期。 （策略：当前播放器地址过期时间2小时，我们在播放地址差1分钟过期时提供回调；（7200-60）秒时发送）
     *参数：videoid：将过期时播放的videoId
     *参数：quality：将过期时播放的清晰度，playauth播放方式和STS播放方式有效。
     *参数：videoDefinition：将过期时播放的清晰度，MPS播放方式时有效。
     */
    func vodPlayerPlaybackAddressExpired(withVideoId videoId: String!, quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
}

//extension VideoPlayCell:AliyunVodPlayerViewDelegate{
//    /**
//     * 功能：返回按钮事件
//     * 参数：playerView ：AliyunVodPlayerView
//     */
//    func onBackViewClick(with playerView: AliyunVodPlayerView!) {
//
//    }
//
//    /**
//     * 功能：是否锁屏
//     */
//    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, lockScreen isLockScreen: Bool) {
//
//    }
//
//    /**
//     * 功能：返回调用全屏
//     * 参数：isFullScreen ： 点击全屏按钮后，返回当前是否全屏状态
//     */
//    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, fullScreen isFullScreen: Bool) {
//
//    }
//
//    //@optional
//    /**
//     * 功能：暂停事件
//     * 参数：currentPlayTime ： 暂停时播放时间
//     */
//    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onPause currentPlayTime: TimeInterval) {
//
//    }
//
//    /**
//     * 功能：继续事件
//     * 参数：currentPlayTime ： 继续播放时播放时间。
//     */
//    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onResume currentPlayTime: TimeInterval) {
//
//    }
//    /**
//     * 功能：播放完成事件 ，请区别stop（停止播放）
//     * 参数：playerView ： AliyunVodPlayerView
//     */
//    func onFinish(with playerView: AliyunVodPlayerView!) {
//
//    }
//    /**
//     * 功能：停止播放
//     * 参数：currentPlayTime ： 播放停止时播放时间。
//     */
//    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onStop currentPlayTime: TimeInterval) {
//
//    }
//
//    /**
//     * 功能：拖动进度条结束事件
//     * 参数：seekDoneTime ： seekDone时播放时间。
//     */
//    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onSeekDone seekDoneTime: TimeInterval) {
//
//    }
//
//    /**
//     * 功能：切换后的清晰度
//     * 参数：quality ：切换后的清晰度
//     playerView ： AliyunVodPlayerView
//     */
//    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onVideoQualityChanged quality: AliyunVodPlayerVideoQuality) {
//
//    }
//    /**
//     * 功能：切换后的清晰度，清晰度非枚举类型，字符串，适应于媒体转码播放
//     * 参数：videoDefinition ： 媒体处理，切换清晰度后清晰度
//     playerView ：AliyunVodPlayerView
//     */
//    func aliyunVodPlayerView(_ playerView: AliyunVodPlayerView!, onVideoDefinitionChanged videoDefinition: String!) {
//
//    }
//    /**
//     * 功能：循环播放开始
//     * 参数：playerView ：AliyunVodPlayerView
//     */
//    func onCircleStart(with playerView: AliyunVodPlayerView!) {
//
//    }
//
//}
