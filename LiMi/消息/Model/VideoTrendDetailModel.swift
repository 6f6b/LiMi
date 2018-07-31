//
//  VideoTrendDetailModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/30.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class VideoTrendDetailModel: BaseModel {
    var data:VideoTrendModel?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}
