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
    var status:String?
    var identity_time:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id<-map["data.id"]
        token<-map["data.token"]
        status<-map["data.status"]
        identity_time<-map["data.identity_time"]
    }
}

