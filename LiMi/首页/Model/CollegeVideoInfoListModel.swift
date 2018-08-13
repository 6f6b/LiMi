//
//  CollegeVideoInfoListModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/9.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class CollegeVideoInfoListModel: BaseModel {
    var data:[CollegeVideoInfoModel]?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data<-map["data"]
    }
}

class CollegeVideoInfoModel: BaseModel {
    var college:CollegeModel?
    var videoList:[String]?
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        college<-map["college"]
        videoList<-map["videoList"]
    }
}
