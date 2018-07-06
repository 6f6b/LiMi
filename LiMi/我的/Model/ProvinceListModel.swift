//
//  ProvinceListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/2.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class ProvinceListModel: BaseModel {
    var data:[ProvinceModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class ProvinceModel: BaseModel {
    var id:Int?
    var name:String?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id<-map["id"]
        name<-map["name"]

    }
}
