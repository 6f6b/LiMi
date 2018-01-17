//
//  BaseModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/11.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseModel:Mappable{
    var commonInfoModel:CommonInfoModel?
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        commonInfoModel = CommonInfoModel.init(map: map)
    }
    
}
