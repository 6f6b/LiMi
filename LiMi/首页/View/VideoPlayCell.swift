
//
//  VideoPlayCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

let clickDetectionTime = Float(0.3)
@objc protocol VideoPlayCellDelegate {
    ///点击头像回调
    @objc func videoPlayCellUserHeadButtonClicked(button:UIButton)
    ///点击添加关注回调
    @objc func videoPlayCellAddFollowButtonClicked(button:UIButton)
    ///点击点赞回调
     @objc func videoPlayCellThumbsUpButtonClicked(button:UIButton)
    ///点击评论按钮回调
    @objc func videoPlayCellCommentButtonClicked(button:UIButton)
    ///点击更多操作
    @objc func videoPlayCellMoreOperationButtonClicked(button:UIButton)
    ///单击了播放cell
    @objc func videoPlayCellSingleClick(videoPlayCell:VideoPlayCell)
    ///双击了播放cell
    @objc func videoPlayCellDoubleClick(videoPlayCell:VideoPlayCell)
    ///左滑播放cell
    @objc func videoPlayCellSwipeLeft(videoPlayCell:VideoPlayCell)
}
class VideoPlayCell: UITableViewCell {
    var videoTrendModel:VideoTrendModel?
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
    var videoCoverImageView:UIImageView!
    //底部遮罩
    var bottomMaskImageView:UIImageView?
    //底部加载视图
    var bottomBufferView:BufferView!
    
    weak var delegate:VideoPlayCellDelegate?
    var playButton:UIButton!
    
    var playerContainView:UIView!
    
    var clickedCount:Int = 0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("生成一个新的播放CELL")
    }
    
    deinit {
        print("播放CELL销毁")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //开始播放        
        NotificationCenter.default.addObserver(self, selector: #selector(thumbsUpButtonRefresh(notification:)), name: THUMBS_UP_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFollowButtonRefresh(notification:)), name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentSuccessed(notification:)), name: COMMENT_SUCCESS_NOTIFICATION, object: nil)
        self.contentView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 30)
        
        self.playerContainView = UIView.init(frame: SCREEN_RECT)
        self.contentView.addSubview(self.playerContainView)
        
        self.videoCoverImageView = UIImageView.init(frame: SCREEN_RECT)
        self.videoCoverImageView.contentMode = .scaleAspectFill
        self.videoCoverImageView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.contentView.addSubview(self.videoCoverImageView)
        
        let x = SCREEN_WIDTH-15-44
        let userHeadButtonY = SCREEN_HEIGHT - (405 - 49 + TAB_BAR_HEIGHT)
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
        self.playButton.center = CGPoint.init(x: SCREEN_WIDTH*0.5, y: SCREEN_HEIGHT*0.5)
        self.playButton.isHidden = true
        self.playButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
        self.contentView.addSubview(self.playButton);
        
        let bottomToolsHeight = 140-49+TAB_BAR_HEIGHT
        
        self.bottomMaskImageView = UIImageView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-bottomToolsHeight, width: SCREEN_WIDTH, height: bottomToolsHeight))
