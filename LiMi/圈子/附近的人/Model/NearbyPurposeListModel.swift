//
//  NearbyPurposeListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/17.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class NearbyPurposeListModel: BaseModel {
    var autograph:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        autograph<-map["data"]
    }
}

class NearbyPurposeModel: BaseModel {
    var autograph:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        autograph<-map["data"]
    }
}
