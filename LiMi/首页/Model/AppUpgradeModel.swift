//
//  AppUpgradeModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/24.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class AppUpgradeModel: BaseModel {
    var status:Int?
    ///0：可选更新 1：强制更新 2：不需要更新
    var update:Int?
    var content:[String]?
    var update_url:String?
    var version:String?

    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        status<-map["data.update.status"]
        update<-map["data.update.update"]
        content<-map["data.update.version.data.content"]
        update_url<-map["data.update.version.data.update_url"]
        version<-map["data.update.version.data.version"]
    }
}
