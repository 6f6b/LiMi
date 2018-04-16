//
//  SkillListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/30.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class SkillListModel: BaseModel {
    var skills:[SkillModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        skills<-map["data"]
    }
}
