//
//  GlobalFunction.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import UIKit

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
        let regex = "^1(3|4|5|7|8)\\d{9}$"
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

//压缩图片
func CompressImgWith(img:UIImage?,maxKB:Double)->UIImage?{
    if let originalImg = img{
        //计算零压缩条件下的大小
        let tempData = UIImageJPEGRepresentation(originalImg, 1)
        //压缩率
        var compRatio = 1.0
        if maxKB*1024/Double((tempData?.count)!)<1.0{
            compRatio = maxKB*1024/Double((tempData?.count)!)
        }
        //将Image图片转为JPEG格式的二进制数据
        let data = UIImageJPEGRepresentation(originalImg, CGFloat(compRatio))
        let finalImg = UIImage.init(data: data!)
        return finalImg
    }else{return nil}
}

//生成本地上传地址
func GenerateImgUrlWith(img:UIImage?)->URL?{
    if let unpackImg = img{
        let tempDir = NSTemporaryDirectory()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyymmddhhmmss"
        let timeStr = dateFormatter.string(from: Date())
        let imgName = timeStr + "i.png"
        let imgPath = tempDir+imgName
        let fileUrl = URL.init(fileURLWithPath: imgPath)
        do{
            try UIImageJPEGRepresentation(unpackImg, 1)?.write(to: fileUrl)
        }catch{
            return nil
        }
        return fileUrl
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
    if let tbController = UIApplication.shared.keyWindow?.rootViewController as? TabBarController{
        tbController.selectedIndex = 0
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

/// 根据传入颜色生成一张导航栏图片
///
/// - Parameter color: 传入颜色
/// - Returns: 生成的图片
func GetNavBackImg(color:UIColor)->UIImage{
    let layer = CAGradientLayer()
    let frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 64)
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
