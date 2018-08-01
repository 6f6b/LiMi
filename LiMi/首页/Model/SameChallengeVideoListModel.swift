//
//  SameChallengeVideoListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/1.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class SameChallengeVideoListModel: BaseModel {
    var challenge:ChallengeModel?
    var video:[VideoTrendModel]?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        challenge<-map["data.challenge"]
        video<-map["data.video"]
    }
}
