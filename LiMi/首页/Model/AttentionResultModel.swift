//
//  AttentionResultModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/16.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class AttentionResultModel: BaseModel {
    var is_attention:Int?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        is_attention<-map["data.is_attention"]
    }
}
