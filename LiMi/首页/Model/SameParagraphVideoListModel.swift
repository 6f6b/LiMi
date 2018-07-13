//
//  SameParagraphVideoListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/9.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class SameParagraphVideoListModel: BaseModel {
    var music:MusicModel?
    var video:[VideoTrendModel]?
    var time:Int?
    var original_video:[VideoTrendModel]?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        music<-map["data.data.music"]
        video<-map["data.data.video"]
        original_video <- map["data.data.original_video"]
        time<-map["data.time"]
    }
}
