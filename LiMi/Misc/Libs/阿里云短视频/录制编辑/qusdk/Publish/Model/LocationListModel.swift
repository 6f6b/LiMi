//
//  LocationListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class LocationListModel: BaseModel {
    var data:[LocationModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class LocationModel: BaseModel {
    var name:String?
    var distance:String?
    var position:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name<-map["name"]
        distance<-map["distance"]
        position<-map["position"]
    }
}
