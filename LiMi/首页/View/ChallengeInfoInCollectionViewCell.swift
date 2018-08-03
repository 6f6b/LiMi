//
//  ChallengeInfoInCollectionViewCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/1.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol ChallengeInfoInCollectionViewCellDelegate : class {
    ///点击了头像
    func challengeInfoInCollectionViewCell(cell:ChallengeInfoInCollectionViewCell,clickHeadImageWith model:ChallengeModel?)
    ///点击了关注
    func challengeInfoInCollectionViewCell(cell:ChallengeInfoInCollectionViewCell,clickFollowButtonWith model:ChallengeModel?,followButton:UIButton)
    ///点击了人名
    func challengeInfoInCollectionViewCell(cell:ChallengeInfoInCollectionViewCell,clickUserNameWith model:ChallengeModel?)
}
class ChallengeInfoInCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var headPic: UIImageView!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var initialChallenger: UIButton!
    @IBOutlet weak var useNum: UILabel!
    var challengeModel:ChallengeModel?
    weak var delegate:ChallengeInfoInCollectionViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.headPic.isUserInteractionEnabled = true
        let tapHeadPicGes = UITapGestureRecognizer.init(target: self, action: #selector(tapedHeadPic))
        self.headPic.addGestureRecognizer(tapHeadPicGes)
        
        self.followBtn.addTarget(self, action: #selector(tapedFollowButton), for: .touchUpInside)
        self.initialChallenger.addTarget(self, action: #selector(tapedUserName), for: .touchUpInside)
    }

    //MARK: - actions
    @objc func tapedHeadPic(){
        self.delegate?.challengeInfoInCollectionViewCell(cell: self, clickHeadImageWith: self.challengeModel)
    }
    
    @objc func tapedFollowButton(){
        self.delegate?.challengeInfoInCollectionViewCell(cell: self, clickFollowButtonWith: self.challengeModel, followButton: self.followBtn)
    }
    
    @objc func tapedUserName(){
        self.delegate?.challengeInfoInCollectionViewCell(cell: self, clickUserNameWith: self.challengeModel)
    }
    
    func configWith(model:ChallengeModel?){
        self.challengeModel = model
        if let _headPic = model?.creator?.head_pic{
            self.headPic.kf.setImage(with: URL.init(string: _headPic))
        }
        if model?.creator?.is_attention == 0{
            self.followBtn.isHidden = false
        }else{
            self.followBtn.isHidden = true
        }
        if let _challenger = model?.creator?.nickname{
            self.initialChallenger.setTitle("@\(_challenger)", for: .normal)
        }
        if let _useNum = model?.use_num{
            self.useNum.text = "-  \(_useNum)人使用  -"
        }
    }
}
