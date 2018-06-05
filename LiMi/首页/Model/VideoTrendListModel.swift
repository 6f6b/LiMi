//
//  VideoTrendListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class VideoTrendListModel: BaseModel {
    var data:[VideoTrendModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class VideoTrendModel: BaseModel {
    var click_num:Int?
    var discuss_num:Int?
    var id:Int?
    var music_id:Int?
    var music_name:String?
    var music_pic:String?
    var tags:String?
    var title:String?
    var user_head_pic:String?
    var user_id:Int?
    var user_nickname:String?
    var video:String?
    var video_cover:String?
    var view_num:Int?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        click_num<-map["click_num"]
        discuss_num<-map["discuss_num"]
        id<-map["id"]
        music_id<-map["music_id"]
        music_name<-map["music_name"]
        music_pic<-map["music_pic"]
        tags<-map["tags"]
        title<-map["title"]
        user_head_pic<-map["user_head_pic"]
        user_id<-map["user_id"]
        user_nickname<-map["user_nickname"]
        video<-map["video"]
        video_cover<-map["video_cover"]
        view_num<-map["view_num"]

    }
}

