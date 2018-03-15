//
//  LoginModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/11.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import ObjectMapper

class LoginModel: BaseModel {
    var id:Int?
    var token:String?
//    identity_status        0 ：未认证   1：认证中  2：认证完成  3：认证失败
//    user_info_status     0:只注册了手机号  1：完善了性别真实姓名和头像  2：完善了身份认证
    var user_info_status:Int?
    var identity_status:Int?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id<-map["data.id"]
        token<-map["data.token"]
        user_info_status<-map["data.user_info_status"]
        identity_status<-map["data.identity_status"]
        let tmpIdentityStatus = Defaults[.userCertificationState]
        Defaults[.userCertificationState] = identity_status
        Defaults[.userId] = id
        Defaults[.userToken] = token
        
        if tmpIdentityStatus != 2 && Defaults[.userCertificationState] == 2{
            //发通知
            NotificationCenter.default.post(name: IDENTITY_STATUS_OK_NOTIFICATION, object: nil)
        }
        
    }
}

