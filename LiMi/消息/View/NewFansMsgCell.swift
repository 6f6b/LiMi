//
//  NewFansMsgCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/26.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol NewFansMsgCellDelegate : class{
    func newFansMsgCell(cell:NewFansMsgCell,clickFollowButtonWith model:NewFansMsgModel?)
}
class NewFansMsgCell: UITableViewCell {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var relationshipButton: UIButton!
    weak var delegate:NewFansMsgCellDelegate?
    var model:NewFansMsgModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(addFollowButtonRefresh(notification:)), name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configWith(model:NewFansMsgModel){
        self.model = model
        if let _headPic = model.head_pic{
            self.headImageView.kf.setImage(with: URL.init(string: _headPic))
        }
        self.userName.text = model.nickname
        self.timeLabel.text = model.time
        //关注关系
        ///is_attention=0 未关注 1 已关注 2 互关注
        if model.is_attention == 0{
            relationshipButton.backgroundColor = APP_THEME_COLOR_2
            relationshipButton.setTitle("关注", for: .normal)
        }else if model.is_attention == 1{
            relationshipButton.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
            relationshipButton.setTitle("已关注", for: .normal)
        }else if model.is_attention == 2{
            relationshipButton.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
            relationshipButton.setTitle("互相关注", for: .normal)
        }
    }
    
    @IBAction func clickRelationshipButton(_ sender: Any) {
        self.delegate?.newFansMsgCell(cell: self, clickFollowButtonWith: self.model)
    }
    
    
    @objc func addFollowButtonRefresh(notification:Notification){
        if let userInfo = notification.userInfo{
            if let userId = userInfo[USER_ID_KEY] as? Int,let relationShip = userInfo[RELATIONSHIP_KEY] as? Int{
                if userId == self.model?.uid{
                    self.model?.is_attention = relationShip
                    self.configWith(model: self.model!)
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

