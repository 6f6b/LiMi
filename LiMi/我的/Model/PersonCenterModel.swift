//
//  PersonCenterModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/15.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class PersonCenterModel: BaseModel {
    var user_info:UserInfoModel?
    var is_access:IdentityStatusModel?
    
    var feedback:String?
    
    /// 我的现金
    var money:Double?
    
    /// 我的动态数
    var my_action:Int?
    var with_limi:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        user_info<-map["data"]
    }
}
