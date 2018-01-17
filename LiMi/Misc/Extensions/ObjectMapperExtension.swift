//
//  ObjectMapperExtension.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import ObjectMapper

extension Mapper{
    public func map(jsonData: Data?) -> N? {
        if let data = jsonData{
            do{
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers){
                    return self.map(JSONObject: json)
                }else{return nil}
            }
        }
        return nil
    }
}
