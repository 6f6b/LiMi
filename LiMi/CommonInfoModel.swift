//
//  CommonInfoModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/11.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class CommonInfoModel:Mappable{
    var flag : String?
    var status:Int?
    var msg:String?
    
    required init?(map: Map) {
        self.mapping(map: map)
    }
    
    func mapping(map: Map) {
        flag  <- map["flag"]
        status   <- map["status"]
        msg   <- map["msg"]
    }
    
}
