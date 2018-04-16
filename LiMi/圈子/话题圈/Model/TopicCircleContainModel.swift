//
//  TopicCircleModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class TopicCircleContainModel: BaseModel {
    var data:[TopicCircleModel]?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}


class TopicCircleModel: BaseModel {
    var id:Int?
    var status:Int?
    var user_id:Int?
    var title:String?
    var content:String?
    var head_pic:String?
    var nickname:String?
    var pics:[String]?
    var pics_num:Int?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id<-map["id"]
        status<-map["status"]
        user_id<-map["user_id"]
        title<-map["title"]
        content<-map["content"]
        head_pic<-map["head_pic"]
        nickname<-map["nickname"]
        pics<-map["pics"]
        pics_num<-map["pics_num"]
    }
}