//        self.bottomMaskImageView?.backgroundColor = UIColor.red
        self.bottomMaskImageView?.image = UIImage.init(named: "zhezhao_down")
        self.contentView.addSubview(self.bottomMaskImageView!)
        
        self.userNameLabel = UILabel.init(frame: CGRect.init(x: 15, y: SCREEN_HEIGHT-bottomToolsHeight+13, width: 200, height: 16))
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
        
        self.bottomBufferView = BufferView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-TAB_BAR_HEIGHT, width: SCREEN_WIDTH, height: 1))
        self.contentView.addSubview(self.bottomBufferView)
        
        //添加单击手势
        let singleClick = UITapGestureRecognizer.init(target: self, action: #selector(clickedContentView))
        singleClick.numberOfTapsRequired = 1
        self.contentView.addGestureRecognizer(singleClick)
        
        //添加左滑手势
        let swipeLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(dealSwipeLeft))
        swipeLeft.direction = .left
        self.contentView.addGestureRecognizer(swipeLeft)
        
    }
    
    //MARK: - action
    @objc func commentSuccessed(notification:Notification){
        if let videoTrendModel = notification.userInfo![TREND_MODEL_KEY] as? VideoTrendModel{
            if videoTrendModel.id == self.videoTrendModel?.id{
                let discussNum = (self.videoTrendModel?.discuss_num)! + 1
                self.videoTrendModel?.discuss_num = discussNum
                self.commentButton.setTitle(self.videoTrendModel?.discuss_num?.suitableStringValue(), for: .normal)
            }
        }
    }
    
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
    
    @objc func clickedContentView(){
        if self.clickedCount == 0{
            self.perform(#selector(detectionClickedCount), with: nil, afterDelay: TimeInterval.init(clickDetectionTime))
        }
        self.clickedCount += 1
    }
    
    @objc func detectionClickedCount(){
        if self.clickedCount == 1{self.dealSingleClick()}else{
            self.dealDoubleClick()
        }
        self.clickedCount = 0
    }
    
    @objc func playButtonClicked(){
        self.dealSingleClick()
    }
    
    @objc func dealSingleClick(){
        self.delegate?.videoPlayCellSingleClick(videoPlayCell: self)
    }
    
    @objc func dealDoubleClick(){
        self.delegate?.videoPlayCellDoubleClick(videoPlayCell: self)
    }
    @objc func dealSwipeLeft(gesture:UISwipeGestureRecognizer){
        self.delegate?.videoPlayCellSwipeLeft(videoPlayCell: self)
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
                if self.videoTrendModel?.user_id == trendModel.user_id{
                    if let _is_attention = trendModel.is_attention{
                        self.addFollowButton.isHidden = _is_attention
                    }
                }
            }
        }
    }
    
    func calibrationCenterXWith(referButton:UIButton,calibrationButton:UIButton){
        var center = calibrationButton.center
        center.x = referButton.center.x
        calibrationButton.center = center
    }
    
    func configWith(videoTrendModel:VideoTrendModel?){
        self.videoTrendModel = videoTrendModel
        self.reset()
        self.videoCoverImageView.frame = self.videoFrameWith(height: videoTrendModel?.height, width: videoTrendModel?.width)
        self.videoCoverImageView.image = nil
        if let videoCoverImage = videoTrendModel?.video_cover{
            let url = URL.init(string: videoCoverImage)
            self.videoCoverImageView.kf.setImage(with: url)
        }else{
            self.videoCoverImageView.isHidden = true
        }
        
        if let headPic = videoTrendModel?.user_head_pic{
            let url = URL.init(string: headPic)
            self.userHeadButton.kf.setImage(with: url, for: .normal, placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.commentButton.setTitle(videoTrendModel?.discuss_num?.suitableStringValue(), for: .normal)
        self.commentButton.sizeToFitTitleBelowImageWith(distance: 8)
        self.thumbsUpButton.setTitle(videoTrendModel?.click_num?.suitableStringValue(), for: .normal)
        self.thumbsUpButton.sizeToFitTitleBelowImageWith(distance: 8)
        
        //加关注按钮
        if let _is_click = videoTrendModel?.is_click{
            self.thumbsUpButton.isSelected = _is_click
        }
        if let _is_attention = videoTrendModel?.is_attention{
            self.addFollowButton.isHidden = _is_attention
        }
        
        if videoTrendModel?.user_id == Defaults[.userId]{
            self.addFollowButton.isHidden = true
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
    
    func videoFrameWith(height:Int?,width:Int?)->CGRect{
        if let _height = height,let _width = width{
            if _height >= _width{
                return SCREEN_RECT
            }else{
                let vWidth = SCREEN_WIDTH
                let vHeight = SCREEN_WIDTH*(CGFloat(CGFloat(_height)/CGFloat(_width)))
                let vX = CGFloat(0)
                let vY = (SCREEN_HEIGHT-vHeight)/2
                return CGRect.init(x: vX, y: vY, width: vWidth, height: vHeight)
            }
        }else{
            return SCREEN_RECT
        }
    }
    
    func addPlayerView(playerView:UIView){
        playerView.frame = self.videoFrameWith(height: videoTrendModel?.height, width: videoTrendModel?.width)
        self.playerContainView.addSubview(playerView)
    }
    
    func reset(){
        self.videoCoverImageView.isHidden = false
        self.playButton.isHidden = true
    }

}







