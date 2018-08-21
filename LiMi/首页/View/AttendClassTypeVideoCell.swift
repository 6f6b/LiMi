//
//  AttendClassTypeVideoCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/8.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol AttendClassTypeVideoCellDelegate : class{
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickHeadImageWith model:VideoTrendModel?)
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickFollowButtonWith model:VideoTrendModel?)
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickThumbUpWith model:VideoTrendModel?)
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickHeadCommentButtonWith model:VideoTrendModel?)
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickMoreOperationWith model:VideoTrendModel?)
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickPlayButtonWith model:VideoTrendModel?)
}

class AttendClassTypeVideoCell: UITableViewCell {
    var model:VideoTrendModel?
    @IBOutlet weak var userHeadImage: UIButton!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var school: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var videoTrendContent: UILabel!
    @IBOutlet weak var clickNumButton: UIButton!
    @IBOutlet weak var commentNumButton: UIButton!
    @IBOutlet weak var moreOperationButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var videoContainView: UIView!
    @IBOutlet weak var videoContainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoContainViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var goodStudentTag: UILabel!
    
    var videoPlayerContainView:VideoPlayerContainView?
    weak var playerView:UIView?
    weak var delegate:AttendClassTypeVideoCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(thumbsUpButtonRefresh(notification:)), name: THUMBS_UP_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFollowButtonRefresh(notification:)), name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentSuccessed(notification:)), name: COMMENT_SUCCESS_NOTIFICATION, object: nil)
        
        self.videoPlayerContainView = VideoPlayerContainView.init(frame: self.videoContainView.bounds)
        self.videoPlayerContainView?.delegate = self
        self.videoContainView.addSubview(self.videoPlayerContainView!)
    }

    @objc func commentSuccessed(notification:Notification){
        if let videoTrendModel = notification.userInfo![TREND_MODEL_KEY] as? VideoTrendModel{
            if videoTrendModel.id == self.model?.id{
                let discussNum = (self.model?.discuss_num)! + 1
                self.model?.discuss_num = discussNum
                if let _commentNum = self.model?.discuss_num{
                    self.commentNumButton.setTitle("  \(_commentNum.suitableStringValue())", for: .normal)
                }
            }
        }
    }
    
    @objc func addFollowButtonRefresh(notification:Notification){
        if let userInfo = notification.userInfo{
            if let trendModel = userInfo[TREND_MODEL_KEY] as? VideoTrendModel{
                if self.model?.user?.user_id == trendModel.user?.user_id{
                    if let _is_attention = trendModel.is_attention{
                        self.followButton.isHidden = _is_attention == 0 ? false : true
                    }
                }
            }
        }
    }
    
    @objc func thumbsUpButtonRefresh(notification:Notification){
        if let userInfo = notification.userInfo{
            if let trendModel = userInfo[TREND_MODEL_KEY] as? VideoTrendModel{
                if trendModel.id != self.model?.id{return}
                if let _is_click = trendModel.is_click{
                    if _is_click{
                            self.clickNumButton.isSelected = _is_click
                            if let _clickNum = trendModel.click_num{
                                self.clickNumButton.setTitle("  \(_clickNum.suitableStringValue())", for: .normal)
                            }
                    }else{
                        self.clickNumButton.isSelected = _is_click
                        if let _clickNum = trendModel.click_num{
                            self.clickNumButton.setTitle("  \(_clickNum.suitableStringValue())", for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configWith(model:VideoTrendModel){
        self.model = model
        self.playerView?.removeFromSuperview()
        if let _headPic = model.user?.head_pic{
            self.userHeadImage.setImage(nil, for: .normal)
            self.userHeadImage.kf.setImage(with: URL.init(string: _headPic), for: .normal)
        }
        self.nickName.text = model.user?.nickname
        self.school.text = model.user?.college?.name
        if model.is_attention == 0{
            self.followButton.isHidden = false
        }else{
            self.followButton.isHidden = true
        }
        if let _clickNum = model.click_num{
            self.clickNumButton.setTitle("  \(_clickNum.suitableStringValue())", for: .normal)
        }
                
        if let _is_click = model.is_click{
            self.clickNumButton.isSelected = _is_click
        }
        
        if let _commentNum = model.discuss_num{
            self.commentNumButton.setTitle("  \(_commentNum.suitableStringValue())", for: .normal)
        }
        
//        if let _videoImage = model.video?.cover{
//            self.videoPreImageView.kf.setImage(with: URL.init(string: _videoImage))
//        }

        var videoContainViewConstHeight = (SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT-TAB_BAR_HEIGHT)*0.8
        var videoContainViewConstWidth = videoContainViewConstHeight*(9.0/16.0)
        if let videoWidth = model.video?.width,let videoHeight = model.video?.height{
            if videoWidth > videoHeight{
                videoContainViewConstWidth = SCREEN_WIDTH-15*2
                videoContainViewConstHeight = videoContainViewConstWidth*(9.0/16.0)
            }
        }
        self.videoContainViewWidth.constant = videoContainViewConstWidth
        self.videoContainViewHeight.constant = videoContainViewConstHeight
        self.videoContainView.layoutIfNeeded()
        self.videoPlayerContainView?.frame = CGRect.init(x: 0, y: 0, width: videoContainViewConstWidth, height: videoContainViewConstHeight)
        self.videoPlayerContainView?.configWith(model: model)
        
        self.videoTrendContent.text = model.title
        
        self.timeLabel.text = model.publish_time
        self.goodStudentTag.text = model.user?.identity_name ?? "学霸"
    }
    
    func installPlayerViewWith(playerView:UIView){
        playerView.backgroundColor = UIColor.clear
        playerView.isHidden = true
        if let _videoPlayerContainView = self.videoPlayerContainView{
            _videoPlayerContainView.installPlayerView(playerView: playerView)
        }
    }
    
    func resetCell(){
        self.videoPlayerContainView?.playButton.isSelected = false
    }
    
    @IBAction func clickHeadButton(_ sender: Any) {
        self.delegate?.attendClassTypeVideoCell(cell: self, clickHeadImageWith: self.model)
    }
    
    @IBAction func clickFollowButton(_ sender: Any) {
        self.delegate?.attendClassTypeVideoCell(cell: self, clickFollowButtonWith: self.model)
    }
    
    @IBAction func clickThumbUpButton(_ sender: Any) {
        self.delegate?.attendClassTypeVideoCell(cell: self, clickThumbUpWith: self.model)
    }
    @IBAction func clickCommentButton(_ sender: Any) {
        self.delegate?.attendClassTypeVideoCell(cell: self, clickHeadCommentButtonWith: self.model)
    }
    @IBAction func clickMoreOperationButton(_ sender: Any) {
        self.delegate?.attendClassTypeVideoCell(cell: self, clickMoreOperationWith: self.model)
    }
}

extension AttendClassTypeVideoCell : VideoPlayerContainViewDelegate{
    func videoPlayerViewClickedPlayButton() {
        self.delegate?.attendClassTypeVideoCell(cell: self, clickPlayButtonWith: self.model)
    }
    
    
    func videoPlayerViewBeTaped(){
        //在window上
        if let _superView = self.videoPlayerContainView?.superview as? WindowLevelView{
            _superView.removeFromSuperview()
            self.videoPlayerContainView?.frame = self.videoContainView.bounds
            self.videoContainView.addSubview(self.videoPlayerContainView!)
        }else{
            //在Cell的view上
            let windowLevelView = WindowLevelView.init(frame: SCREEN_RECT)
            windowLevelView.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.8)
            var height = SCREEN_HEIGHT
            var width = SCREEN_WIDTH
            if let _height = self.model?.video?.height,let _width = self.model?.video?.width{
                if _width > _height{
                    height = width * (9.0/16.0)
                }
            }
            self.videoPlayerContainView?.frame = CGRect.init(x: 0, y: 0, width: width, height: height)
            self.videoPlayerContainView?.center = CGPoint.init(x: SCREEN_WIDTH*0.5, y: SCREEN_HEIGHT*0.5)
            self.videoPlayerContainView?.removeFromSuperview()
            windowLevelView.addSubview(self.videoPlayerContainView!)
            UIApplication.shared.keyWindow?.addSubview(windowLevelView)
        }
    }
    func videoPlayerViewBePanWith(ges:UIPanGestureRecognizer){
        //在window上
        if let _superView = self.videoPlayerContainView?.superview as? WindowLevelView{
            let point = ges.translation(in: ges.view)
            var points = self.videoPlayerContainView?.center
            points?.x += point.x
            points?.y += point.y
            self.videoPlayerContainView?.center = points!
            ges.setTranslation(CGPoint.zero, in: ges.view)
            print("\(ges.state)")
            if ges.state == .ended{
                let ratio = CGFloat(0.35)
                //超过一定区域
                if (points?.x)! <= SCREEN_WIDTH*ratio || (points?.x)! >= SCREEN_WIDTH*(1-ratio) || (points?.y)! <= SCREEN_HEIGHT*ratio || (points?.y)! >= SCREEN_HEIGHT*(1-ratio){
                    _superView.removeFromSuperview()
                    self.videoPlayerContainView?.frame = self.videoContainView.bounds
                    self.videoContainView.addSubview(self.videoPlayerContainView!)
                }else{
                    //未超过
                    UIView.animate(withDuration: 0.3) {
                        self.videoPlayerContainView?.center = CGPoint.init(x: SCREEN_WIDTH*0.5, y: SCREEN_HEIGHT*0.5)
                    }
                }
            }
        }else{
            //在Cell的view上
            return
        }
    }

}
