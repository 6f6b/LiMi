//
//  SexModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/29.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class SexModel:Mappable {
    var sex:String?
    var id:Int?
    var isSelected = false
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        sex<-map["sex"]
        id <- map["id"]
    }
}
