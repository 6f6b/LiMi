//
//  QNUploadTokenModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/30.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class QNUploadTokenModel: BaseModel {
    var token:String?
    var size:Int?
    var type:String?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        token<-map["data.token"]
        size<-map["data.size"]
        type<-map["data.type"]
    }
}
