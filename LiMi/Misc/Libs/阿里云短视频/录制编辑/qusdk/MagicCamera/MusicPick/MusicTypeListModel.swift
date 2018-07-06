//
//  MusicTypeListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class MusicTypeListModel: BaseModel {
    var data:[MusicTypeModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class MusicTypeModel: BaseModel {
    var type:Int?
    var m_id:Int?
    var name:String?
    
    
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        type<-map["type"]
        m_id<-map["m_id"]
        name<-map["name"]
    }
}
