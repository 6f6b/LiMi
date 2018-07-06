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
    
    var startTime:Float = 0
    var duration:Float{
        get{
            let _time = self.time ?? 0
            var _duration = (Float(_time) - startTime)
            if _duration <= 0{_duration = 0.0}
            return _duration
        }
    }
//    "music_id":25,
//    "music_type":0,
//    "name":"G.G(张思源) - 给陌生的你听",
//    "pic":"http://oss.youhongtech.com/music/pic/20180619/1529379747_9936.jpg",
//    "music":"http://oss.youhongtech.com/music/music/20180619/1529379746_8283.mp3",
//    "time":24,
//    "is_collect":1
    
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
    }
}
