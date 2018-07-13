//
//  GlobalFunction.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import UIKit
import Moya
import SVProgressHUD
import ObjectMapper
import AVFoundation
import MJRefresh

enum StoryBoardName {
    case homePage
    case circle
    case msg
    case personalCenter
    case loginRegister
    case main
}

//创建颜色
func RGBA(r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat)->UIColor {return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)}

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

//检测手机号码格式
func IS_PHONE_NUMBER(phoneNum:String?)->Bool{
    if let phoneNum = phoneNum{
        let regex = "^1(3|4|5|7|8|9)\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: phoneNum)
        return isValid
    }
    return false
}

//检测密码格式
func IS_PASSWORD(password:String?)->Bool{
    if let password = password{
        let regex = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,18}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: password)
        return isValid
    }
    return false
}

//检测验证码格式
func IS_AuthCode(authCode:String?)->Bool{
    if let authCode = authCode{
        let regex = "^d{4}$ "
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: authCode)
        return isValid
    }
    return false
}


func GetImgNameWith(asset:PHAsset?,complet:((String?)->Void)?){
    if let _asset = asset{
        _asset.getImageComplete({ (data, imgName) in
            let tempDir = NSTemporaryDirectory()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyymmddhhmmss"
            let timeStr = dateFormatter.string(from: Date())
            // 生成 "0000-9999" 4位验证码
            let num = arc4random() % 10000
            let randomStr = String.init(format: "%.4d", num)
            let imgName = timeStr + randomStr + "i\(imgName)"
            let imgPath = tempDir+imgName
            if let _complet = complet{
                _complet(imgPath)
            }
        })
    }
}

//生成本地上传地址
func GenerateImgPathlWith(img:UIImage?)->String?{
    if let unpackImg = img{
        let tempDir = NSTemporaryDirectory()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyymmddhhmmss"
        let timeStr = dateFormatter.string(from: Date())
        // 生成 "0000-9999" 4位验证码
        let num = arc4random() % 10000
        let randomStr = String.init(format: "%.4d", num)
        let imgName = timeStr + randomStr + "i.png"
        let imgPath = tempDir+imgName
        let fileUrl = URL.init(fileURLWithPath: imgPath)
        do{
            try UIImageJPEGRepresentation(unpackImg, 1)?.write(to: fileUrl)
        }catch{
            return nil
        }
        return imgPath
    }
    return nil
}

//从storyBoard中加载Controller
 func GetViewControllerFrom(sbName:StoryBoardName,sbID:String) -> UIViewController {
    var name  = ""
    switch sbName {
    case .homePage:
        name = "HomePage"
        break
    case .circle:
        name = "Circle"
        break
    case .msg:
        name = "Msg"
        break
    case .personalCenter:
        name = "PersonalCenter"
        break
    case .loginRegister:
        name = "LoginRegister"
        break
    case .main:
        name = "Main"
        break
    }
    let sb = UIStoryboard.init(name: name, bundle: nil)
    let vc = sb.instantiateViewController(withIdentifier: sbID)
    return vc
}

func LoginServiceToMainController(loginRootController:UIViewController?){
    //其余页面均返回原页面，个人中心页则返回首页
    if let tbController = UIApplication.shared.keyWindow?.rootViewController as? TabBarController{
        
        if let navController = tbController.selectedViewController as? CustomNavigationController{
            if let _ = navController.topViewController as? PersonCenterController{
                tbController.selectedIndex = 0
            }
        }
//
//        if AppManager.shared.appState() == .imOfflineBusinessOnline || AppManager.shared.appState() == .imOnlineBusinessOnline{}else{
//            tbController.selectedIndex = 0
//        }
    }
    loginRootController?.dismiss(animated: true, completion: nil)
}

//隐藏tableview的分割线
func MakeExtraCellLineHidden(tableView: UITableView) {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    tableView.tableFooterView = view
}

//检测UITextField是否有字符串
func IsEmpty(textField:UITextField?)->Bool{
    if let text = textField?.text{
        if text.lengthOfBytes(using: .utf8) == 0{return true}
        return false
    }else{return true}
}

//检测UITextView是否有字符串
func IsEmpty(textView:UITextView?)->Bool{
    if let text = textView?.text{
        if text.lengthOfBytes(using: .utf8) == 0{return true}
        return false
    }else{return true}
}

func MAX(parametersA:Double,parametersB:Double)->Double{
    return parametersA > parametersB ? parametersA:parametersB
}

func MIN(parametersA:Double,parametersB:Double)->Double{
    return parametersA < parametersB ? parametersA:parametersB
}

