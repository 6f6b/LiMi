//
//  FollowerCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/4.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class FollowerCell: UITableViewCell {
    @IBOutlet weak var headPic: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var relationshipBtn: UIButton!
    
    var userInfoModel:UserInfoModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    @IBAction func dealTapRelationshipBtn(_ sender: Any) {
//        AddAttention
        if self.userInfoModel?.is_attention == 0{
            self.dealChangeRelationship()
        }else{
            let popViewForChooseToUnFollow = PopViewForChooseToUnFollow.init(frame: SCREEN_RECT)
            popViewForChooseToUnFollow.tapRightBlock = {[unowned self] () in
                self.dealChangeRelationship()
            }
            popViewForChooseToUnFollow.show()
        }
    }
    
    func dealChangeRelationship(){
        if let userId = self.userInfoModel?.user_id{
            Toast.showStatusWith(text: nil)
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            let addAttention = AddAttention.init(attention_id: userId)
            _ = moyaProvider.rx.request(.targetWith(target: addAttention)).subscribe(onSuccess: {[unowned self] (response) in
                let personCenterModel = Mapper<PersonCenterModel>().map(jsonData: response.data)
                if personCenterModel?.commonInfoModel?.status == successState{
                    NotificationCenter.default.post(name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil, userInfo: [USER_ID_KEY:self.userInfoModel?.user_id,RELATIONSHIP_KEY:personCenterModel?.user_info?.is_attention])
                }
                Toast.showErrorWith(model: personCenterModel)
                }, onError: { (error) in
                    Toast.showErrorWith(msg: error.localizedDescription)
            })
        }
    }
    
    func configWith(model:UserInfoModel?){
        self.userInfoModel = model
        self.nickName.text = model?.nickname
        if let headPic = model?.head_pic{
            self.headPic.kf.setImage(with: URL.init(string: headPic), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        var info = ""
        if let college = model?.college?.name{
            info.append(college)
        }
        if let fansNum = model?.fans_num{
            info.append("  粉丝  \(fansNum)")
        }
        self.infoLabel.text = info
        self.refreshRelationshipBtnWith(userInfoModel: model)
    }
    
    func refreshRelationshipBtnWith(userInfoModel:UserInfoModel?){
        if let _isAttention = userInfoModel?.is_attention{
            //is_attention=0 未 1 已关注 2 互关注
            if _isAttention == 0{
                self.relationshipBtn.setTitleColor(UIColor.white, for: .normal)
                self.relationshipBtn.setImage(UIImage.init(named: "ic_tjgz"), for: .normal)
                self.relationshipBtn.backgroundColor = APP_THEME_COLOR
                self.relationshipBtn.setTitle("关注", for: .normal)
                self.relationshipBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -5, bottom: 0, right: 0)
                self.relationshipBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 0)
            }
            if _isAttention == 1{
                self.relationshipBtn.setTitleColor(RGBA(r: 153, g: 153, b: 153, a: 1), for: .normal)
                self.relationshipBtn.setImage(nil, for: .normal)
                self.relationshipBtn.backgroundColor = RGBA(r: 238, g: 238, b: 238, a: 1)
                self.relationshipBtn.setTitle("已关注", for: .normal)
                self.relationshipBtn.imageEdgeInsets = UIEdgeInsets.zero
                self.relationshipBtn.titleEdgeInsets = UIEdgeInsets.zero
            }
            if _isAttention == 2{
                self.relationshipBtn.setTitleColor(RGBA(r: 153, g: 153, b: 153, a: 1), for: .normal)
                self.relationshipBtn.setImage(nil, for: .normal)
                self.relationshipBtn.backgroundColor = RGBA(r: 238, g: 238, b: 238, a: 1)
                self.relationshipBtn.setTitle("互相关注", for: .normal)
                self.relationshipBtn.imageEdgeInsets = UIEdgeInsets.zero
                self.relationshipBtn.titleEdgeInsets = UIEdgeInsets.zero
            }
        }
    }
}
