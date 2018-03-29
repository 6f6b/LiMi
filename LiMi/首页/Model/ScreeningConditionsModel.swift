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
    var datas = [[ScreeningConditionsBaseModel]]()
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
        //0
        var colleges = [ScreeningConditionsBaseModel]()
        if let _colleges = self.college{
            for college in _colleges{
                colleges.append(college)
            }
        }
        datas.append(colleges)
        //1
        var academys = [ScreeningConditionsBaseModel]()
        if let _academys = self.academy{
            for academy in _academys{
                academys.append(academy)
            }
        }
        datas.append(academys)
        //2
        var grades = [ScreeningConditionsBaseModel]()
        if let _grades = self.grade{
            for grade in _grades{
                grades.append(grade)
            }
        }
        datas.append(grades)
        //3
        var sexs = [ScreeningConditionsBaseModel]()
        if let _sexs = self.sex{
            for sex in _sexs{
                sexs.append(sex)
            }
        }
        datas.append(sexs)
        //4
        var skills = [ScreeningConditionsBaseModel]()
        if let _skills = self.skill{
            for skill in _skills{
                skills.append(skill)
            }
        }
        datas.append(skills)
    }
}
