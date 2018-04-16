//
//  SendRedPacketResultModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/5.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class SendRedPacketResultModel: BaseModel {
    var red_token:String?
    var money:Double?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        red_token<-map["data.red_token"]
        money<-map["data.money"]
    }
}
