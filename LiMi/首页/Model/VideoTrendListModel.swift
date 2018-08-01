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
    var time:Int?
    //var timestamp:Int?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data.data"]
        //time<-map["data.time"]
        time <- map["data.timestamp"]
    }
}

class VideoTrendModel: BaseModel {
    var click_num:Int?//
    var discuss_num:Int?//
    var id:Int?//
    var title:String?//
    var is_click:Bool?//
    var is_attention:Bool?//
    var music:MusicModel?
    var user:UserInfoModel?
    var video:VideoInfoModel?
    var notify_extra:[TextExtraModel]?
    var publish_addr:String? //": "zhongguo",
    var challenge_id:Int? //": 19,
    var challenge:String? //": "\u5ddd\u5927\u6444\u5f71\u6bd4\u8d5b",
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        click_num<-map["click_num"]
        discuss_num<-map["discuss_num"]
        id<-map["id"]
        title<-map["title"]
        is_click <- map["is_click"]
        is_attention <- map["is_attention"]
        music <- map["music"]
        user <- map["user"]
        video <- map["video"]
        notify_extra <- map["notify_extra"]
        publish_addr <- map["publish_addr"]
        challenge_id <- map["challenge_id"]
        challenge <- map["challenge"]
    }
}

class VideoInfoModel: BaseModel {
    var cover:String?
    var height:Int?
    var video:String?
    var width:Int?
    var v_create_time:String?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        cover<-map["cover"]
        height<-map["height"]
        video <- map["video"]
        width <- map["width"]
        v_create_time <- map["v_create_time"]
    }
}

class TextExtraModel: BaseModel {
    var id:Int?
    var text:String?
    var type:Int?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id<-map["id"]
        text<-map["text"]
        type <- map["type"]
    }
}





