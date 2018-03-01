//
//  TrendListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class TrendsListModel: BaseModel {
    var trends:[TrendModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        trends<-map["data"]
    }
}

class TrendModel: BaseModel {
    var action_id:Int?
    var action_pic:[String]?
    var action_pic_num:Int?
    var action_video:String?
    var click_num:Int?  //点赞数
    var college:String?
    var content:String?
    var create_time:String?
    var discuss_num:Int?
    var head_pic:String?
    var isred:String?
    var school:String?
    var sex:String?
    var skill:String?   //标签
    var true_name:String?
    var user_id:Int?
    var view_num:String?   //浏览人数
    var is_click:Int?   //0：未点赞，1：已点赞
    var is_over:Int?    //0：没有抢光，1：已经抢光
    var red_token:String?
    var red_type:String?
    
    //话题部分
    var pic:String?
    var topic_action_id:Int?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        action_id<-map["action_id"]
        action_pic<-map["action_pic"]
        action_pic_num<-map["action_pic_num"]
        action_video<-map["action_video"]
        click_num<-map["click_num"]
        college<-map["college"]
        content<-map["content"]
        create_time<-map["create_time"]
        discuss_num<-map["discuss_num"]
        head_pic<-map["head_pic"]
        isred<-map["isred"]
        school<-map["school"]
        sex<-map["sex"]
        skill<-map["skill"]
        true_name<-map["true_name"]
        user_id<-map["user_id"]
        view_num<-map["view_num"]
        is_click<-map["is_click"]
        is_over<-map["is_over"]
        red_token<-map["red_token"]
        red_type<-map["red_type"]
        
        pic <- map["pic"]
        topic_action_id <- map["topic_action_id"]
        
        if (nil == self.action_pic || self.action_pic?.count == 0) && self.pic != nil{
            if self.pic!.lengthOfBytes(using: String.Encoding.utf8) >= 5{
                self.action_pic = [self.pic!]
            }
        }
        if nil == self.action_id && self.topic_action_id != nil{
            self.action_id = self.topic_action_id
        }
    }
}










