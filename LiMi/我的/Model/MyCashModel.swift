//
//  MyCashModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/6.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class MyCashModel: BaseModel {
    var money:Double?
    var is_set_passwd:Int?
//    var content:
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        money<-map["data.money"]
        is_set_passwd<-map["data.is_set_passwd"]
    }
}

//class MyCashContentModel: Mappable {
//    var
//}

