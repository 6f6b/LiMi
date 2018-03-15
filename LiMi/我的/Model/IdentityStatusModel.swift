//
//  IdentityStatusModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/15.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class IdentityStatusModel: BaseModel {
    var identity_status:Int?
    var msg:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        msg<-map["msg"]
        identity_status<-map["identity_status"]
        let tmpIdentityStatus = Defaults[.userCertificationState]
        Defaults[.userCertificationState] = identity_status
        if tmpIdentityStatus != 2 && Defaults[.userCertificationState] == 2{
            //发通知
            NotificationCenter.default.post(name: IDENTITY_STATUS_OK_NOTIFICATION, object: nil)
        }
    }
}
