//
//  TransactonModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/29.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class TransactonListModel: BaseModel {
    var datas:[TransactionModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        datas<-map["data"]
    }
}

class TransactionModel:Mappable{
    var des:String?
    var money:String?
    var time:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        des<-map["des"]
        money<-map["money"]
        time<-map["time"]
    }
}

