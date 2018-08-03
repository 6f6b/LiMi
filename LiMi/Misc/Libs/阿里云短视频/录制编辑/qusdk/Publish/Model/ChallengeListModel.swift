//
//  ChallengeListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class ChallengeListModel: BaseModel {
    var data:[ChallengeModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class ChallengeModel: BaseModel {
    var challenge_id:Int?
    var challenge_name:String?
    var use_num:Int?
    var creator:UserInfoModel?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        challenge_id<-map["challenge_id"]
        challenge_name<-map["challenge_name"]
        use_num<-map["use_num"]
        creator <- map["creator"]
    }
}
