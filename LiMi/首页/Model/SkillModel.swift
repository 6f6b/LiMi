//
//  SkillModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/29.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class SkillModel:Mappable {
    var id:Int?
    var skill:String?
    var isSelected = false
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id<-map["id"]
        skill<-map["skill"]
    }
}
