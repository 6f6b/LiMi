//
//  ChallengeWithVideosListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/3.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class ChallengeWithVideosListModel: BaseModel {
    var data:[ChallengeWithVideosModel]?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class ChallengeWithVideosModel: BaseModel {
    var challenge:ChallengeModel?
    var videos:[VideoTrendModel]?
    var timestamp:Int?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        challenge<-map["challenge"]
        videos <- map["video"]
    }
}


