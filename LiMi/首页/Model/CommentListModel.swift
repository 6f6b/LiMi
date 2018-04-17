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
    var back_pic:String?
    var school:String?
    var sex:String?
    var true_name:String?
    var nickname:String?
    var user_id:Int?
    var user_info_status:Int?
    
    ///子评论
    var child:[SubCommentModel]?
    var child_num:Int?
    var delete_time:String?
    ///所属评论组
    var group_id:Int?
    ///评论id
    var id:Int?
    ///父级评论id
    var parent_id:Int?
    ///父级评论人名字
    var parent_name:String?
    ///父级评论人id
    var parent_uid:Int?
    
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
        back_pic <- map["back_pic"]
        school<-map["school"]
        sex<-map["sex"]
        true_name<-map["true_name"]
        nickname <- map["nickname"]
        user_id<-map["user_id"]
        user_info_status<-map["user_info_status"]
        
        child<-map["child"]
        child_num<-map["child_num"]
        delete_time<-map["delete_time"]
        group_id<-map["group_id"]
        id<-map["id"]
        parent_id<-map["parent_id"]
        parent_name<-map["parent_name"]
        parent_uid<-map["parent_uid"]
    }
}

class SubCommentModel: BaseModel {
    var action_id:Int?
    var college:String?
    var content:String?
    var create_time:String?
    var grade:String?
    var head_pic:String?
    var back_pic:String?
    var school:String?
    var sex:String?
    var true_name:String?
    var nickname:String?
    var user_id:Int?
    var user_info_status:Int?
    
    var delete_time:String?
    ///所属评论组
    var group_id:Int?
    ///评论id
    var id:Int?
    ///父级评论id
    var parent_id:Int?
    ///父级评论人名字
    var parent_name:String?
    ///父级评论人id
    var parent_uid:Int?
    
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
        back_pic <- map["back_pic"]
        school<-map["school"]
        sex<-map["sex"]
        true_name<-map["true_name"]
        nickname <- map["nickname"]
        user_id<-map["user_id"]
        user_info_status<-map["user_info_status"]
        
        delete_time<-map["delete_time"]
        group_id<-map["group_id"]
        id<-map["id"]
        parent_id<-map["parent_id"]
        parent_name<-map["parent_name"]
        parent_uid<-map["parent_uid"]
    }
}
