//
//  CommentListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class CommentListModel: BaseModel {
    var comments:[CommentModel]?
    var trend:TrendModel?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        comments<-map["data.discuss"]
        trend<-map["data.action"]
    }
}

class CommentModel: BaseModel {
    var action_id:Int?
    var college:String?
    var content:String?
    var create_time:String?
    var grade:String?
    var head_pic:String?
    var school:String?
    var sex:String?
    var true_name:String?
    var user_id:Int?
    var user_info_status:Int?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        action_id<-map["action_id"]
        college<-map["college"]
        content<-map["content"]
        create_time<-map["create_time"]
        grade<-map["grade"]

        head_pic<-map["head_pic"]
        school<-map["school"]
        sex<-map["sex"]
        true_name<-map["true_name"]
        user_id<-map["true_name"]
        user_info_status<-map["user_info_status"]

    }
}

