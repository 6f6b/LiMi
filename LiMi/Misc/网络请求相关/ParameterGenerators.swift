//
//  ParameterGenerators.swift
//  SpaceFlight
//
//  Created by YunKuai on 2017/9/4.
//  Copyright © 2017年 cdu.com. All rights reserved.
//

import Foundation
import Moya


// MARK: - 相关参数体
let serverAddress = "http://47.97.218.145/limiapp/public"

protocol ParametersProtocol {
    func parameters()->[String:Any]
}

//MARK: 1注册登录短信发送接口（已完成）
struct RequestAuthCode:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/index.php/apps/Sms/startSendSms" }
    
    //参数体
    var phone:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = ["phone":phone]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: 2登录接口（已完成）
struct Login:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/index.php/apps/User/login" }
    
    var phone:String?
    var code:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = ["phone":phone,
                             "code":code]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

////3 注册页面大学列表【川内】(弃用)

//MARK: 4 注册时身份认证接口（已完成）
struct RegisterForID:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/index.php/apps/user/perfectUserInfo" }
    
    var college:String?
    var school:String?
    var grade:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
                             "college":college,
                             "school":school,
                             "grade":grade
                             ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: 5 个人中心—身份认证—保存身份认证信息（已完成）
struct CenterPerfectUserInfo:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/index.php/apps/user/centerPerfectUserInfo" }

     var type:String?   //0查看身份信息 1保存身份信息
     var true_name:String?
     var sex:String?    //0：女 1：男
    
    var college:String?
    var school:String?
    var grade:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "type":type,
            "true_name":true_name,
            "sex":sex,
            "college":college,
            "school":school,
            "grade":grade
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: 6 个人中心—身份认证—查看身份认证信息（已完成）
struct CenterShowUserInfo:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/index.php/apps/user/centerShowUserInfo" }
    
    func parameters() -> [String : Any] {
        let tmpParameters = ["":""]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: 7 头像上传通用接口（已完成）
struct HeadImgUpLoad:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task {
        if let imgUrl =  self.headImgUrl{
            var datas = [MultipartFormData]()
            let imgData = MultipartFormData(provider: .file(imgUrl), name: "file", fileName: "hehe", mimeType: "image/png")
            datas.append(imgData)
            return .uploadCompositeMultipart(datas, urlParameters: self.parameters())
        }
        return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default)
    }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/index.php/apps/User/uploadUserHeadImg" }
    
    //上传的图片数组
    var headImgUrl:URL?
    var id:Int?
    var token:String? 
    
    func parameters()->[String:Any]{
        let tmpParamters = [
            "id":id,
            "token":token
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParamters)
    }
}

//MARK: 8认证状态查看【5分钟后查看会变为 已认证】（弃用）

//MARK: 9个人信息列表（已完成）
struct UserInfoList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/index.php/apps/User/infolist" }
    
    func parameters() -> [String : Any] {
        return handleRequestParameters(parameters: nil)
    }
}

//MARK: 10编辑个人信息姓名性别（已完成）
struct EditUsrInfo:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/index.php/apps/User/edituser" }

    var field:String?
    var value:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "field":field,
            "value":value
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: 11我的个人中心（已完成）
struct PersonCenter:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/index.php/apps/User/mycenter" }
    
    func parameters() -> [String : Any] {
        let tmpParameters = ["":""]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: 12 注册是完善 真实姓名和性别接口（已完成）
struct RegisterFinishNameAndSex:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/index.php/apps/User/perfectUserBasicInfo" }

    var id:Int?
    var token:String?
    var true_name:String?
    var sex:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "id":id,
            "token":token,
            "true_name":true_name,
            "sex":sex,
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}


//MARK: 13 返回大学列表通用接口（已完成）
struct CollegeList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/index.php/apps/User/collegeList"
    }
    
    var provinceID:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "provinceID":provinceID
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: 14 返回二级学院通用接口（已完成）
struct AcademyList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/index.php/apps/User/schoolList"
    }
    
    var collegeID:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "collegeID":collegeID
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}
//MARK: 15 返回年级列表通用接口（已完成）
struct GradeList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/index.php/apps/User/gradeList"
    }
    
    func parameters() -> [String : Any] {
        let tmpParameters = ["":""]
        return handleRequestParameters(parameters: tmpParameters)
    }
}






















