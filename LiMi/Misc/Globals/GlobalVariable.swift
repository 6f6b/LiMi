//
//  GlobalVariable.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import UIKit

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

let APP_PRIVATE_KEY = ""
let APP_PUBLIC_KEY = ""
let ALIPAY_PUBLIC_KEY = ""
let ALIPAY_APP_ID = ""
let WECHAT_APP_ID = ""
let QQ_APP_ID = ""

//APP版本版本
let APP_VERSION = "1.0.5"

//设备唯一标示
//let IMEI = AppUntils.readUUIDFromKeyChain()

//APP 主题色
let APP_TITLE_COLOR = RGBA(r: 71, g: 154, b: 220, a: 1)

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
