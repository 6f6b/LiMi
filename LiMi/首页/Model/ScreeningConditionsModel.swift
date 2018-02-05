//
//  ScreeningConditionsModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/29.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class ScreeningConditionsModel: BaseModel {
    var college:[CollegeModel]?
    var grade:[GradeModel]?
    var academy:[AcademyModel]?
    var sex:[SexModel]?
    var skill:[SkillModel]?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        college<-map["data.college"]
        grade<-map["data.grade"]
        academy<-map["data.academy"]
        sex<-map["data.sex"]
        skill<-map["data.skill"]
    }
}