// MARK: - 相关枚举
//收藏类型
enum CollectType:Int{
    case collect = 1
    case cancelCollect = 2
}

//查看评论是否倒序
enum CommentSortType:Int{
    case positiveSequence = 1
    case reverse = 2
}

//是否只查看楼主回复
enum LookCommentType:Int{
    case onlyFloorHost = 1
    case all = 2
}

//举报类型
enum TipType:Int{
    //举报帖子
    case postTip = 1
    //举报用户
    case userTip = 2
    //举报评论
    case commentTip = 3
}

//婚恋状态
enum MarriageAndLoveStatus:Int{
    //未婚
    case unmarried = 1
    //已婚
    case married = 2
    //单身
    case single = 3
    //恋爱中
    case inLove = 4
    //离异/丧偶
    case divorce = 5
    
    func description()->String{
        var result = ""
        switch self {
        case .unmarried:
            result = "未婚"
            break
        case .married:
            result = "已婚"
            break
        case .single:
            result = "单身"
            break
        case .inLove:
            result = "恋爱中"
            break
        case .divorce:
            result = "离异/丧偶"
            break
        }
        return result
    }
}

//交友意向
enum FriendsIntension:Int{
    //勿扰
    case notFaze = 1
    //随缘
    case letItBe = 2
    //求撩
    case forHer = 3
    //未设置
    case notSet = 0
    
    func description()->String{
        var result = ""
        switch self {
        case .notFaze:
            result = "勿扰"
            break
        case .letItBe:
            result = "随缘"
            break
        case .forHer:
            result = "求撩"
            break
        case .notSet:
            result = "未设置"
            break
        }
        return result
    }
}

//回复类型
enum ReplayType:Int{
    //回复帖子
    case post = 1
    //回复跟帖
    case comment = 2
}

//用户点赞操作类型
enum ThumbUpType:Int{
    //点赞
    case thumUp = 1
    //取消点赞
    case cancelThumUp = 2
}

//点赞对象类型
enum ThumbUpTargetType:Int{
    //帖子
    case post = 1
    //跟帖
    case followPost = 2
}

//用户性别
enum UserSex:Int{
    //保密
    case secrecy = 0
    //男
    case male = 1
    //女
    case female = 2
    
    func description()->String{
        var result = ""
        switch self {
        case .secrecy:
            result = "保密"
            break
        case .male:
            result = "男"
            break
        case .female:
            result = "女"
            break
        }
        return result
    }
}

//帖子类型
enum PostType:Int{
    //心情
    case mood = 1
    //图片
    case picture = 2
    //视频
    case video = 3
    //投票
    case vote = 4
    //帖子
    case post = 5
}

//短信类型
enum MsgType:Int{
    //注册
    case register = 1
    //登录
    case login = 2
    //修改登录密码
    case updateLoginPwd = 3
    //重置登录密码
    case resetLoginPwd = 4
    //实名认证
    case certification = 5
    //绑定手机
    case bundPhone = 6
    //三方账号绑定用户登录账号
    case thirdAccountBundLoginAccount = 7
}

//三方登录
enum ThirdPartyLoginType:Int{
    //微信
    case wechat = 1
    //QQ
    case qq = 2
    //微博
    case weibo = 3
}

//取消/关注圈子
enum HandleCircleType:Int{
    //关注
    case follow = 1
    //取关
    case cancleFollow = 2
}

//取消/关注用户
enum HandleMemberType:Int{
    //关注
    case follow = 1
    //取关
    case cancleFollow = 2
}

//任务类型
enum TaskType:Int{
    //注册
    case register = 1
    //登录
    case login = 2
    //编辑个人资料
    case editPersonalProfile = 3
    //实名认证
    case certification = 4
    //浏览圈子
    case glanceCircle = 5
    //查看圈子详情
    case checkCircleDetail = 6
    //浏览帖子
    case glancePost = 7
    //查看帖子详情
    case checkPostDetail = 8
    //浏览回帖
    case glanceBackPost = 9
    //发布视频
    case publishVideo = 10
    //发布心情
    case publishMood = 11
    //发布图片
    case publishPicture = 12
    //发布帖子
    case publishPost = 13
    //回复帖子
    case replayPost = 14
    //二次回帖
    case twiceReplayPost = 15
}


