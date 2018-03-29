//
//  CollegeContainerModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/12.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class AcademyContainerModel: BaseModel {
    var academies:[AcademyModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        academies<-map["data"]
    }
}

class AcademyModel:ScreeningConditionsBaseModel, Mappable  {
    var collegeID:Int?
    var name:String?
    var scid:Int?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        collegeID<-map["collegeID"]
        name<-map["name"]
        scid<-map["scid"]
        id = scid
    }
}

