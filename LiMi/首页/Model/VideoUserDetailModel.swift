//
//  VideoUserDetailModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/7.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class VideoUserDetailModel: BaseModel {
    var user:UserInfoModel?
    var video_list:[VideoTrendModel]?
    var timestamp:Int?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        user<-map["data.data.user"]
        video_list<-map["data.data.video_list"]
        timestamp<-map["data.timestamp"]
    }
}
