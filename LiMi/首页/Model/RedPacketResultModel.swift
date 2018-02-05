//
//  RedPacketResultModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class RedPacketResultModel: BaseModel {
    var data_list:[PersonCatchedRedPacketModel]?
    var my_self:PersonCatchedRedPacketModel?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data_list<-map["data.data_list"]
        my_self<-map["data.self"]
    }
}

class PersonCatchedRedPacketModel:Mappable {
    var head_pic:String?
    var money:Double?
    var true_name:String?
    var uid:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        head_pic<-map["head_pic"]
        money<-map["money"]
        true_name<-map["true_name"]
        uid<-map["uid"]

    }
}
