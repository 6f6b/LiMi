//
//  NearbyPurposeListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/17.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

//"target_list":Array[10],
//"user":Object{...}

class NearbyPurposeInfo: BaseModel {
    var target_list:[NearbyPurposeModel]?
    var user:UserInfoModel?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        target_list<-map["data.target_list"]
        user<-map["data.user"]
    }
}

class NearbyPurposeListModel: BaseModel {
    var autograph:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        autograph<-map["data"]
    }
}

class NearbyPurposeModel: BaseModel {
    var id:Int?
    var name:String?
    var image:String?
    var selected:Bool?

    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id<-map["id"]
        name<-map["name"]
        image<-map["image"]
        selected<-map["selected"]

    }
}
