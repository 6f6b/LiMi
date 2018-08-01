
//
//  VideoPlayCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import TextRotateView
import ORCycleLabel
import YYText

let clickDetectionTime = Float(0.3)
protocol VideoPlayCellDelegate : class{
    ///点击头像回调
    func videoPlayCell(cell:VideoPlayCell,clickedUserHeadButton button:UIButton,withModel model:VideoTrendModel?)
    ///点击用户名回调
    func videoPlayCell(cell:VideoPlayCell,clickedUserName label:UILabel,withModel model:VideoTrendModel?)

    ///点击添加关注回调
    func videoPlayCell(cell:VideoPlayCell,clickedAddFollowButton button:UIButton,withModel model:VideoTrendModel?)

    ///点击点赞回调
    func videoPlayCell(cell:VideoPlayCell,clickedThumbsUpButton button:UIButton,withModel model:VideoTrendModel?)

    ///点击评论按钮回调
    func videoPlayCell(cell:VideoPlayCell,clickedCommentButton button:UIButton,withModel model:VideoTrendModel?)

    ///点击更多操作
    func videoPlayCell(cell:VideoPlayCell,clickedMoreOperationButton button:UIButton,withModel model:VideoTrendModel?)

    ///单击了播放cell
    func videoPlayCell(cell:VideoPlayCell,singleClickWithModel model:VideoTrendModel?)

    ///双击了播放cell
    func videoPlayCell(cell:VideoPlayCell,doubleClickWithModel model:VideoTrendModel?)

    ///左滑播放cell
    func videoPlayCell(cell:VideoPlayCell,swipeLeftWithModel model:VideoTrendModel?)

    ///点击音乐封面图
    func videoPlayCell(cell:VideoPlayCell,tapedMusicCoverView coverImageView:UIImageView,withModel model:VideoTrendModel?)

    ///点击了文本中的@对象
    func videoPlayCell(cell:VideoPlayCell,clickRemindUserWith userId:Int?)

    ///点击了地理位置
    func videoPlayCell(cell:VideoPlayCell,tapedCreatedAddressWithModel model:VideoTrendModel?)
    ///点击了挑战名称
    func videoPlayCell(cell:VideoPlayCell,tapedChallengeNameWithModel model:VideoTrendModel?)
    ///点击了学校
    func videoPlayCell(cell:VideoPlayCell,tapedSchoolNameWithModel model:VideoTrendModel?)
}
class VideoPlayCell: UITableViewCell {
    var videoTrendModel:VideoTrendModel?
//    var player:AliyunVodPlayer!
//    var indexPath:IndexPath?
    
    //用户头像
    @IBOutlet weak var userHeadButton:UIButton!
    //加关注
    @IBOutlet weak var addFollowButton:UIButton!
    
    //点赞
    @IBOutlet weak var thumbsUpButton:UIButton!
    @IBOutlet weak var thumbsUpNumLabel: UILabel!
    //评论
    @IBOutlet weak var commentButton:UIButton!
    @IBOutlet weak var commentNumLabel: UILabel!
    //更多操作
    @IBOutlet weak var moreOperationButton:UIButton!
    //地理位置
    @IBOutlet weak var createdAdress: UILabel!
        //挑战名称
    @IBOutlet weak var challengeName: UILabel!
    
    //学校名字
    @IBOutlet weak var schoolName: UILabel!
    //用户名字
    @IBOutlet weak var userNameLabel:UILabel!
    //视频title
    @IBOutlet weak var yyVideoTitleLabel: YYLabel!
    
    //音乐图标
    @IBOutlet weak var musicIcon:UIImageView!
    
    @IBOutlet weak var musicNameContainView: UIView!
    //音乐名称
    @IBOutlet weak var musicNameLabel:UILabel!
    //
    @IBOutlet weak var musicAnimationContainView: UIView!
    //音乐封面图
    @IBOutlet weak var musicCoverImageView:UIImageView!
    @IBOutlet weak var videoCoverImageView:UIImageView!
    //底部遮罩
    @IBOutlet weak var bottomMaskView:UIView!
    //底部加载视图
    
    @IBOutlet weak var bufferContainView: UIView!
    var bottomBufferView:BufferView!
    
    weak var delegate:VideoPlayCellDelegate?
    @IBOutlet weak var playButton:UIButton!
    
