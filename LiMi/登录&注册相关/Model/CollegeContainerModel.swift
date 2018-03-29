//
//  CollegeContainerModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/12.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper
protocol WithSelectProtocol {
    var isSelected:Bool{get set}
}

class CollegeContainerModel: BaseModel {
    var colleges:[CollegeModel]?
    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        colleges<-map["data"]
    }
}

class CollegeModel:ScreeningConditionsBaseModel, Mappable {
    var coid:Int?
    var name:String?
    var provinceID:Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        coid<-map["coid"]
        name<-map["name"]
        provinceID<-map["provinceID"]
        id = coid
    }
}
