//
//  MusicListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/28.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class MusicListModel: BaseModel {
    var data:[MusicModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class MusicModel: BaseModel {
    var music_id:Int?
    var music_type:Int?
    var name:String?
    var pic:String?
    var music:String?
    var time:Int?
    var is_collect:Bool?
    var singer:String?
    var down_num:Int?
    

    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        music_id<-map["music_id"]
        music_type<-map["music_type"]
        name<-map["name"]
        pic<-map["pic"]
        music<-map["music"]
        time<-map["time"]
        is_collect<-map["is_collect"]
        singer <- map["singer"]
        down_num <- map["down_num"]
    }
}
