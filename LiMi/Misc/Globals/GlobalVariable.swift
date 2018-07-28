//
//  GlobalVariable.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import UIKit
import Qiniu

let Defaults = UserDefaults.standard

/***************************************************************尺寸相关***************************************************************/
let USERDEFAULTS_KEY_IS_FIRST_BOOT = "IS_FIRST_BOOT"

let SCREEN_WIDTH = UIScreen.main.bounds.width

let SCREEN_HEIGHT = UIScreen.main.bounds.height

let SCREEN_RECT = UIScreen.main.bounds

///导航栏高度
let NAVIGATION_BAR_HEIGHT = CGFloat(44.0)

///状态栏高度
let STATUS_BAR_HEIGHT = SCREEN_HEIGHT >= 812 ? CGFloat(44) : CGFloat(20) //UIApplication.shared.statusBarFrame.size.height

///Tabbar高度
let TAB_BAR_HEIGHT = SCREEN_HEIGHT >= 812 ? CGFloat(83.0) : CGFloat(49.0)

///导航栏分割线高度
let NAVIGATION_BAR_SEPARATE_LINE_HEIGHT = CGFloat(0.7)

/***************************************************************颜色相关***************************************************************/
///APP 主题色
let APP_THEME_COLOR = RGBA(r: 47, g: 196, b: 233, a: 1)

///APP 主题色 1 - RGBA(r: 30, g: 30, b: 30, a: 1)
let APP_THEME_COLOR_1 = RGBA(r: 30, g: 30, b: 30, a: 1)

///APP 主题色 2 - RGBA(r: 114, g: 0, b: 218, a: 1)
let APP_THEME_COLOR_2 = RGBA(r: 114, g: 0, b: 218, a: 1)

///一级黑
let FIRST_LEVEL_BLACK_COLOR = RGBA(r: 51, g: 51, b: 51, a: 1)

///CELL分割线颜色
let CELL_SEPERATE_COLOR = RGBA(r: 200, g: 200, b: 200, a: 1)

///导航栏分割线颜色
let NAVIGATION_BAR_SEPARATE_COLOR = RGBA(r: 228, g: 228, b: 228, a: 1)

//头像内存上限，单位KB
let HEAD_IMG_MAX_MEMERY_SIZE = 200.0

/// 微信APPID
let WECHAT_APP_ID = "wxb750b949790baabc"
let QQ_APP_ID = ""

//APP版本版本
let APP_VERSION = "V\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"

//APP   scheme
let APP_SCHEME = "LiMi20018"

//设备唯一标示
//let IMEI = AppUntils.readUUIDFromKeyChain()


var AUTH_BTN_COUNT_DOWN_TIMER:Timer?
var AUTH_BTN_COUNT_DOWN_TIME = 0

