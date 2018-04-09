//
//  BlackerCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class BlackerCell: UITableViewCell {
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
        if !AppManager.shared.checkUserStatus(){return}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let type:String? = "black"
        let moreOperation = MoreOperation(type: type, action_id: nil, user_id: self.userInfoModel?.user_id)
        _ = moyaProvider.rx.request(.targetWith(target: moreOperation)).subscribe(onSuccess: {[unowned self] (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                var moreOperationModel = MoreOperationModel()
                moreOperationModel.operationType = .cancelBlack
                moreOperationModel.user_id = self.userInfoModel?.user_id
                NotificationCenter.default.post(name: DID_MORE_OPERATION, object: nil, userInfo: [MORE_OPERATION_KEY:moreOperationModel])
            }
            Toast.showResultWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func configWith(model:UserInfoModel?){
        self.userInfoModel = model
        self.nickName.text = model?.nickname
        if let headPic = model?.head_pic{
            self.headPic.kf.setImage(with: URL.init(string: headPic), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        var info = ""
        if let college = model?.college{
            info.append(college)
        }
        if let fansNum = model?.fans_num{
            info.append("  粉丝  \(fansNum)")
        }
        self.infoLabel.text = info
        //self.refreshRelationshipBtnWith(userInfoModel: model)
    }
}
