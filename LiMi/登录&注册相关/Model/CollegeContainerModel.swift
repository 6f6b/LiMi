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

protocol Copyable {
    func copy()->Copyable?
}

class CollegeModel:Mappable {
    var id:Int?
    var name:String?
    var provinceID:Int?
    var b_g:BoysAndGirlsProportionModel?
    var click_num:Int?
    var is_click:Bool?

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name<-map["name"]
        provinceID<-map["provinceID"]
        b_g <- map["b_g"]
        click_num <- map["click_num"]
        is_click <- map["is_click"]
    }
}

extension CollegeModel : Copyable{
    func copy() -> Copyable?{
        let collegeModel = CollegeModel.init(map: Map.init(mappingType: .fromJSON, JSON: ["":""]))
        collegeModel?.id = self.id
        collegeModel?.name = self.name
        collegeModel?.provinceID = self.provinceID
        collegeModel?.b_g = self.b_g?.copy() as? BoysAndGirlsProportionModel
        collegeModel?.click_num = self.click_num
        collegeModel?.is_click = self.is_click

        return collegeModel
    }
}



class BoysAndGirlsProportionModel:Mappable {
    var b:Int?
    var g:Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        b <- map["b"]
        g<-map["g"]
    }
}

extension BoysAndGirlsProportionModel : Copyable{
    func copy() -> Copyable? {
        let boysAndGirlsProportionModel = BoysAndGirlsProportionModel.init(map: Map.init(mappingType: .fromJSON, JSON: ["":""]))
        boysAndGirlsProportionModel?.b = self.b
        boysAndGirlsProportionModel?.g = self.g
        return boysAndGirlsProportionModel
    }
}
