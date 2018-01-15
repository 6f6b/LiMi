//
//  IdentityInfoModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/15.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class IdentityInfoModel: BaseModel {
    var true_name:String?
    var sex:String?
    var head_pic:String?
    var college:CollegeModel?
    var school:AcademyModel?
    var grade:GradeModel?
    var identity_status:Int?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        true_name<-map["data.true_name"]
        sex<-map["data.sex"]
        head_pic<-map["data.head_pic"]
        college<-map["data.college"]
        school<-map["data.school"]
        grade<-map["data.grade"]
        identity_status<-map["data.identity_status"]
    }
}
