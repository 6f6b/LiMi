//
//  RemindMsgModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/27.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class RemindMsgListModel: BaseModel {
    var data:[RemindMsgModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class RemindMsgModel: BaseModel {
    ///0:动态  1：话题  2：短视频  3：关注     指定数据来源分类
    var type:Int?
    ///type_id 指定数据分类下的数据id
    var type_id:Int?
    var user_id:Int?
    var sex:Int?
    var nickname:String?
    var head_pic:String?
    var msg:String?
    var text:String?
    var img:String?
    var time:String?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        type <- map["type"]
        type_id <- map["type_id"]
        user_id <- map["user_id"]
        sex <- map["sex"]
        nickname <- map["nickname"]
        head_pic <- map["head_pic"]
        msg <- map["msg"]
        text <- map["text"]
        img <- map["img"]
        time <- map["time"]
    }
}
