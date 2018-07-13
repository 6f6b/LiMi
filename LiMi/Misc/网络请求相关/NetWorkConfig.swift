//
//  NetWorkConfig.swift
//  SpaceFlight
//
//  Created by YunKuai on 2017/8/22.
//  Copyright © 2017年 cdu.com. All rights reserved.
//

import Foundation
import SwiftyJSON

let serviceAddress = "http://app.taoke80.com"
let successState = "Success"
func handleRequestParameters(parameters:Any?)->[String:Any]{
    var tmpParameters = [String:Any]()
    if let parameters = parameters as? [String:Any?]{
        for key in parameters.keys{
            if let tmpValue = parameters[key]{
                tmpParameters[key] = tmpValue
            }
        }
    }
    //加userid、token
    if tmpParameters["id"] == nil && Defaults[.userId]?.stringValue() != nil{
        tmpParameters["id"] = Defaults[.userId]
    }
//    if Defaults[.userId]?.stringValue() != nil{
//        tmpParameters["id"] = Defaults[.userId]
//    }
    if Defaults[.userToken] != nil{
        tmpParameters["token"] = Defaults[.userToken]
    }
    return tmpParameters
}
