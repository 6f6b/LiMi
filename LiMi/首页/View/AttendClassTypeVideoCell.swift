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
}

class AttendClassTypeVideoCell: UITableViewCell {
    var model:VideoTrendModel?
    @IBOutlet weak var userHeadImage: UIButton!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var school: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var pauseImage: UIImageView!
    @IBOutlet weak var videoTrendContent: UILabel!
    @IBOutlet weak var clickNumButton: UIButton!
    @IBOutlet weak var commentNumButton: UIButton!
    @IBOutlet weak var moreOperationButton: UIButton!
    
    @IBOutlet weak var videoContainView: UIView!
    @IBOutlet weak var videoContainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoContainViewWidth: NSLayoutConstraint!
    
    weak var delegate:AttendClassTypeVideoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configWith(model:VideoTrendModel){
        self.model = model
        if let _headPic = model.user?.head_pic{
            self.userHeadImage.kf.setImage(with: URL.init(string: _headPic), for: .normal)
        }
        self.nickName.text = model.user?.nickname
        self.school.text = model.user?.college?.name
        if model.user?.is_attention == 0{
            self.followButton.isHidden = false
        }else{
            self.followButton.isHidden = true
        }
        if let _clickNum = model.click_num{
            self.clickNumButton.setTitle(_clickNum.suitableStringValue(), for: .normal)
        }
        if let _commentNum = model.discuss_num{
            self.commentNumButton.setTitle(_commentNum.suitableStringValue(), for: .normal)
        }
        
        var videoContainViewConstWidth = (SCREEN_WIDTH-15*2)*0.5
        var videoContainViewConstHeight = videoContainViewConstWidth*(16.0/9.0)
        if let videoWidth = model.video?.width,let videoHeight = model.video?.height{
            if videoWidth > videoHeight{
                videoContainViewConstWidth = SCREEN_WIDTH-15*2
                videoContainViewConstHeight = videoContainViewConstWidth*(9.0/16.0)
            }
        }
        self.videoContainViewWidth.constant = videoContainViewConstWidth
        self.videoContainViewHeight.constant = videoContainViewConstHeight
        self.videoContainView.layoutIfNeeded()
        
        self.videoTrendContent.text = model.title
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
