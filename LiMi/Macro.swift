//
//  Macro.swift
//  SpaceFlight
//
//  Created by YunKuai on 2017/8/4.
//  Copyright © 2017年 cdu.com. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
//Macro definition
let Defaults = UserDefaults.standard

let USERDEFAULTS_KEY_IS_FIRST_BOOT = "IS_FIRST_BOOT"

let SCREEN_WIDTH = UIScreen.main.bounds.width

let SCREEN_HEIGHT = UIScreen.main.bounds.height

let SCREEN_RECT = UIScreen.main.bounds

let NAVIGATION_BAR_HEIGHT = CGFloat(44.0)

let STATUS_BAR_HEIGHT = CGFloat(20.0)

let TAB_BAR_HEIGHT = CGFloat(49.0)

//APP版本版本
let APP_VERSION = "1.0.5"

//设备唯一标示
//let IMEI = AppUntils.readUUIDFromKeyChain()

//设置颜色
func RGBA(r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat)->UIColor {return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)}

//APP 主题色
let APP_TITLE_COLOR = RGBA(r: 71, g: 154, b: 220, a: 1)

//tableView背景色
let TABLE_VIEW_BACKGROUND_COLOR = RGBA(r: 230, g: 239, b: 245, a: 1)

//cell背景色
let CELL_BACKGROUND_COLOR = RGBA(r: 241, g: 247, b: 254, a: 1)

//CELL分割线颜色
let CELL_SEPERATE_COLOR = RGBA(r: 200, g: 200, b: 200, a: 1)

//无数据提示色
let NO_DATA_COLOR = RGBA(r: 150, g: 150, b: 150, a: 1)

//通用灰
let GENERAL_GRAY_COLOR = RGBA(r: 128, g: 128, b: 128, a: 1)

//设置字体大小
func FONT(size:CGFloat,isBold: Bool=false)->UIFont {
    //    return UIFont.init(name: "Heiti SC", size: size)!
    if isBold{
        return UIFont.boldSystemFont(ofSize: size)
    }else{
        return UIFont.systemFont(ofSize: size)
    }
}


//设置Plus的字号，字体名称，其他机型自适应
func FONT(sizePlus:CGFloat,isBold: Bool=false)->UIFont{
    if SCREEN_WIDTH == 375{return FONT(size: CGFloat((375.0/414))*sizePlus,isBold: isBold)}
    if SCREEN_WIDTH == 320{return FONT(size: CGFloat((320.0/414))*sizePlus,isBold: isBold)}
    return FONT(size: sizePlus)
}

//输入跟屏宽的比，得到对应的距离
func GET_DISTANCE(ratio:Float)->CGFloat{
    let distance = SCREEN_WIDTH*CGFloat(ratio)
    return distance
}

let GENERAL_CELL_HEIGHT = GET_DISTANCE(ratio: 100/750.0)

//新闻标题大小
let NEWS_TITLE_FONT = FONT(sizePlus: 18)

// 根据屏幕尺寸自动调整约束
func AutoLayoutConstraint(constraintPlus: CGFloat)->CGFloat{
    if SCREEN_HEIGHT == 667{
        return constraintPlus*667/736
    }else if SCREEN_HEIGHT <= 568{
        return 568/736*constraintPlus
    }else{
        return constraintPlus
    }
}

//加载xib
func GET_XIB_VIEW(nibName:String)->UIView?{
    return Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.last as? UIView
}

//从storyBoard中加载Controller
func getViewControllerFromStoryboard(storyboardName: String, storyboardID: String) -> UIViewController? {
    
    let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
    let viewController = storyboard.instantiateViewController(withIdentifier: storyboardID)
    return viewController
}

//隐藏tableview的分割线
func makeExtraCellLineHidden(tableView: UITableView) {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    tableView.tableFooterView = view
}

//检测UITextField是否有字符串
func isEmpty(textField:UITextField?)->Bool{
    if let text = textField?.text{
        if text.lengthOfBytes(using: .utf8) == 0{return true}
        return false
    }else{return true}
}

func handleAllSuperViewWith(currentView:UIView!,handleBlock:((UIView?)->Void)?){
    
    if currentView.isKind(of: UIWindow.classForCoder()){
        return
    }
    if let tmpBlock = handleBlock{
        tmpBlock(currentView.superview)
    }
    handleAllSuperViewWith(currentView: currentView!.superview, handleBlock: handleBlock)
}

let APP_PRIVATE_KEY = ""
let APP_PUBLIC_KEY = ""
let ALIPAY_PUBLIC_KEY = ""
let ALIPAY_APP_ID = ""
let WECHAT_APP_ID = ""
let QQ_APP_ID = ""

