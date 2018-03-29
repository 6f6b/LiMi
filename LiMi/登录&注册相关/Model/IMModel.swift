//
//  IMModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class IMModel: BaseModel {
    var token:String?
    var accid:String?
    var name:String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        token<-map["data.token"]
        accid<-map["data.accid"]
        name<-map["data.name"]
    }
}
//"token": "4a9621e6fe00906b585466f48b979fc5",
//"accid": "4",
//"name": "Feng"

