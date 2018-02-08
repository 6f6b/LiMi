//
//  SignedResultModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/6.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

//签名结果
import Foundation
import ObjectMapper

class SignedResultModel: BaseModel {
    /// 支付宝签名字符串
    var alipay_signed_str:String?
    
    /****微信部分***/
    var noncestr:String?
    var package:String?
    var partnerid:String?
    var prepayid:String?
    var sign:String?
    var timestamp:UInt32?

    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        alipay_signed_str<-map["data"]
        
        noncestr<-map["data.noncestr"]
        package<-map["data.package"]
        partnerid<-map["data.partnerid"]
        prepayid<-map["data.prepayid"]
        sign<-map["data.sign"]
        timestamp<-map["data.timestamp"]
    }
}