/// 根据传入颜色生成一张导航栏图片
///
/// - Parameter color: 传入颜色
/// - Returns: 生成的图片
func GetNavBackImg(color:UIColor)->UIImage{
    return GetImgWith(size: CGSize.init(width: SCREEN_WIDTH, height: 64), color: color)
//    let layer = CAGradientLayer()
//    let frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 64)
//    layer.frame = frame
//    layer.colors = [color.cgColor,color.cgColor]
//    layer.locations = [0.0, 1]
//    layer.startPoint = CGPoint.init(x: 0, y: 0)
//    layer.endPoint = CGPoint.init(x: 1, y: 1)
//
//    let viewForImg = UIView.init(frame: frame)
//    viewForImg.layer.addSublayer(layer)
//
//    UIGraphicsBeginImageContextWithOptions(frame.size, false, 1)
//    viewForImg.layer.render(in: UIGraphicsGetCurrentContext()!)
//    let img = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    return img!
}


/// 根据传入颜色和尺寸生成一张图片
///
/// - Parameters:
///   - size: 尺寸
///   - color: 颜色
/// - Returns: 返回图片
func GetImgWith(size:CGSize,color:UIColor)->UIImage{
    let layer = CAGradientLayer()
    let frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
    layer.frame = frame
    layer.colors = [color.cgColor,color.cgColor]
    layer.locations = [0.0, 1]
    layer.startPoint = CGPoint.init(x: 0, y: 0)
    layer.endPoint = CGPoint.init(x: 1, y: 1)
    
    let viewForImg = UIView.init(frame: frame)
    viewForImg.layer.addSublayer(layer)
    
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 1)
    viewForImg.layer.render(in: UIGraphicsGetCurrentContext()!)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img!
}

//获取验证码按钮倒计时
func MakeAuthCodeBtnCannotBeHandleWith(button:UIButton?){
    button?.isUserInteractionEnabled = false
    button?.setTitleColor(UIColor.lightGray, for: .normal)
    button?.layer.borderColor = UIColor.lightGray.cgColor
    AUTH_BTN_COUNT_DOWN_TIME = 60
    AUTH_BTN_COUNT_DOWN_TIMER?.invalidate()
    if #available(iOS 10.0, *) {
        AUTH_BTN_COUNT_DOWN_TIMER = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _  in
            let info = "\(AUTH_BTN_COUNT_DOWN_TIME)秒后再试"
            button?.setTitle(info, for: .normal)
            AUTH_BTN_COUNT_DOWN_TIME -= 1
            if AUTH_BTN_COUNT_DOWN_TIME == 0{
                button?.isUserInteractionEnabled = true
                let normalColor = RGBA(r: 47, g: 213, b: 233, a: 1)
                button?.setTitleColor(normalColor, for: .normal)
                button?.layer.borderColor = normalColor.cgColor
                button?.setTitle("获取验证码", for: .normal)
                AUTH_BTN_COUNT_DOWN_TIMER?.invalidate()
                AUTH_BTN_COUNT_DOWN_TIMER = nil
            }
        })
    } else {
        // Fallback on earlier versions
    }
}


/// 退出登录通知
///
/// - Parameter msg: 要现实的消息
func PostLogOutNotificationWith(msg:String?){
    let userInfo = [LOG_OUT_MESSAGE_KEY:msg]
    NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil, userInfo: userInfo)
}

/// 获取七牛云上传token
///
/// - Parameters:
///   - type: token类别，图片、视频
///   - onSuccess: 成功回调
func GetQiNiuUploadToken(type:MediaType,onSuccess: ((QNUploadTokenModel?)->Void)?,id:String? = nil,token:String? = nil){
    let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
    var tokenType = "image"
    if type == .video{
        tokenType = "video"
    }
    let getQNUploadToken = GetQNUploadToken(type: tokenType, id: id?.intValue(), token: token)
    _ = moyaProvider.rx.request(.targetWith(target: getQNUploadToken)).subscribe(onSuccess: { (response) in
        let qnUploadTokenModel = Mapper<QNUploadTokenModel>().map(jsonData: response.data)
        Toast.showErrorWith(model: qnUploadTokenModel)
        if let _onSuccess = onSuccess{
            _onSuccess(qnUploadTokenModel)
        }
    }, onError: { (error) in
        Toast.showErrorWith(msg: error.localizedDescription)
    })
}

func RequestQiNiuUploadToken(type:MediaType,onSuccess:((QNUploadTokenModel?)->Void)?,tokenIDModel:TokenIDModel? = nil){
    let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
    var tokenType = "image"
    if type == .video{
        tokenType = "video"
    }
    let getQNUploadToken = GetQNUploadToken(type: tokenType, id: tokenIDModel?.Id, token: tokenIDModel?.token)
    _ = moyaProvider.rx.request(.targetWith(target: getQNUploadToken)).subscribe(onSuccess: { (response) in
        let qnUploadTokenModel = Mapper<QNUploadTokenModel>().map(jsonData: response.data)
        if qnUploadTokenModel?.commonInfoModel?.status != successState{
            Toast.showErrorWith(model: qnUploadTokenModel)
        }
        if let _onSuccess = onSuccess{
            _onSuccess(qnUploadTokenModel)
        }
    }, onError: { (error) in
        Toast.showErrorWith(msg: error.localizedDescription)
    })}


