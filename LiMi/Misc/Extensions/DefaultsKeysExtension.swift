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
    // 存储用户ID
    static let userId = DefaultsKey<Int?>("userId")
    //存储用户token
    static let userToken = DefaultsKey<String?>("userToken")
    //存储用户手机号
    static let userPhone = DefaultsKey<String?>("userPhoneNum")
}
