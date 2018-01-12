//
//  CollegeContainerModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/12.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class GradeContainerModel: BaseModel {
    var grades:[GradeModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        grades<-map["data"]
    }
}

class GradeModel: Mappable {
    var id:Int?
    var name:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id<-map["id"]
        name<-map["name"]
    }
}


