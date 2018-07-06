//
//  CityListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/2.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class CityListModel: BaseModel {
    var data:[CityModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class CityModel: BaseModel {
    var id:Int?
    var province:ProvinceModel?
    var name:String?

    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id<-map["id"]
        province<-map["province"]
        name<-map["name"]
    }
}

//class AreaModel: BaseModel {
//    var id:Int?
//    var city:CityModel?
//    var name:String?
//    
//    required init?(map: Map) {
//        super.init(map: map)
//    }
//    
//    override func mapping(map: Map) {
//        super.mapping(map: map)
//        id<-map["id"]
//        city<-map["city"]
//        name<-map["name"]
//    }
//}


