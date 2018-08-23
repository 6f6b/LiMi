//
//  ScreeningFiltersModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/22.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class ScreeningFiltersModel: BaseModel {
    var target_age:String?
    var target_distance:Int?
    var target_list:[NearbyPurposeModel]?
    var target_sex:Int?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        target_age<-map["data.target_age"]
        target_distance<-map["data.target_distance"]
        target_list<-map["data.target_list"]
        target_sex<-map["data.target_sex"]
    }
}
