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
        configuration.timeoutIntervalForRequest = 5 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireManager(configuration: configuration)
    }()
}

//moya管理网络请求
let moyaProvider = MoyaProvider<APIManger>(manager: DefaultAlamofireManager.sharedManager)
let disposeBag = DisposeBag()

enum APIManger{
    case managerWith(parameterGenerator:ParameterGeneratorProtocol)
}

extension APIManger: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    //服务器地址
    public var baseURL: URL {
        switch self {
        case .managerWith(let parameterGenerator):
            return parameterGenerator.baseURL
        }
    }
    //请求方式
    public var method: Moya.Method {
        switch self {
        case .managerWith(let parameterGenerator):
            return parameterGenerator.method
        }
    }
    //参数编码方式
    public var parameterEncoding: ParameterEncoding {
        switch self {
        case .managerWith(let parameterGenerator):
            return parameterGenerator.parameterEncoding
        }
    }
    public var task: Task {
        switch self {
        case .managerWith(let parameterGenerator):
            return parameterGenerator.task
        }
    }
    public var sampleData: Data {
        switch self {
        case .managerWith(let parameterGenerator):
            return parameterGenerator.sampleData
        }
    }
    
    //请求地址
    public var path: String {
        switch self {
        case .managerWith(let parameterGenerator):
            return parameterGenerator.path
        }
    }
    
    //请求参数
    public var parameters: [String : Any]? {
        switch self {
        case .managerWith(let parameterGenerator):
            return parameterGenerator.parameters()
        }
    }
    
}

