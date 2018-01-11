//
//  TmpAuthCodeModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/11.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import ObjectMapper

class TmpAuthCodeModel: BaseModel {
    var code:String?

    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        code<-map["data"]
    }
}
