//
//  ParameterGenerators.swift
//  SpaceFlight
//
//  Created by YunKuai on 2017/9/4.
//  Copyright © 2017年 cdu.com. All rights reserved.
//

import Foundation
import Moya

// MARK: - 参数生成器协议
protocol ParameterGeneratorProtocol {
    //默认网络配置参数
    var baseURL: URL{get}   //服务器地址
    var method: Moya.Method {get}    //请求方式
    var parameterEncoding: ParameterEncoding {get}    //参数编码方式
    var task: Task{get}
    var sampleData: Data{get}
    
    //请求路径
    var path:String!{get}
    
    //网络请求参数，自定义
    
    //参数字典生成函数
    func parameters()->[String:Any]?
}


// MARK: - 相关参数体
//1获取验证码
struct RequestVertificationCode:ParameterGeneratorProtocol{
    var baseURL: URL {return URL(string: serviceAddress)!}   //服务器地址
    var method: Moya.Method {return .post}    //请求方式
    var parameterEncoding: ParameterEncoding {return URLEncoding.default}    //参数编码方式
    var task: Task {return .requestPlain}
    var sampleData: Data {return "".data(using: String.Encoding.utf8)!}

    var path:String!{return "/index.php/apps/Sms/startSendSms"}

    var phone:String?

    func parameters()->[String:Any]?{
        var tmpParamters = [String:Any]()
        tmpParamters["phone"] = phone

        return handleRequestParameters(parameters: tmpParamters)
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


