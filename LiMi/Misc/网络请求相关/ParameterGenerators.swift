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
let serverAddress = "http://app.youhongtech.com/index.php/apps2"

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
    var path: String { return "/Sms/startSendSms" }
    
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
    var path: String { return "/User/login" }
    
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
    var path: String { return "/user/perfectUserInfo" }
    
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
    var path: String { return "/user/perfectUserInfo" }

     var type:String?   //0查看身份信息 1保存身份信息
     var true_name:String?
    
    var college:Int?
    var school:Int?
    var grade:Int?
    var identity_pic:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "type":type,
            "true_name":true_name,
            "college":college,
            "school":school,
            "grade":grade,
            "identity_pic":identity_pic
            ] as [String : Any]
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
    var path: String { return "/user/centerShowUserInfo" }
    
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
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: JSONEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String { return "/User/uploadUserHeadImg" }
    
    var id:Int?
    var token:String?
    
    /// 图片地址
    var image:String?
    
    /// 默认为head(头像)，back为背景图
    var type:String? = "head"
    
    func parameters() -> [String : Any] {
        let tmpParamters = [
            "id":id,
            "token":token,
            "images":image,
            "type":type
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
    var path: String { return "/User/infolist" }
    
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
    var path: String { return "/User/edituser" }

    var nickname:String?
    var signature:String?
    var sex:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "nickname":nickname,
            "signature":signature,
            "sex":sex
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: 11我的个人中心（已完成）
struct PersonCenter:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String { return "/user/myCenter" }
    
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
    var path: String { return "/User/perfectUserBasicInfo" }

    var id:Int?
    var token:String?
    var nickname:String?
    var sex:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "id":id,
            "token":token,
            "nickname":nickname,
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
        return "/User/collegeList"
    }
    
    var college:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "college":college
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
        return "/User/schoolList"
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
        return "/User/gradeList"
    }
    
    func parameters() -> [String : Any] {
        let tmpParameters = ["":""]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: 16 动态、发现列表-以及筛选之后的列表（已对接）
struct TrendsList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/Action/indexList"
    }
    var type:String?    //动态/action 发现/skill
    var page:String?        //分页
    var college_id:String?
    var school_id:String?
    var grade_id:String?
    var sex:String?
    var skill_id:String?    //skill
    var time:TimeInterval?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "type":type,
            "page":page,
            "college_id":college_id,
            "school_id":school_id,
            "grade_id":grade_id,
            "sex":sex,
            "skill_id":skill_id,
            "time":time
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: 17 显示评论列表（已对接）
struct CommentList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/Action/discussList"
    }
    
    var action_id:String?
    var page:Int?
    var time:TimeInterval?
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "action_id":action_id,
            "page":page,
            "time":time
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 18 添加评论处理接口（已对接）
struct AddComment:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Action/discussAction"
    }
    
    var action_id:String?
    var content:String?
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "action_id":action_id,
            "content":content
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 19点赞处理接口（已对接）
struct ThumbUp:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Action/clickAction"
    }
    
    var action_id:String?
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "action_id":action_id,
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 20 个人详情-点击头像
struct UserDetails:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/Action/myActionList"
    }
    
    var page:Int?
    var user_id:Int?
    var type:String?
    var time:TimeInterval?
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "page":page,
            "type":type,
            "user_id":user_id,
            "time":time
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 21 更多功能方法处理接口-举报-拉黑-聊天-删除
struct MoreOperation:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Action/multiFunction"
    }
    
    var type:String?
    var action_id:Int?
    var user_id:Int?
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "type":type,
            "action_id":action_id,
            "user_id":user_id
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 22 点击漏斗筛选条件显示
struct ScreeningConditions:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/Action/filtrateList"
    }

    func parameters() -> [String : Any] {
        let tmpParameters = ["":""]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 23 我的动态(已对接)
struct MyTrends:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/Action/myAction"
    }
    
    var page:Int?
    var time:TimeInterval?
    
    func parameters() -> [String : Any] {
        let tmpParameters = ["page":page,
                             "time":time] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 24 设置支付密码(已对接)
struct SetPayPassword:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/user/paymentCodeaction"
    }
    var code:String?
    var password1:String?
    var password2:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "code":code,
            "password1":password1,
            "password2":password2,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 25 设置支付密码(已对接)
struct TransactonRcord:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/user/myrecord"
    }
    var page:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "page":page,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 26我的现金
struct MyCash:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/User/mycash"
    }
    
    func parameters() -> [String : Any] {
        var tmpParameters:[String:Any]? = nil
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 粉丝列表
struct MyFansList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/user/myFansList"
    }
    var page:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "page":page,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 关注列表
struct MyAttentionList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/user/myAttentionList"
    }
    var page:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "page":page,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 关注列表
