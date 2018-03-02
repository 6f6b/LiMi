//
//  WeekendTourDetailModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class WeekendTourDetailModel: BaseModel {
    var id:Int?  //
    var name:String?
    var feature:String?
    var content:String?
    var flow:String?    //流程
    var logo:String?    //商家log
    var price:Double?   //价格
    var cost:String?    //花费
    var from:String? //起点
    var to:String? //终点
    var pic:[String]?   //轮播
    var time:String?
    var shop_name:String? //商家名称
    var shop_address:String? //商家地址
    var shop_phone:String?//商家电话
    var create_time:String?
    var delete_time:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id<-map["data.id"]
        name<-map["data.name"]
        feature<-map["data.feature"]
        content<-map["data.content"]
        flow<-map["data.flow"]
        logo<-map["data.logo"]
        price<-map["data.price"]
        cost<-map["data.cost"]
        from<-map["data.from"]
        to <- map["data.to"]
        pic<-map["data.pic"]
        time<-map["data.time"]
        shop_name<-map["data.shop_name"]
        shop_address<-map["data.shop_address"]
        shop_phone<-map["data.shop_phone"]
        create_time<-map["data.create_time"]
        delete_time<-map["data.delete_time"]

    }
}
