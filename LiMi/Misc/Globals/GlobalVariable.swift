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

let USERDEFAULTS_KEY_IS_FIRST_BOOT = "IS_FIRST_BOOT"

let SCREEN_WIDTH = UIScreen.main.bounds.width

let SCREEN_HEIGHT = UIScreen.main.bounds.height

let SCREEN_RECT = UIScreen.main.bounds

let NAVIGATION_BAR_HEIGHT = CGFloat(44.0)

let STATUS_BAR_HEIGHT = CGFloat(20.0)

let TAB_BAR_HEIGHT = CGFloat(49.0)

//头像内存上限，单位KB
let HEAD_IMG_MAX_MEMERY_SIZE = 200.0

let QI_NIU_TOKEN = ""

let APP_PRIVATE_KEY = ""
let APP_PUBLIC_KEY = ""
let ALIPAY_PUBLIC_KEY = ""
let ALIPAY_APP_ID = ""

/// 微信APPID
let WECHAT_APP_ID = "wxb750b949790baabc"
let QQ_APP_ID = ""

//APP版本版本
let APP_VERSION = "v\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"

//APP   scheme
let APP_SCHEME = "LiMi20018"

//设备唯一标示
//let IMEI = AppUntils.readUUIDFromKeyChain()

//APP 主题色
let APP_THEME_COLOR = RGBA(r: 47, g: 196, b: 233, a: 1)

//cell背景色
let CELL_BACKGROUND_COLOR = RGBA(r: 241, g: 247, b: 254, a: 1)

//CELL分割线颜色
let CELL_SEPERATE_COLOR = RGBA(r: 200, g: 200, b: 200, a: 1)

//无数据提示色
let NO_DATA_COLOR = RGBA(r: 150, g: 150, b: 150, a: 1)

//通用灰
let GENERAL_GRAY_COLOR = RGBA(r: 128, g: 128, b: 128, a: 1)

var AUTH_BTN_COUNT_DOWN_TIMER:Timer?
var AUTH_BTN_COUNT_DOWN_TIME = 0

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

/// 更多操作通知对象的key
let MORE_OPERATION_KEY = "MORE_OPERATION_KEY"
/// 动态模型key
let TREND_MODEL_KEY = "TREND_MODEL_KEY"
///微信支付结果
let WXPAY_RESULT_KEY = "WXPAY_RESULT_KEY"
///退出登录信息key
let LOG_OUT_MESSAGE_KEY = "LOG_OUT_MESSAGE_KEY"


//国内https上传
let qnConfig = QNConfiguration.build { (builder) in
    builder?.setZone(QNFixedZone.zone0())
}
let QiNiuUploadManager = QNUploadManager(configuration: qnConfig)

let SYSTEM_VERSION = UIDevice.current.systemVersion.doubleValue()!