struct AddAttention:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/user/addAttention"
    }
    ///操作对象id
    var attention_id:Int?

    func parameters() -> [String : Any] {
        let tmpParameters = [
            "attention_id":attention_id,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 昵称搜索动作
struct SearchUser:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/user/searchUser"
    }
    ///操作对象id
    var nickname:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "nickname":nickname,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}


//MARK: - 我的黑名单
struct MyBlackList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/user/myBlackList"
    }

    var page:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "page":page,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}


//MARK: - 我的关注
struct TopAttentionList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/user/topAttentionList"
    }
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "":"",
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}
//MARK: - 获取七牛云上传token（已对接）
struct GetQNUploadToken:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Qiniuyun/getUploadToken"
    }
    var type:String = "image"
    var id:Int? = nil
    var token:String? = nil
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "id":id,
            "token":token,
            "type":type] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}


//MARK: - /******************************发布需求模块*************************************/
//MARK: - 1发布动态（已对接）
struct ReleaseTrends:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Publish/publishDynamic"
    }
    var red_token:String?   //红包
    var skill_id:Int?    //标签
    var content:String? //发布文字内容
    var images:String?  //发布图片
    var video:String?   //发布视频
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "red_token":red_token,
            "skill_id":skill_id,
            "content":content,
            "images":images,
            "video":video,
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}
//MARK: - 2.获取技能标签列表（已对接）
struct SkillList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/Publish/skillList"
    }
    var page:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "page":page,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}
//MARK: - 3 塞入钱包,塞红包到动态中    POST app.youhongtech.com/Publish/sendRedpacket
struct SendRedpacket:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Publish/sendRedpacket"
    }
    
    var money:Double?
    var num:Int?
    var type:Int?
    var password:String?
    var trade_no:String?
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "money":money,
            "num":num,
            "type":type,
            "password":password,
            "trade_no":trade_no
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}
//4 取消发布需求    POST
struct CancelDynamic:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Publish/cancelDynamic"
    }
    
    var red_token:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "red_token":red_token
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 5 领取红包
struct GetRedPacked:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Publish/getRedPacked"
    }
    var red_token:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "red_token":red_token,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 6 打开红包
struct OpenRedPacked:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Publish/openRedPacked"
    }
    var red_token:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "red_token":red_token,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - /*********************支付模块****************************/
//MARK: - 1 塞入钱包在线支付，返回支付宝订单信息
struct GetRechargeOrderInfo:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Pay/getRechargeOrderInfo"
    }
    
    /// 金额
    var money:String?
    /// 类型
    var type:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "type":type,
            "money":money,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 2 ：支付宝异步回调，查询支付是否成功（用于塞红包、充值等）
struct GetPayStaus:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Pay/getPayStaus"
    }
    
    /// 交易流水号
    var order_no:String?
    
    /// 支付类型 1：支付宝 2：微信
    var type:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "out_biz_no":order_no,
            "type":type
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 3提现
struct WithdrawCash:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Pay/withdrawCash"
    }
    
    /// 提现金额
    var money:Double?
    /// 支付宝账户
    var account:String?
    /// 真实姓名
    var true_name:String?
    /// 短信验证码
    var code:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "money":money,
            "account":account,
            "true_name":true_name,
            "code":code,
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 4 ：支在线支付——查看支付状态（周末游支付状态查询）
struct GetOnlinePayStaus:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Pay/getOnlinePayStaus"
    }
    
    /// 交易流水号
    var order_no:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "out_biz_no":order_no,
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - /*********************IM模块****************************/
//MARK: - 1获取IM token
struct GetIMToken:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Im/getToken"
    }
    
    var to_uid:Int?
    var id:Int?
    var token:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "to_uid":to_uid,
            "id":id,
            "token":token
                                           ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - /*********************用户反馈****************************/
//MARK: - 1用户反馈
struct FeedBack:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/user/feedBack"
    }
    
    var type:Int?   //反馈类型，1：功能问题 2：性能问题 3：其他问题
    var info:String? //反馈的文字信息
    var pic:String? //图片地址
    var phone:String? //联系电话
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "type":type,
            "info":info,
            "pic":pic,
            "phone":phone
                                           ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - /*********************APP升级****************************/
//MARK: - 1APP升级
struct AppUpdate:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Update/appStart"
    }

    var device:String? //设备名称，android、ios
    var version:String? //版本号
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "device":device,
            "version":version,
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - /*********************圈子****************************/
//MARK: - 4-1添加话题
struct AddTopic:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/topic/addtopic"
    }
    
    var title:String? //主题
    var content:String? //话题简介
    
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "title":title,
            "content":content,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 4-2话题圈下发表话题
struct AddTopicAction:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/topic/addTopicAction"
    }
    
    var pic:String? //图片
    var topic_id:Int? //话题圈id
    var content:String? //内容
    
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "pic":pic,
            "topic_id":topic_id,
            "content":content,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 4-3话题点赞
