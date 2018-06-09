
//
//  VideoPlayCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
protocol VideoPlayCellDelegate {
    func videoPlayCellUserHeadButtonClicked(button:UIButton)
    func videoPlayCellAddFollowButtonClicked(button:UIButton)
    func videoPlayCellThumbsUpButtonClicked(button:UIButton)
    func videoPlayCellCommentButtonClicked(button:UIButton)
    func videoPlayCellMoreOperationButtonClicked(button:UIButton)
}
class VideoPlayCell: UICollectionViewCell {
    var videoTrendModel:VideoTrendModel?
    var playCertificateModel:UploadVideoCertificateModel?
    var player:AliyunVodPlayer!
    var indexPath:IndexPath?
    
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

    //用户名字
    var userNameLabel:UILabel!
    //视频title
    var videoTitleLabel:UILabel!
    //音乐图标
    var musicIcon:UIImageView!
    //音乐名称
    var musicNameLabel:UILabel!
    //音乐封面图
    var musicCoverImageView:UIImageView!
    
    var delegate:VideoPlayCellDelegate?
    var playButton:UIButton!
    
    var isAllowToPlay:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("生成一个新的播放CELL")
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //开始播放
        NotificationCenter.default.addObserver(self, selector: #selector(cellEnterIntoPlayStatusWith(notification:)), name: CELL_START_PLAY_NOTIFICATION, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(thumbsUpButtonRefresh(notification:)), name: THUMBS_UP_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFollowButtonRefresh(notification:)), name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil)
        
        self.contentView.backgroundColor = UIColor.init(red: 30, green: 30, blue: 30, alpha: 30)
        self.player = AliyunVodPlayer.init()
        self.player.displayMode = .fitWithCropping
        self.player.circlePlay = true
        self.player.isAutoPlay = false
        self.player.delegate = self
        self.player.playerView.frame = SCREEN_RECT
//        self.contentView.addSubview(self.player.playerView)
        
        let x = SCREEN_WIDTH-15-44
        let userHeadButtonY = CGFloat(233)
        self.userHeadButton = UIButton.init(frame: CGRect.init(x: x, y: userHeadButtonY, width: 44, height: 44))
        self.userHeadButton.addTarget(self, action: #selector(userHeadButtonClicked(button:)), for: .touchUpInside)
        self.userHeadButton.layer.cornerRadius = 22
        self.userHeadButton.clipsToBounds = true
        self.userHeadButton.setImage(UIImage.init(named: "touxiang"), for: .normal)
        self.contentView.addSubview(self.userHeadButton)
        
        self.addFollowButton = UIButton.init(frame: CGRect.init(x: x, y: self.userHeadButton.frame.maxY-10, width: 28, height: 16))
        self.addFollowButton.addTarget(self, action: #selector(addFollowButtonClicked(button:)), for: .touchUpInside)
        self.addFollowButton.setImage(UIImage.init(named: "home_gz"), for: .normal)
        self.calibrationCenterXWith(referButton: userHeadButton, calibrationButton: addFollowButton)
        self.contentView.addSubview(self.addFollowButton)
    
        self.thumbsUpButton = UIButton.init(frame: CGRect.init(x: x, y: self.userHeadButton.frame.maxY+30, width: 36, height: 36))
        self.thumbsUpButton.addTarget(self, action: #selector(thumbsUpButtonClicked(button:)), for: .touchUpInside)
        self.thumbsUpButton.titleLabel?.textAlignment = .center
        self.thumbsUpButton.setTitle("0", for: .normal)
        self.thumbsUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.thumbsUpButton.setImage(UIImage.init(named: "home_like"), for: .normal)
        self.thumbsUpButton.setImage(UIImage.init(named: "home_likepre"), for: .selected)
        self.thumbsUpButton.sizeToFitTitleBelowImageWith(distance: 8)
        self.calibrationCenterXWith(referButton: userHeadButton, calibrationButton: thumbsUpButton)
        self.contentView.addSubview(self.thumbsUpButton)
        
        self.commentButton = UIButton.init(frame: CGRect.init(x: x, y: self.thumbsUpButton.frame.maxY+20, width: 36, height: 36))
        self.commentButton.addTarget(self, action: #selector(commentButtonClicked(button:)), for: .touchUpInside)
        self.commentButton.titleLabel?.textAlignment = .center
        self.commentButton.setTitle("1.1W", for: .normal)
        self.commentButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.commentButton.setImage(UIImage.init(named: "home_pl"), for: .normal)
        self.commentButton.sizeToFitTitleBelowImageWith(distance: 8)
        self.calibrationCenterXWith(referButton: userHeadButton, calibrationButton: commentButton)
        self.contentView.addSubview(self.commentButton)
        
        self.moreOperationButton = UIButton.init(frame: CGRect.init(x: x, y: self.commentButton.frame.maxY+20, width: 36, height: 36))
        self.moreOperationButton.addTarget(self, action: #selector(moreOperationButtonClicked(button:)), for: .touchUpInside)
        self.moreOperationButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.moreOperationButton.setImage(UIImage.init(named: "home_more"), for: .normal)
        self.calibrationCenterXWith(referButton: userHeadButton, calibrationButton: moreOperationButton)
        self.contentView.addSubview(self.moreOperationButton)
        
        self.playButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        self.playButton.setImage(UIImage.init(named: "home_ic_bofang"), for: .normal)
        self.playButton.center = self.contentView.center
        self.playButton.isHidden = true
        self.playButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        self.contentView.addSubview(self.playButton);
        
        self.userNameLabel = UILabel.init(frame: CGRect.init(x: 15, y: SCREEN_HEIGHT-140+13, width: 200, height: 16))
        self.userNameLabel.textColor = UIColor.white
        self.userNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.contentView.addSubview(self.userNameLabel)
        
        self.videoTitleLabel = UILabel.init(frame: CGRect.init(x: 15, y: self.userNameLabel.frame.maxY+12,width: SCREEN_WIDTH-60-15, height: 13))
        self.videoTitleLabel.textColor = UIColor.white
        self.videoTitleLabel.font = UIFont.systemFont(ofSize: 13)
        self.videoTitleLabel.numberOfLines = 0
        self.videoTitleLabel.lineBreakMode = .byWordWrapping
        self.contentView.addSubview(self.videoTitleLabel)
        
        self.musicIcon = UIImageView.init(frame: CGRect.init(x: 15, y: self.videoTitleLabel.frame.maxY+8, width: 15, height: 15))
        self.musicIcon.image = UIImage.init(named: "music")
        self.contentView.addSubview(self.musicIcon)
        
        self.musicNameLabel = UILabel.init(frame: CGRect.init(x: self.musicIcon.frame.maxX+11, y: self.videoTitleLabel.frame.maxY+10, width: 200, height: 12))
        self.musicNameLabel.textColor = UIColor.white
        self.musicNameLabel.font = UIFont.systemFont(ofSize: 12)
        var center = musicNameLabel.center
        center.y = self.musicIcon.center.y
        self.musicNameLabel.center = center
        self.contentView.addSubview(self.musicNameLabel)
        
        self.musicCoverImageView = UIImageView.init(frame: CGRect.init(x: SCREEN_WIDTH-60, y: self.musicNameLabel.frame.maxY-44, width: 44, height: 44))
        self.musicCoverImageView.layer.cornerRadius = 22
        self.musicCoverImageView.clipsToBounds = true
        self.contentView.addSubview(self.musicCoverImageView)
        
        let tapPlayerView = UITapGestureRecognizer.init(target: self, action: #selector(tapedPlayerView))
        self.player.playerView.addGestureRecognizer(tapPlayerView)
    }
    
    deinit {
        print("播放CELL销毁")
        NotificationCenter.default.removeObserver(self)
        self.player.release()
    }
    
    //MARK: - action
    
    @objc func userHeadButtonClicked(button:UIButton){
        self.delegate?.videoPlayCellUserHeadButtonClicked(button: button)
    }
    @objc func addFollowButtonClicked(button:UIButton){
        self.delegate?.videoPlayCellAddFollowButtonClicked(button: button)
    }
    @objc func thumbsUpButtonClicked(button:UIButton){
        self.delegate?.videoPlayCellThumbsUpButtonClicked(button: button)

    }
    @objc func commentButtonClicked(button:UIButton){
        self.delegate?.videoPlayCellCommentButtonClicked(button: button)
    }
    @objc func moreOperationButtonClicked(button:UIButton){
        self.delegate?.videoPlayCellMoreOperationButtonClicked(button: button)
    }

    
    @objc func playButtonClicked(){
        self.tapedPlayerView()
    }
    
    @objc func tapedPlayerView(){
        if self.player.playerState() == .pause{
            self.resume()
        }else{
            self.pause()
        }
    }
    
    @objc func cellEnterIntoPlayStatusWith(notification:Notification){
        if let userInfo = notification.userInfo{
            if let videoPlayCell = userInfo[CELL_INSTANCE_KEY] as? VideoPlayCell{
                if videoPlayCell.videoTrendModel?.id != self.videoTrendModel?.id{
//                    self.stop()
                }
            }
        }
    }
    
    @objc func thumbsUpButtonRefresh(notification:Notification){
        if let userInfo = notification.userInfo{
            if let trendModel = userInfo[TREND_MODEL_KEY] as? VideoTrendModel{
                if let _is_click = trendModel.is_click{
                        self.thumbsUpButton.isSelected = _is_click
                        self.thumbsUpButton.setTitle(trendModel.click_num?.suitableStringValue(), for: .normal)
                }
            }
        }
    }
    
    @objc func addFollowButtonRefresh(notification:Notification){
        if let userInfo = notification.userInfo{
            if let trendModel = userInfo[TREND_MODEL_KEY] as? VideoTrendModel{
                if let _is_attention = trendModel.is_attention{
                    self.addFollowButton.isHidden = _is_attention
                }
            }
        }
    }
    
    func calibrationCenterXWith(referButton:UIButton,calibrationButton:UIButton){
        var center = calibrationButton.center
        center.x = referButton.center.x
        calibrationButton.center = center
    }
    
    func configWith(videoTrendModel:VideoTrendModel?,playCertificateModel:UploadVideoCertificateModel?){
        self.videoTrendModel = videoTrendModel
        self.playCertificateModel = playCertificateModel
        self.reset()
        self.prepareWith(videoTrendModel: videoTrendModel, playCertificateModel: playCertificateModel)
        
        if let headPic = videoTrendModel?.user_head_pic{
            let url = URL.init(string: headPic)
            self.userHeadButton.kf.setImage(with: url, for: .normal, placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.commentButton.setTitle(videoTrendModel?.discuss_num?.suitableStringValue(), for: .normal)
        self.commentButton.sizeToFitTitleBelowImageWith(distance: 8)
        self.thumbsUpButton.setTitle(videoTrendModel?.click_num?.suitableStringValue(), for: .normal)
        self.thumbsUpButton.sizeToFitTitleBelowImageWith(distance: 8)
        
        if let _is_click = videoTrendModel?.is_click{
            self.thumbsUpButton.isSelected = _is_click
        }
        if let _is_attention = videoTrendModel?.is_attention{
            self.addFollowButton.isHidden = _is_attention
        }
        
        //用户姓名
        if let userNickNmae = videoTrendModel?.user_nickname{
            self.userNameLabel.isHidden = false
            self.userNameLabel.text = userNickNmae
        }else{
            self.userNameLabel.isHidden = true
        }
        
        //视频title
        if let videoTitle = videoTrendModel?.title{
            self.videoTitleLabel.isHidden = false
            self.videoTitleLabel.text = videoTitle
        }else{
            self.videoTitleLabel.isHidden = true
        }
        
        //音乐图标
        //音乐名字
        if let musicName = videoTrendModel?.music_name{
            self.musicIcon.isHidden = false
            self.musicNameLabel.isHidden = false
            self.musicNameLabel.text = musicName
            self.musicNameLabel.sizeToFit()
        }else{
            self.musicIcon.isHidden = true
            self.musicNameLabel.isHidden = true
        }
        //音乐封面
        if let musicPic = videoTrendModel?.music_pic{
            self.musicCoverImageView.isHidden = false
            self.musicCoverImageView.kf.setImage(with: URL.init(string: musicPic))
        }else{
            self.musicCoverImageView.isHidden = true
        }
    }
    
    func prepareWith(videoTrendModel:VideoTrendModel?,playCertificateModel:UploadVideoCertificateModel?){
        let vid = videoTrendModel?.video ?? ""
        let keyId = playCertificateModel?.AccessKeyId ?? ""
        let keySecret = playCertificateModel?.AccessKeySecret ?? ""
        let securityToken = playCertificateModel?.SecurityToken ?? ""
        self.player.prepare(withVid: vid, accessKeyId: keyId, accessKeySecret: keySecret, securityToken: securityToken)
    }
    
    func reset(){
        self.player.stop()
        self.playButton.isHidden = true
        self.isAllowToPlay = false
    }
    
    //播放
    func play(){
        self.contentView.backgroundColor = UIColor.green
//        print("播放链接--->\(self.videoTrendModel?.video)")
//        self.isAllowToPlay = true
//        if self.player.isPlaying{return}
//        if self.player.playerState() == .prepared{
//            self.player.start()
//        }else{
//            self.prepareWith(videoTrendModel: self.videoTrendModel, playCertificateModel: self.playCertificateModel)
//        }
    }
    //停止
    func stop(){
        self.contentView.backgroundColor = UIColor.red
//        self.isAllowToPlay = false
//        self.player.stop()
//        self.prepareWith(videoTrendModel: self.videoTrendModel, playCertificateModel: self.playCertificateModel)
    }
    //暂停
    func pause(){
        self.isAllowToPlay = false
        self.player.pause()
    }
    //恢复
    func resume(){
        self.isAllowToPlay = true
        self.player.resume()
    }
}

extension VideoPlayCell:AliyunVodPlayerDelegate{
    /**
     * 功能：播放事件协议方法,主要内容 AliyunVodPlayerEventPrepareDone状态下，此时获取到播放视频数据（时长、当前播放数据、视频宽高等）
     * 参数：event 视频事件
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, onEventCallback event: AliyunVodPlayerEvent) {
        if vodPlayer.isPlaying{self.playButton.isHidden = true}
        
        if event == .prepareDone{
            print("播放器状态变更--->准备完毕")
            if self.isAllowToPlay{
                self.player.start()
            }
        }
        if event == .play{
            self.playButton.isHidden = true
            print("播放器状态变更--->播放中")
        }
        if event == .firstFrame{
            print("播放器状态变更--->第一帧")
            
            if self.isAllowToPlay{
                NotificationCenter.default.post(name: CELL_START_PLAY_NOTIFICATION, object: nil, userInfo: [CELL_INSTANCE_KEY:self])
            }
            
        }
        if event == .pause{
            self.playButton.isHidden = false
        }
        if event == .stop{
            print("播放器状态变更--->停止")
        }
        if event == .finish{
            print("播放器状态变更--->finish")
        }
        if event == .beginLoading{
            print("播放器状态变更--->开始加载")

        }
        if event == .endLoading{
            print("播放器状态变更--->加载完毕")
        }
        if event == .seekDone{
            print("播放器状态变更--->seekdone")
        }
        
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