func mjGifHeaderWith(refreshingBlock:@escaping MJRefreshComponentRefreshingBlock)->MJRefreshGifHeader{
    let header = MJRefreshGifHeader.init(refreshingBlock: refreshingBlock)
    //刷新动画图片数组
    var refreshImgs = [UIImage]()
    for i in 1...9{
        refreshImgs.append(UIImage.init(named: "loading_0\(i)")!)
    }
    header?.setImages(refreshImgs, for: .refreshing)
    header?.setImages([UIImage.init(named: "loading_shang")], for: .pulling)
    header?.setImages([UIImage.init(named: "loading_xia")], for: .idle)
    header?.lastUpdatedTimeLabel.isHidden = true
    header?.stateLabel.isHidden = true
    return header!
}

func mjGifFooterWith(refreshingBlock:@escaping MJRefreshComponentRefreshingBlock)->MJRefreshBackGifFooter{
    let header = MJRefreshBackGifFooter.init(refreshingBlock: refreshingBlock)
//    let header = MJRefreshAutoGifFooter.init(refreshingBlock: refreshingBlock)
    //刷新动画图片数组
    var refreshImgs = [UIImage]()
    for i in 1...9{
        refreshImgs.append(UIImage.init(named: "loading_0\(i)")!)
    }
    header?.setImages(refreshImgs, for: .refreshing)
    header?.setImages(refreshImgs, for: .pulling)
    header?.stateLabel.isHidden = true
//    header?.isRefreshingTitleHidden = true
    return header!
}

///和某人聊天
func ChatWith(toUserId:Int?,navigationController:UINavigationController? = nil){
    //请求对方accid
    if !NIMSDK.shared().loginManager.isLogined(){
        AppManager.shared.manualLoginIM(userId: nil, userToken: nil, handle: { (error) in
            if nil == error{
                Toast.showStatusWith(text: nil)
                let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
                let getImToken = GetIMToken.init(to_uid: toUserId, id: nil, token: nil)
                _ = moyaProvider.rx.request(.targetWith(target: getImToken)).subscribe(onSuccess: { (response) in
                    let imModel = Mapper<IMModel>().map(jsonData: response.data)
                    if imModel?.commonInfoModel?.status == successState{
                        if let _accid = imModel?.accid,let _ = imModel?.token{
                            let session = NIMSession.init((_accid), type: .P2P)
                            let sessionVC = NTESSessionViewController.init(session: session)
                            sessionVC?.defaultTitle = imModel?.name
                            if let _navigationController = navigationController{
                                _navigationController.pushViewController(sessionVC!, animated: true)
                            }else{
                                let tbc = UIApplication.shared.keyWindow?.rootViewController as! TabBarController
                                let nav = tbc.selectedViewController as! CustomNavigationController
                                nav.pushViewController(sessionVC!, animated: true)
                            }
                        }
                    }
                    Toast.showErrorWith(model: imModel)
                }) { (error) in
                    Toast.showErrorWith(msg: error.localizedDescription)
                }
            }
            if nil != error{
                Toast.showErrorWith(msg: error?.localizedDescription)
            }
        })
    }else{
        Toast.showStatusWith(text: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let getImToken = GetIMToken.init(to_uid: toUserId, id: nil, token: nil)
        _ = moyaProvider.rx.request(.targetWith(target: getImToken)).subscribe(onSuccess: { (response) in
            let imModel = Mapper<IMModel>().map(jsonData: response.data)
            if imModel?.commonInfoModel?.status == successState{
                if let _accid = imModel?.accid,let _ = imModel?.token{
                    let session = NIMSession.init((_accid), type: .P2P)
                    let sessionVC = NTESSessionViewController.init(session: session)
                    sessionVC?.defaultTitle = imModel?.name
                    if let _navigationController = navigationController{
                        _navigationController.pushViewController(sessionVC!, animated: true)
                    }else{
                        let tbc = UIApplication.shared.keyWindow?.rootViewController as! TabBarController
                        let nav = tbc.selectedViewController as! CustomNavigationController
                        nav.pushViewController(sessionVC!, animated: true)
                    }
                }
            }
            Toast.showErrorWith(model: imModel)
        }) { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        }
    }
}

enum ThirdPartAPP {
    ///支付宝
    case alipay
    ///微信
    case wechat
    ///高德地图
    case amap
    ///新浪微博
    case sina
    ///QQ
    case qq
    ///
}


func isInstalled(app:ThirdPartAPP)->Bool{
    let shareApplication = UIApplication.shared
    if app == .alipay{
        let url = URL.init(string: "alipay://")
        return shareApplication.canOpenURL(url!)
    }
    if app == .wechat{
        let url = URL.init(string: "weixin://")
        return shareApplication.canOpenURL(url!)
    }
    if app == .amap{
        let url = URL.init(string: "iosamap://")
        return shareApplication.canOpenURL(url!)
    }
    if app == .sina{
        let url = URL.init(string: "weibo://")
        return shareApplication.canOpenURL(url!)
    }
    if app == .qq{
        let url = URL.init(string: "mqq://")
        return shareApplication.canOpenURL(url!)
    }
    return false
}



