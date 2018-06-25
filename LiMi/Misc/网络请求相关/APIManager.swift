//
//  APIManager.swift
//  SpaceFlight
//
//  Created by YunKuai on 2017/8/23.
//  Copyright © 2017年 cdu.com. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire

class DefaultAlamofireManager: Alamofire.SessionManager {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 15 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireManager(configuration: configuration)
    }()
}

public enum LiMiAPI {
    case targetWith(target:TargetType)
}

extension LiMiAPI: TargetType {
    public var baseURL: URL {
        switch self {
        case .targetWith(let target):
            return target.baseURL
        }
    }
    public var path: String {
        switch self {
        case .targetWith(let target):
            return target.path
        }
    }
    public var method: Moya.Method {
        switch self {
        case .targetWith(let target):
            return target.method
        }
    }
    public var task: Task {
        switch self {
        case .targetWith(let target):
            return target.task
        }
    }
    public var validate: ValidationType {
        switch self {
        case .targetWith(let target):
            return target.validationType
            //return target.validate
        }
    }
    public var sampleData: Data {
        switch self {
        case .targetWith(let target):
            return target.sampleData
        }
    }
    public var headers: [String: String]? {
        return nil
    }
}

