//
//  DefaultsKeysExtension.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys{
    ///存储用户手机号
    static let userPhone = DefaultsKey<String?>("userPhoneNum")
    
    /// 存储用户ID
    static let userId = DefaultsKey<Int?>("userId")
    ///存储用户token
    static let userToken = DefaultsKey<String?>("userToken")
    ///存储用户性别
    static let userSex = DefaultsKey<String?>("userSex")
    ///0未认证，1认证中，2认证成功，3认证失败
    static let userCertificationState = DefaultsKey<Int?>("userCertificationState")
    ///用户im token
    static let userImToken = DefaultsKey<String?>("userImToken")
    ///用户accid
    static let userAccid = DefaultsKey<String?>("userAccid")
    
    ///是否第一次进入附近的人
    static let isFirstTimeToNearbyPerson = DefaultsKey<Bool?>("isFirstTimeToNearbyPerson")
    ///是否提醒过没认证
    static let isMindedNotAuthenticated = DefaultsKey<Bool?>("isMindedNotAuthenticated")
    ///是否提醒过认证失败
    static let isMindedAuthenticatedFailed = DefaultsKey<Bool?>("isMindedAuthenticatedFailed")
}
