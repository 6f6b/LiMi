//
//  UserInfoModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/15.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class UserInfoModel: BaseModel {
    var nickname:String?
    var signature:String?
    ///0未认证 1认证中 2已认证 3 认证失败
    var is_access:Int?
    ///0学生认证 1 学霸认证
    var identity_type:Int?
    ///认证的标签名
    var identity_name:String?
    var attention_num:Int?
    var fans_num:Int?
    var click_num:Int?
    ///is_attention=0 未 1 已关注 2 互关注
    var is_attention:Int?
    
    var true_name:String?
    var sex:Int?
    ///
    var user_info_status:Int?
    var head_pic:String?
    //var school:String?
    var college:CollegeModel?
    var grade:String?
    
    var back_pic:String?
    var user_id:Int?
    
    //红包
    var money:Double?   //抢到的红包金额
    var uid:Int? //用户id
    
    //附近的人
    var content:String? //个性签名
    var distance:String? //距离
    var numSex:Int?
    
    var time:String?
    var id_code:String?
    var send_status:Int? //1,允许未关注的人发送消息  0相反
    var clickVL_status:Int?//1,公开喜欢的视频         0相反
    var fansL_status:Int?//1,公开粉丝列表           0 相反
    var attentionL_status:Int?//1,   公开关注列表    0 相反

    var city:CityModel?
    var birthday:Int?
    var photo:String?
    var target:[String]?
    var age:Int?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        is_attention <- map["is_attention"]
        attention_num <- map["attention_num"]
        click_num <- map["click_num"]
        fans_num <- map["fans_num"]

        is_access <- map["is_access"]
        identity_type <- map["identity_type"]
        identity_name <- map["identity_name"]
        signature <- map["signature"]
        nickname<-map["nickname"]
        true_name<-map["true_name"]
        user_info_status<-map["user_info_status"]
        sex<-map["sex"]
        head_pic<-map["head_pic"]
        //school<-map["school"]
        college<-map["college"]
        grade<-map["grade"]
        back_pic<-map["back_pic"]
        user_id<-map["user_id"]

        uid<-map["uid"]
        money<-map["money"]
        
        content <- map["content"]
        distance <- map["distance"]
        numSex <- map["sex"]
        
        time <- map["time"]
        id_code <- map["id_code"]
        
        send_status <- map["send_status"]
        clickVL_status <- map["clickVL_status"]
        fansL_status <- map["fansL_status"]
        attentionL_status <- map["attentionL_status"]
        city <- map["city"]
        birthday <- map["birthday"]
        photo <- map["photo"]
        target <- map["target"]
        age <- map["age"]
        
    }
}

//class FuckingUserInfoModel : UserInfoModel{
//
//}

class FoolishUserInfoModel: BaseModel {
    var age:Int?
    var city:String?
    var college:String?
    var constellation:String?
    var distance:String?
    var nickname:String?
    var photo:String?
    var sex:Int?
    var signature:String?
    var target:[String]?
    var user_id:Int?
    var active_time:String?
    
    required init?(map: Map) {
        super.init(map: map)
        
    }

    override func mapping(map: Map) {
        age <- map["age"]
        city <- map["city"]
        college <- map["college"]
        constellation <- map["constellation"]
        distance <- map["distance"]
        nickname <- map["nickname"]
        photo <- map["photo"]
        sex <- map["sex"]
        signature <- map["signature"]
        target <- map["target"]
        user_id <- map["user_id"]
        active_time <- map["active_time"]
    }
}
