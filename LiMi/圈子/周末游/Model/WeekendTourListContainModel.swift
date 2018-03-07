//
//  WeekendTourListContainModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class WeekendTourListContainModel: BaseModel {
    var data:[WeekendTourModel]?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class WeekendTourModel: BaseModel {
    var feature:String?
    var id:Int?
    var name:String?
    var num:Int?
    var pic:String?
    var price:Double?
    var time:String?
    var to:String?

    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        feature<-map["feature"]
        id<-map["id"]
        name<-map["name"]
        num<-map["num"]
        pic<-map["pic"]
        price<-map["price"]
        time<-map["time"]
        to<-map["to"]
        
        if self.feature == nil{
            feature <- map["data.feature"]
        }
        if self.name == nil{
            name <- map["data.name"]
        }
        if self.pic == nil{
            pic <- map["data.pic"]
        }
        if self.price == nil{
            price <- map["data.price"]
        }
    }
}