///注册完毕
let REGISTER_FINISHED_NOTIFICATION = Notification.Name.init("REGISTER_FINISHED_NOTIFICATION")
///动态发送成功通知
let POST_TREND_SUCCESS_NOTIFICATION = Notification.Name.init("POST_TREND_SUCCESS_NOTIFICATION")
///话题发送成功通知
let POST_TOPIC_SUCCESS_NOTIFICATION = Notification.Name.init("POST_TOPIC_SUCCESS_NOTIFICATION")
///话题圈添加成功
let ADD_TOPIC_CIRCLE_SUCCESS_NOTIFICATION = Notification.Name.init("ADD_TOPIC_CIRCLE_SUCCESS_NOTIFICATION")
///退出登录通知
let  LOGOUT_NOTIFICATION = Notification.Name.init("LOGOUT_NOTIFICATION")
///筛选条件改变
let   SCREENING_CODITIONS_CHANGED = Notification.Name.init("SCREENING_CODITIONS_CHANGED")
///做出了更多操作通知：举报、删除、拉黑、聊天、不感兴趣
let    DID_MORE_OPERATION = Notification.Name.init("DID_MORE_OPERATION")
///对话题做出了更多操作通知：举报、删除、拉黑、聊天
let    DID_TOPIC_MORE_OPERATION = Notification.Name.init("DID_TOPIC_MORE_OPERATION")
///对视频做出了更多操作通知：举报、删除、拉黑、聊天
let    DID_VIDEO_TREND_MORE_OPERATION = Notification.Name.init("DID_VIDEO_TREND_MORE_OPERATION")
/// 抢了红包
let     CATCHED_RED_PACKET_NOTIFICATION = Notification.Name.init("CATCHED_RED_PACKET_NOTIFICATION")
/// 支付宝支付完毕
let FINISHED_ALIPAY_NOTIFICATION = Notification.Name.init("FINISHED_ALIPAY_NOTIFICATION")
///微信支付完毕
let FINISHED_WXPAY_NOTIFICATION = Notification.Name.init("FINISHED_WXPAY_NOTIFICATION")
/// 点赞&取消点赞通知
let THUMBS_UP_NOTIFICATION =    Notification.Name.init("THUMBS_UP_NOTIFICATION")
///未读消息数改变通知
let ALL_UNREAD_COUNT_CHANGED_NOTIFICATION = Notification.Name.init("ALL_UNREAD_COUNT_CHANGED_NOTIFICATION")
///提现成功通知
let WITHDRAW_SUCCESSED_NOTIFICATION = Notification.Name.init("WITHDRAW_SUCCESSED_NOTIFICATION")
///通过认证通知
let IDENTITY_STATUS_OK_NOTIFICATION = Notification.Name.init("IDENTITY_STATUS_OK_NOTIFICATION")
///点击了Tabbar通知
let TAPED_TABBAR_NOTIFICATION = Notification.Name.init("TAPED_TABBAR_NOTIFICATION")
let LOGIN_IM_SUCCESS_NOTIFICATION = Notification.Name.init("LOGIN_IM_SUCCESS_NOTIFICATION")
///评论短点击通知
let TAPED_COMMENT_NOTIFICATION = Notification.Name.init("TAPED_COMMENT_NOTIFICATION")
///评论长按通知
let LONGPRESS_COMMENT_NOTIFICATION = Notification.Name.init("LONGPRESS_COMMENT_NOTIFICATION")
///人名短点击通知
let TAPED_COMMENT_PERSON_NAME_NOTIFICATION = Notification.Name.init("TAPED_COMMENT_PERSON_NAME_NOTIFICATION")
///查看更多子评论通知
let CHECK_MORE_SUB_COMMENT_NOTIFICATION = Notification.Name.init("CHECK_MORE_SUB_COMMENT_NOTIFICATION")
///删除评论成功通知
let DELETE_COMMENT_SUCCESS_NOTIFICATION = Notification.Name.init("DELETE_COMMENT_SUCCESS_NOTIFICATION")
let COMMENT_SUCCESS_NOTIFICATION = Notification.Name.init("COMMENT_SUCCESS_NOTIFICATION")


///清空点赞和评论消息成功
let CLEAR_COMMENTS_AND_THUMBUP_MESSAGE_SUCCESS = Notification.Name.init("CLEAR_COMMENTS_AND_THUMBUP_MESSAGE_SUCCESS")
///关注、取消关注成功
let ADD_ATTENTION_SUCCESSED_NOTIFICATION = Notification.Name.init("ADD_ATTENTION_SUCCESSED_NOTIFICATION")

///离开播放页
let LEAVE_PLAY_PAGE_NOTIFICATION = Notification.Name.init("LEAVE_PLAY_PAGE_NOTIFICATION")
///进入播放页
let INTO_PLAY_PAGE_NOTIFICATION = Notification.Name.init("INTO_PLAY_PAGE_NOTIFICATION")

let PULISH_VIDEO_TREND_SUCCESS = Notification.Name.init("PULISH_VIDEO_TREND_SUCCESS")
//收藏、取消收藏音乐成功通知
let COLLECT_MUSIC_SUCCESS_NOTIFICATION = Notification.Name.init("COLLECT_MUSIC_SUCCESS_NOTIFICATION")
///获取cell的key
let CELL_INSTANCE_KEY = "CELL_INSTANCE_KEY"
/// 更多操作通知对象的key
let MORE_OPERATION_KEY = "MORE_OPERATION_KEY"
/// 动态模型key
let TREND_MODEL_KEY = "TREND_MODEL_KEY"
///微信支付结果
let WXPAY_RESULT_KEY = "WXPAY_RESULT_KEY"
///退出登录信息key
let LOG_OUT_MESSAGE_KEY = "LOG_OUT_MESSAGE_KEY"
///UserId key
let USER_ID_KEY = "USER_ID_KEY"
///关注关系key
let RELATIONSHIP_KEY = "RELATIONSHIP_KEY"
///点击Tabbar的index key
let  TABBAR_INDEX_KEY = "TABBAR_INDEX_KEY"
///评论模型Key
let COMMENT_MODEL_KEY = "COMMENT_MODEL_KEY"

//国内https上传
let qnConfig = QNConfiguration.build { (builder) in
    builder?.setZone(QNFixedZone.zone0())
}
let QiNiuUploadManager = QNUploadManager(configuration: qnConfig)

let SYSTEM_VERSION = UIDevice.current.systemVersion.doubleValue()!

///联系电话
var PHONE_NUMBER = "028-33010731"
///一级最长拍摄时间
var FIRST_LEVEL_RECORD_TIME = Float(15)


