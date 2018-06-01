//
//  UploadVideoCertificateModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/30.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class UploadVideoCertificateModel: BaseModel {
    var address:String?
    var auth:String?
    var authDecode:AuthDecode?
    var requestId:String?
    var vdeoId:String?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        address<-map["data.address"]
        auth<-map["data.auth"]
        authDecode<-map["data.authDecode"]
        requestId<-map["data.requestId"]
        vdeoId<-map["data.vdeoId"]

    }
}

class AuthDecode: BaseModel {
    var AccessKeyId:String?
    var AccessKeySecret:String?
    var Expiration:String?
    var SecurityToken:String?

    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        AccessKeyId<-map["AccessKeyId"]
        AccessKeySecret<-map["AccessKeySecret"]
        Expiration<-map["Expiration"]
        SecurityToken<-map["SecurityToken"]

    }
}
