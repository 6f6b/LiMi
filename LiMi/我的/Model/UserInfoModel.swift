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
    var true_name:String?
    var sex:String?
    ///
    var user_info_status:Int?
    var head_pic:String?
    var school:String?
    var college:String?
    var grade:String?
    
    var back_pic:String?
    var user_id:Int?
    
    //红包
    var money:Double?   //抢到的红包金额
    var uid:String? //用户id
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        true_name<-map["true_name"]
        user_info_status<-map["user_info_status"]
        sex<-map["sex"]
        head_pic<-map["head_pic"]
        school<-map["school"]
        college<-map["college"]
        grade<-map["grade"]
        back_pic<-map["back_pic"]
        user_id<-map["user_id"]
    }
}
