//
//  TopicsContainModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class TopicsContainModel: BaseModel {
    var actionList:[TrendModel]?
    var topicCircleModel:TopicCircleModel?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        actionList<-map["data.actionList"]
        topicCircleModel <- map["data.topic"]
    }
}