    @IBOutlet weak var playerContainView:UIView!
    var clickedCount:Int = 0
    
    @IBOutlet weak var musicIconBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var schoolInfoContainView: UIView!
    @IBOutlet weak var userNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var musicIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createdAdressContainView: UIView!
    @IBOutlet weak var challengeInfoContainView: UIView!
    @IBOutlet weak var challengeInfoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var createdAddressBottomConstraint: NSLayoutConstraint!
    
    var musicAnimationView:LOTAnimationView?
    var textRoateView:TextRotateView?
    var cycleLabel:ORCycleLabel?
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
        
//        tempLabel = YYLabel()
//        tempLabel.frame = CGRect.init(x: 100, y: 50, width: 200, height: 50)
//        self.bottomMaskView.addSubview(tempLabel)
        
        self.musicAnimationView = LOTAnimationView.init(name: "music_animation")
        self.musicAnimationView?.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
        self.musicAnimationContainView.addSubview(self.musicAnimationView!)
        self.musicAnimationContainView.bringSubview(toFront: self.musicCoverImageView)
        self.musicAnimationView?.loopAnimation = true
        self.musicAnimationView?.play()
    
        self.musicIconBottomConstraint.constant = TAB_BAR_HEIGHT + 15
        
        self.yyVideoTitleLabel.numberOfLines = 0
        self.yyVideoTitleLabel.lineBreakMode = .byWordWrapping
        self.yyVideoTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.yyVideoTitleLabel.textColor = UIColor.white
        self.yyVideoTitleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH-89
        
        
        let cycleLabel = ORCycleLabel.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 24))
        cycleLabel.text = ""
        cycleLabel.textColor = UIColor.white
        cycleLabel.rate = 0.3
        cycleLabel.font = UIFont.systemFont(ofSize: 12)
        cycleLabel.style = ORTextCycleStyleAlways
        self.musicNameContainView.addSubview(cycleLabel)
        self.cycleLabel = cycleLabel
        
