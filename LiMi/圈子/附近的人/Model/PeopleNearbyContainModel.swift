//
//  PeopleNearbyContainModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class PeopleNearbyContainModel: BaseModel {
    var data:[UserInfoModel]?

    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}
