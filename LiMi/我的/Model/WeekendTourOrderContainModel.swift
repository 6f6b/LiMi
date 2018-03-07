//
//  WeekendTourOrderContainModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class WeekendTourOrderContainModel: BaseModel {
    var data:[WeekendTourOrderModel]?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class WeekendTourOrderModel: BaseModel {
    var pic:String?
    var shop_order_no:String?
    var order_id:Int?
    var weekend_id:Int?
    var user_id:Int?
    var name:String?
    var feature:String?
    var time:String?
    var to:String?
    var money:Double?
    var num:Int?
    var order_status:Int?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        pic <- map["pic"]
        shop_order_no <- map["shop_order_no"]
        order_id <- map["order_id"]
        weekend_id <- map["weekend_id"]
        user_id <- map["user_id"]
        name <- map["name"]
        feature <- map["feature"]
        time <- map["time"]
        to <- map["to"]
        money <- map["money"]
        num <- map["num"]
        order_status <- map["order_status"]
        
    }
}
