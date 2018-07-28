//
//  NewFansMsgModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/27.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class NewFansMsgListModel: BaseModel {
    var data:[NewFansMsgModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class NewFansMsgModel: BaseModel {
    var uid:Int?
    var head_pic:String?
    var nickname:String?
    var time:String?
    ///is_attention=0 未 1 已关注 2 互关注
    var is_attention:Int?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        uid<-map["uid"]
        head_pic<-map["head_pic"]
        nickname<-map["nickname"]
        time<-map["time"]
        is_attention<-map["is_attention"]

    }
}
