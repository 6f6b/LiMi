//
//  AlipayResultModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/7.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

class AlipayResultContainModel: Mappable {
    var resultStatus:String?
    var result:AlipayResultModel?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        resultStatus<-map["resultStatus"]

        var resultJsonStr:String?
        resultJsonStr <- map["result"]
        if let _resultJsonStr = resultJsonStr{
            result = Mapper<AlipayResultModel>().map(JSONString: _resultJsonStr)
        }
    }
}

class AlipayResultModel: Mappable {
    var alipay_trade_app_pay_response:AlipayTradeAppPayResponse?
    var sign:String?
    var sign_type:String?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        alipay_trade_app_pay_response <- map["alipay_trade_app_pay_response"]
        sign <- map["sign"]
        sign_type <- map["sign_type"]
    }
}

class AlipayTradeAppPayResponse: Mappable {
    var app_id:String?
    var auth_app_id:String?
    var charset:String?
    var code:String?
    var msg:String?
    ///外部交易编号
    var out_trade_no:String?
    var seller_id:String?
    var timestamp:String?
    var total_amount:String?
    /// 交易流水号
    var trade_no:String?

    required init?(map: Map) {
        app_id <- map["app_id"]
        auth_app_id <- map["auth_app_id"]
        charset <- map["charset"]
        code <- map["msg"]
        msg <- map["msg"]
        out_trade_no <- map["out_trade_no"]
        seller_id <- map["seller_id"]
        timestamp <- map["timestamp"]
        total_amount <- map["total_amount"]
        trade_no <- map["trade_no"]
    }
    
    func mapping(map: Map) {
        
    }
}