//        let textRotateView = TextRotateView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 24), textModels: [textModel])
//        self.musicNameContainView.addSubview(textRotateView!)
//        self.textRoateView = textRotateView
//        self.textRoateView?.start()
        
        //开始播放        
        NotificationCenter.default.addObserver(self, selector: #selector(thumbsUpButtonRefresh(notification:)), name: THUMBS_UP_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFollowButtonRefresh(notification:)), name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentSuccessed(notification:)), name: COMMENT_SUCCESS_NOTIFICATION, object: nil)
        self.contentView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.selectedBackgroundView?.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [RGBA(r: 0, g: 0, b: 0, a: 0.5).cgColor,RGBA(r: 0, g: 0, b: 0, a: 0).cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.frame = CGRect.init(x: 0, y: 290-190, width: SCREEN_WIDTH, height: 190)
        self.bottomMaskView.layer.addSublayer(gradientLayer)
        
        self.userHeadButton.addTarget(self, action: #selector(userHeadButtonClicked(button:)), for: .touchUpInside)
        
        self.addFollowButton.addTarget(self, action: #selector(addFollowButtonClicked(button:)), for: .touchUpInside)

        self.thumbsUpButton.addTarget(self, action: #selector(thumbsUpButtonClicked(button:)), for: .touchUpInside)

        self.commentButton.addTarget(self, action: #selector(commentButtonClicked(button:)), for: .touchUpInside)

        self.moreOperationButton.addTarget(self, action: #selector(moreOperationButtonClicked(button:)), for: .touchUpInside)

        self.playButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)

        self.userNameLabel.isUserInteractionEnabled = true
        let tapUserNameLabel = UITapGestureRecognizer.init(target: self, action: #selector(userNameLabelClicked(label:)))
        self.userNameLabel.addGestureRecognizer(tapUserNameLabel)

        let tapMusicCoverImage = UITapGestureRecognizer.init(target: self, action: #selector(tapedMusicCoverImageView))
        self.musicCoverImageView.addGestureRecognizer(tapMusicCoverImage)
        
        self.bottomBufferView = BufferView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 1))
        self.bufferContainView.addSubview(self.bottomBufferView)
        
        //添加单击手势
        let singleClick = UITapGestureRecognizer.init(target: self, action: #selector(clickedContentView))
        singleClick.delegate = self
        singleClick.numberOfTapsRequired = 1
        self.contentView.addGestureRecognizer(singleClick)
        
        //添加左滑手势
        let swipeLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(dealSwipeLeft))
        swipeLeft.direction = .left
        self.contentView.addGestureRecognizer(swipeLeft)
        
        let tapCreateAddressGes = UITapGestureRecognizer.init(target: self, action: #selector(tapCreateAddress))
        self.createdAdressContainView.addGestureRecognizer(tapCreateAddressGes)
        let tapChallengeNameGes = UITapGestureRecognizer.init(target: self, action: #selector(tapChallengeName))
        self.challengeInfoContainView.addGestureRecognizer(tapChallengeNameGes)
        let tapSchoolNameGes = UITapGestureRecognizer.init(target: self, action: #selector(tapSchoolName))
        self.schoolInfoContainView.addGestureRecognizer(tapSchoolNameGes)
    }
    
    //MARK: - action
    @objc func tapCreateAddress(){
        self.delegate?.videoPlayCell(cell: self, tapedCreatedAddressWithModel: self.videoTrendModel)
    }
    @objc func tapChallengeName(){
        self.delegate?.videoPlayCell(cell: self, tapedChallengeNameWithModel: self.videoTrendModel)
    }
    @objc func tapSchoolName(){
        self.delegate?.videoPlayCell(cell: self, tapedSchoolNameWithModel: self.videoTrendModel)
    }
    
    @objc func commentSuccessed(notification:Notification){
        if let videoTrendModel = notification.userInfo![TREND_MODEL_KEY] as? VideoTrendModel{
            if videoTrendModel.id == self.videoTrendModel?.id{
                let discussNum = (self.videoTrendModel?.discuss_num)! + 1
                self.videoTrendModel?.discuss_num = discussNum
                if let _commentNum = self.videoTrendModel?.discuss_num{
                    self.commentNumLabel.text = _commentNum.suitableStringValue()
                }
            }
        }
    }
    
    @objc func tapedMusicCoverImageView(){
        self.delegate?.videoPlayCell(cell: self, tapedMusicCoverView: self.musicCoverImageView, withModel: self.videoTrendModel)
    }
    
    @objc func userNameLabelClicked(label:UILabel){
        self.delegate?.videoPlayCell(cell: self, clickedUserName: self.userNameLabel, withModel: self.videoTrendModel)
    }
    
    @objc func userHeadButtonClicked(button:UIButton){
        self.delegate?.videoPlayCell(cell: self, clickedUserHeadButton: button, withModel: self.videoTrendModel)
    }
    @objc func addFollowButtonClicked(button:UIButton){
        self.delegate?.videoPlayCell(cell: self, clickedAddFollowButton: button, withModel: self.videoTrendModel)
    }
    @objc func thumbsUpButtonClicked(button:UIButton){
        self.delegate?.videoPlayCell(cell: self, clickedThumbsUpButton: button, withModel: self.videoTrendModel)
        
    }
    @objc func commentButtonClicked(button:UIButton){
        self.delegate?.videoPlayCell(cell: self, clickedCommentButton: button, withModel: self.videoTrendModel)
    }
    @objc func moreOperationButtonClicked(button:UIButton){
        self.delegate?.videoPlayCell(cell: self, clickedMoreOperationButton: button, withModel: self.videoTrendModel)
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
        self.delegate?.videoPlayCell(cell: self, singleClickWithModel: self.videoTrendModel)
    }
    
    @objc func dealDoubleClick(){
        self.delegate?.videoPlayCell(cell: self, doubleClickWithModel: self.videoTrendModel)
    }
    @objc func dealSwipeLeft(gesture:UISwipeGestureRecognizer){
        self.delegate?.videoPlayCell(cell: self, swipeLeftWithModel: self.videoTrendModel)
    }
    
    @objc func thumbsUpButtonRefresh(notification:Notification){
        if let userInfo = notification.userInfo{
            if let trendModel = userInfo[TREND_MODEL_KEY] as? VideoTrendModel{
                if let _is_click = trendModel.is_click{
                    if _is_click{
//                        self.thumbsUpButton.isHidden = true
                        let animationView = LOTAnimationView.init(name: "favorite")
                        let height = self.thumbsUpButton.frame.size.height
                        let width = self.thumbsUpButton.frame.size.width
                        let animationViewHeight = CGFloat(130*1.1)
                        let animationViewWidth = CGFloat(130*1.1)
                        let x = (CGFloat(width-CGFloat(animationViewWidth)))*0.5
                        let y = (CGFloat(height-CGFloat(animationViewHeight)))*0.5
                        animationView.frame = CGRect.init(x: x, y: y, width: animationViewWidth, height: animationViewHeight)
                        animationView.animationSpeed = 1
                        self.thumbsUpButton.addSubview(animationView)
                        animationView.play {[unowned animationView] (complete) in
                            self.thumbsUpButton.isSelected = _is_click
                            animationView.isHidden = true
                            animationView.removeFromSuperview()
                            if let _clickNum = trendModel.click_num{
                                self.thumbsUpNumLabel.text = _clickNum.suitableStringValue()
                            }
                        }
                    }else{
                        self.thumbsUpButton.isSelected = _is_click
                        if let _clickNum = trendModel.click_num{
                            self.thumbsUpNumLabel.text = _clickNum.suitableStringValue()
                        }
                    }
                }
            }
        }
    }
    
    @objc func addFollowButtonRefresh(notification:Notification){
        if let userInfo = notification.userInfo{
            if let trendModel = userInfo[TREND_MODEL_KEY] as? VideoTrendModel{
                if self.videoTrendModel?.user?.user_id == trendModel.user?.user_id{
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
        self.videoCoverImageView.frame = self.videoFrameWith(height: videoTrendModel?.video?.height, width: videoTrendModel?.video?.width)
        self.videoCoverImageView.image = nil
        if let videoCoverImage = videoTrendModel?.video?.cover{
            self.videoCoverImageView.image = nil
            let url = URL.init(string: videoCoverImage)
            self.videoCoverImageView.kf.setImage(with: url)
        }else{
            self.videoCoverImageView.isHidden = true
        }
        
        if let headPic = videoTrendModel?.user?.head_pic{
            let url = URL.init(string: headPic)
            self.userHeadButton.kf.setImage(with: url, for: .normal, placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        if let _clickNum = videoTrendModel?.click_num{
            self.thumbsUpNumLabel.text = _clickNum.suitableStringValue()
        }
        if let _commentNum = videoTrendModel?.discuss_num{
            self.commentNumLabel.text = _commentNum.suitableStringValue()
        }
        
        //加关注按钮
        if let _is_click = videoTrendModel?.is_click{
            self.thumbsUpButton.isSelected = _is_click
        }
        if let _is_attention = videoTrendModel?.is_attention{
            self.addFollowButton.isHidden = _is_attention
        }
        
        if videoTrendModel?.user?.user_id == Defaults[.userId]{
            self.addFollowButton.isHidden = true
        }
        
        //地理位置
        if let creatAddress = videoTrendModel?.publish_addr{
            self.createdAddressBottomConstraint.constant = 8
            self.createdAdressContainView.isHidden = false
            self.createdAdress.text = creatAddress
        }else{
            self.createdAddressBottomConstraint.constant = -8
            self.createdAdressContainView.isHidden = true
        }
        
        //挑战名称
        if let challengeName = videoTrendModel?.challenge,let _  = videoTrendModel?.challenge_id{
            self.challengeInfoBottomConstraint.constant = 8
            self.challengeInfoContainView.isHidden = false
            self.challengeName.text = challengeName
        }else{
            self.challengeInfoBottomConstraint.constant = -8
            self.challengeInfoContainView.isHidden = true
        }
        
        //学校
        if let _collegeName = videoTrendModel?.user?.college?.name{
            self.schoolName.text = _collegeName
            self.schoolInfoContainView.isHidden = false
        }else{
            self.schoolInfoContainView.isHidden = true
        }
        
        //用户姓名
        if let userNickNmae = videoTrendModel?.user?.nickname{
            self.videoTitleTopConstraint.constant = 6
            self.userNameLabel.isHidden = false
            self.userNameLabel.text = "@\(userNickNmae)"
        }else{
            self.videoTitleTopConstraint.constant = -6
            self.userNameLabel.isHidden = true
        }
        
        //视频title
        if let textExtraModels = videoTrendModel?.notify_extra{
            self.yyVideoTitleLabel.isHidden = false
            self.musicIconTopConstraint.constant = 6
            self.setVideoTrendTitleWith(textExtraModels: textExtraModels)
        }else{
            if let videoTitle = videoTrendModel?.title{
                self.yyVideoTitleLabel.isHidden = false
                self.yyVideoTitleLabel.text = videoTitle
                self.musicIconTopConstraint.constant = 6
            }else{
                self.yyVideoTitleLabel.isHidden = true
                self.musicIconTopConstraint.constant = -6
            }
        }
        self.yyVideoTitleLabel.sizeToFit()
        
        //音乐图标
        //音乐名字
        if let musicName = videoTrendModel?.music?.name{
            self.musicNameLabel.text = musicName
            self.cycleLabel?.text = musicName
        }else if let _nickname = videoTrendModel?.user?.nickname{
            self.musicNameLabel.text = "@\(_nickname)的原创"
            self.cycleLabel?.text =  "@\(_nickname)的原创"
        }
        self.cycleLabel?.start()
        self.musicNameLabel.sizeToFit()
        
        //音乐封面
        self.musicCoverImageView.layer.removeAllAnimations()
        if let musicPic = videoTrendModel?.music?.pic{
            self.musicCoverImageView.kf.setImage(with: URL.init(string: musicPic))
        }else if let headPic = videoTrendModel?.user?.head_pic{
            self.musicCoverImageView.kf.setImage(with: URL.init(string: headPic))
        }
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = Double.pi*2
        animation.duration = 3
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        animation.repeatCount = MAXFLOAT//如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
        animation.isRemovedOnCompletion = false
        self.musicCoverImageView.layer.add(animation, forKey: "transform.rotation.z")
    }
    
    func setVideoTrendTitleWith(textExtraModels:[TextExtraModel]){
        let finalText = NSMutableAttributedString.init()
        //组装字符串
        var location = 0
        for textExtraModel in textExtraModels{
            if let text = textExtraModel.text{
                let handleText = textExtraModel.type == 1 ? "@\(text)" : text
                let nsText = NSString.init(string: handleText)
                let attr = NSMutableAttributedString.init(string: handleText)
                if textExtraModel.type == 0{
                    let range = NSRange.init(location: 0, length: nsText.length)
                    attr.addAttributes([NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14, weight: .medium)], range: range)
                    
                }else if textExtraModel.type == 1{
                    let range = NSRange.init(location: 0, length: nsText.length)
                    attr.yy_setTextHighlight(range, color: nil, backgroundColor: nil) { (view, attr, range, rect) in
                        //print("点击了\(textExtraModel.id)")
                        self.delegate?.videoPlayCell(cell: self, clickRemindUserWith: textExtraModel.id)
                    }
                    attr.addAttributes([NSAttributedStringKey.foregroundColor:RGBA(r: 241, g: 30, b: 101, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 15, weight: .bold)], range: range)
                }
                finalText.append(attr)
                location += nsText.length
            }
        }
        //添加点击事件
        location = 0
//        for textExtraModel in textExtraModels{
//            if let text = textExtraModel.text{
//                let handleText = textExtraModel.type == 1 ? "@\(text)" : text
//                let nsText = NSString.init(string: handleText)
//                let range = NSRange.init(location: location, length: nsText.length)
//                if textExtraModel.type == 0{
//
//                }else if textExtraModel.type == 1{
//                    finalText.yy_setTextHighlight(range, color: nil, backgroundColor: nil) { (view, attr, range, rect) in
//                        self.delegate?.videoPlayCell(cell: self, clickRemindUserWith: textExtraModel.id)
//                    }
//                }
//                location += nsText.length
//            }
//        }
        self.yyVideoTitleLabel.attributedText = finalText
//        self.tempLabel.attributedText = finalText
    }
    
//    func addTapVideo
    
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
        playerView.frame = self.videoFrameWith(height: videoTrendModel?.video?.height, width: videoTrendModel?.video?.width)
        self.playerContainView.addSubview(playerView)
    }
    
    func reset(){
        self.videoCoverImageView.isHidden = false
        self.playButton.isHidden = true
    }

    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.yyVideoTitleLabel))!{
            return false
        }
        return true
    }
}






