//
//  IMModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class IMModel: BaseModel {
    var token:String?
    var accid:String?
    var name:String?
    var private_message_status:Int?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        token<-map["data.token"]
        accid<-map["data.accid"]
        name<-map["data.name"]
        private_message_status <- map["data.private_message_status"]
        //"private_message_status": 0    禁止发送私信
        //"private_message_status": 1    允许发送私信
    }
}

