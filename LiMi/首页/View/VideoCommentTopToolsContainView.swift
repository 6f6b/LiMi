
//
//  VideoCommentTopToolsContainView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/9.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class VideoCommentTopToolsContainView: CommentTopToolsContainView {
    var thumbsUpButton:UIButton!
    var commentModel:CommentModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.thumbsUpButton = UIButton.init(frame: CGRect.init(x: SCREEN_WIDTH-22-15, y: 22, width: 22, height: 22))
        self.thumbsUpButton.addTarget(self, action: #selector(thumbsUpButtonClicked(button:)), for: .touchUpInside)
        self.thumbsUpButton.titleLabel?.textAlignment = .center
        self.thumbsUpButton.setTitle("0", for: .normal)
        self.thumbsUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.thumbsUpButton.setImage(UIImage.init(named: "pl_ic_like"), for: .normal)
        self.thumbsUpButton.setImage(UIImage.init(named: "pl_ic_likepre"), for: .selected)
        self.thumbsUpButton.sizeToFitTitleBelowImageWith(distance: 8)
        self.addSubview(self.thumbsUpButton)
        
//        self.headImgBtn.snp.makeConstraints { (make) in
//            make.top.equalTo(self).offset(15)
//            make.left.equalTo(self).offset(15)
//            make.bottom.equalTo(self).offset(-15)
//            make.height.equalTo(40)
//            make.width.equalTo(40)
//        }
    }
    
    override func configWith(model: TrendModel?, cellStyle: TrendsCellStyle) {
        super.configWith(model: model, cellStyle: .inCommentList)
        
    }
    
    @objc func thumbsUpButtonClicked(button:UIButton){
//        DiscussClickAction
        if !AppManager.shared.checkUserStatus(){return}
        let discussClickAction = DiscussClickAction.init(discuss_id: self.commentModel?.id)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: discussClickAction)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                self.commentModel?.is_click = !(self.commentModel?.is_click!)!
                if (self.commentModel?.is_click!)!{
                    self.commentModel?.click_num = (self.commentModel?.click_num!)! + 1
                }else{
                    self.commentModel?.click_num = (self.commentModel?.click_num!)! - 1
                }
                self.configWith(commentModel: self.commentModel)
//                NotificationCenter.default.post(name: THUMBS_UP_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:videoModel])
            }
            Toast.showErrorWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    override func configWith(commentModel: CommentModel?) {
        super.configWith(commentModel: commentModel)
        self.commentModel = commentModel
        self.thumbsUpButton.setTitle(commentModel?.click_num?.suitableStringValue(), for: .normal)
        self.thumbsUpButton.isSelected = (commentModel?.is_click)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