struct ClickAction:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/topic/clickAction"
    }
    
    var topic_action_id:Int? //话题圈id
    
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "topic_action_id":topic_action_id,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 4-4话题评论
struct DiscussAction:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/topic/discussAction"
    }
    
    var topic_action_id:Int? //话题id
    var content:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "topic_action_id":topic_action_id,
            "content":content
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 4-5话题圈下的话题列表
struct OneTopicList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/topic/oneTopicList"
    }
    
    var page:Int? //分页
    var topic_id:Int? //话题圈id
    var type:String? //最新、最热
    var time:TimeInterval?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "page":page,
            "topic_id":topic_id,
            "type":type,
            "time":time
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 4-6话题圈列表
struct AllTopicList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/topic/allTopicList"
    }
    
    var page:Int? //分页
    var time:TimeInterval?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "page":page,
            "time":time
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 4-7 对某个话题不感兴趣
struct UnlikeTopic:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/topic/unlikeTopic"
    }
    
    var topic_id:Int?
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "topic_id":topic_id,
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 4-8 更多功能方法处理接口-举报-拉黑-聊天-删除
struct MultiFunction:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/topic/multiFunction"
    }
    
    var type:String?
    var topic_action_id:Int?
    var user_id:Int?
    func parameters() -> [String : Any] {
        let tmpParameters = [
            "type":type,
            "topic_action_id":topic_action_id,
            "user_id":user_id
            ] as [String : Any]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 4-9评论列表
struct DiscussList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/topic/discussList"
    }
    
    var page:Int? //分页
    var topic_action_id:Int? //评论
    var time:TimeInterval?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "page":page,
            "topic_action_id":topic_action_id,
            "time":time
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - /*********************附近的人****************************/
//MARK: - 5-1附近的用户信息列表
struct NearUserList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/near/nearUserList"
    }
    
    var lat:String?
    var lng:String?
    var page:Int?
    var sex:Int?

    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "lat":lat,
            "lng":lng,
            "page":page,
            "sex":sex
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 5-3清除位置信息
struct ClearLocation:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/near/clearLocation"
    }
    
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "":""
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 5-4编辑个性签名
struct UpdateContent:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/near/updateContent"
    }
    
    var content:String?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "content":content
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 5-5编辑个性签名
struct ShowEditContent:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/near/editContent"
    }
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "":""
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - /*********************周日游****************************/
//MARK: - 1周日游首页
struct WeekendIndex:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/weekend/WeekendIndex"
    }
    
    var page:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "page":page
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 2周日游活动详情
struct WeekendInfo:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/weekend/weekendinfo"
    }
    
    var weekend_id:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "weekend_id":weekend_id
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 3周日游订单详情
struct WeekendOrder:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/weekend/weekendorder"
    }
    
    var weekend_id:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "weekend_id":weekend_id
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 4周日游订单详情
struct OrderAction:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/weekend/orderAction"
    }
    
    var goods_id:Int?//    周末游id    是    [int]
    var goods_num:Int?//    购买数量    是    [int]
    var text :String?//   购买备注    是    [string]
    var time:String?//    预约的时间    是    [string]    【格式】2017-12-10 11:11:11 比如【1月9日】传入2018-01-09 00:00:00    查看
    var mobile:String?    //备注手机号    是    [int]    0支付宝 1微信    查看
    var pay_type:Int?//    支付方式    是    [string]
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "goods_id":goods_id,
             "goods_num":goods_num,
             "text":text,
              "time":time,
               "mobile":mobile,
                "pay_type":pay_type,
        ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 订单列表
struct MyOrderList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/user/myOrderList"
    }
    
    var page:Int?//    周末游id    是    [int]

    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "page":page,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 圈子首页，周末游推荐数据
struct CircleList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/weekend/CircleList"
    }

    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "":"",
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - /*********************消息****************************/
//MARK: - 评论消息
struct ClickMessageList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/Message/clickList"
    }
    
    var page:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "page":page,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 点赞消息
struct CommentMessageList:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .get }
    var path: String {
        return "/Message/commentList"
    }
    
    var page:Int?
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "page":page,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

//MARK: - 清空消息
struct ClearMessage:TargetType,ParametersProtocol{
    var baseURL: URL { return URL.init(string: serverAddress)! }
    //单元测试
    var sampleData: Data { return "".data(using: .utf8)! }
    var task: Task { return .requestParameters(parameters: self.parameters(), encoding: URLEncoding.default) }
    var validate: Bool { return true }
    var headers: [String: String]? { return nil }
    var method: Moya.Method { return .post }
    var path: String {
        return "/Message/clearMessage"
    }
    
    var type:Int? = 0
    
    func parameters() -> [String : Any] {
        let tmpParameters:[String:Any]? = [
            "type":type,
            ]
        return handleRequestParameters(parameters: tmpParameters)
    }
}

