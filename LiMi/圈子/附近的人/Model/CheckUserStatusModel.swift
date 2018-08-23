//
//  CheckUserStatusModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/22.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class CheckUserStatusModel: BaseModel {
    var status:Int?
    var msg:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        status<-map["data.status"]
        msg<-map["data.msg"]
    }
}
