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
func handleRequestParameters(parameters:[String:Any?])->[String:Any]{
    var tmpParameters = [String:Any]()
    for key in parameters.keys{
        if let tmpValue = parameters[key]{
            tmpParameters[key] = tmpValue
        }
    }
    return tmpParameters
}
