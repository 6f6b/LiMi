//
//  UserDetailModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class UserDetailModel: BaseModel {
    var user:UserInfoModel?
    var action_list:[TrendModel]?
    var timestamp:Int?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        user<-map["data.user"]
        action_list<-map["data.action_list"]
        timestamp<-map["msg.timestamp"]
    }
}
