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
    var create_time:String?
    var delete_time:String?
    var down_num:Int?
    var id:Int?
    var music:String?
    var name:String?
    var pic:String?
    var startTime:Float?
    var duration:Float?


    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        create_time<-map["create_time"]
        delete_time<-map["delete_time"]
        down_num<-map["down_num"]
        id<-map["id"]
        music<-map["music"]
        name<-map["name"]
        pic<-map["pic"]
        duration <- map["time"]
    }
}
