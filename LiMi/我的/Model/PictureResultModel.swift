//
//  PictureResultModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/11.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class PictureResultModel: BaseModel {
    var url:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        url<-map["data.url"]
    }
}
