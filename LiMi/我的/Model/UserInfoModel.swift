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
    var is_access:Int?
    var attention_num:Int?
    var fans_num:Int?
    var click_num:Int?
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
    var send_status:Bool? //1,允许未关注的人发送消息  0相反
    var clickVL_status:Bool?//1,公开喜欢的视频         0相反
    var fansL_status:Bool?//1,公开粉丝列表           0 相反
    var attentionL_status:Bool?//1,   公开关注列表    0 相反

    var city:CityModel?
    var birthday:Int?
    var constellation:String?
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
        constellation <- map["constellation"]
        age <- map["age"]
    }
}

//class AreaModel: BaseModel? {
//    var city:C
//}
