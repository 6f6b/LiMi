//
//  Extensions.swift
//  KWallet
//
//  Created by dev.liufeng on 2016/12/12.
//  Copyright © 2016年 cdu.com. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

//extension UIButton{
//    func isUsable(){
//        self.backgroundColor = appTitleColor
//        self.isUserInteractionEnabled = true
//    }
//    func noUsable(){
//        self.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
//        self.isUserInteractionEnabled = false
//    }
//}

extension UIImage {
    static func imageWithUIView(view: UIView)->UIImage{
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        let currentContext = UIGraphicsGetCurrentContext()
        view.layer.render(in: currentContext!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func cutCircleImage(view: UIView)->UIImage{
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        let currentContext = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        currentContext?.addEllipse(in: rect)
        currentContext?.clip()
        view.draw(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIImageView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UILabel {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension String{
//    func getRectSize(font:UIFont,width:CGFloat)->CGRect{
//        let attributes = [NSFontAttributeName:font]
//        let option = NSStringDrawingOptions.usesLineFragmentOrigin
//        let nsString = NSString.init(string: self)
//        let size = CGSize(width: width, height: 1000)
//        let rect = nsString.boundingRect(with: size, options: option, attributes: attributes, context: nil)
//        return rect
//    }
    
    func doubleValue()->Double?{
        let nsString = NSString.init(string: self)
        return nsString.doubleValue
    }
    
    // 设置字符串字体大小
//    func setStringAttributeFont(alterStr: String, size alterStrFontSize: CGFloat)->NSAttributedString {
//        let tempStr = self + alterStr
//        let length1 = (alterStr as NSString).length
//        let length2 = (self as NSString).length
//        let strAttrbute = NSMutableAttributedString(string: tempStr)
//        let range = NSRange(location: length2, length: length1)
//        strAttrbute.addAttribute(NSFontAttributeName, value: FONT(sizePlus: alterStrFontSize), range: range)
//
//        return strAttrbute
//    }
    
    func intValue()->Int{
        let nsString = NSString.init(string: self)
        return Int(nsString.intValue)
    }
    
    // 替换任意字符串中间的四个字符为 ****
    func replaceString()->String {
        let length = (self as NSString).length
        if length > 4{
            let location = (length-4)/2
            let str = (self as NSString).replacingCharacters(in: NSMakeRange(location, 4), with: "****")
            return str
        }else{
            return self
        }
        
    }
}

extension Double{
    func stringValue()->String{
        let string = String.init(format: "%.f", self)
        return string
    }
    
    //返回金额
    func decimalValue()->String{
        let format =  NumberFormatter()
        format.numberStyle = .decimal
        let balance = format.string(from: NSNumber.init(value: self))
        return balance!
    }
}

extension Float{
    func stringValue()->String{
        let string = String.init(format: "%f", self)
        return string
    }
}

extension Int{
    func stringValue()->String{
        let string = String.init(format: "%d", self)
        return string
    }
}

extension SVProgressHUD{
    //均显示
    static func showResultWith(model:BaseModel?){
        showSuccessWith(model: model)
        showErrorWith(model: model)
    }
    //只显示错误信息
    static func showErrorWith(model:BaseModel?){
        if let flag  = model?.commonInfoModel?.flag{
            if flag != successState{
                SVProgressHUD.showErrorWith(msg: model?.commonInfoModel?.msg)
            }
        }
    }
    //只显示成功信息
    static func showSuccessWith(model:BaseModel?){
        if let flag  = model?.commonInfoModel?.flag{
            if flag == successState{
                SVProgressHUD.showSuccessWith(msg: model?.commonInfoModel?.msg)
            }
        }
    }
    //显示自定义错误信息
    static func showErrorWith(msg:String?){
        if let msg = msg{
            SVProgressHUD.showError(withStatus: msg)
        }
        SVProgressHUD.dismiss(withDelay: 1.5)
    }
    //显示自定义成功信息
    static func showSuccessWith(msg:String?){
        if let msg = msg{
            SVProgressHUD.showSuccess(withStatus: msg)
        }
        SVProgressHUD.dismiss(withDelay: 1.5)
    }
    
}

extension Date{
    //根据时间获取年龄
    func getAge()->Int{
        let currenDate = Date(timeIntervalSinceNow: 0)
        let time = currenDate.timeIntervalSince(self)
        let age = Int(time)/(3600*24*365)
        return age
    }
    
//    //获取星座
//    func getConstellation()->String{
//        let nsDate = NSDate(timeInterval: 0, since: self)
//        switch nsDate.zodiacSign {
//        case .aquarius:
//            return "水瓶座"
//            break
//        case .pisces:
//            return "双鱼座"
//            break
//        case .aries:
//            return "白羊"
//            break
//        case .taurus:
//            return "金牛座"
//            break
//        case .gemini:
//            return "双子座"
//            break
//        case .cancer:
//            return "巨蟹座"
//            break
//        case .leo:
//            return "狮子座"
//            break
//        case .virgo:
//            return "处女座"
//            break
//        case .libra:
//            return "天秤座"
//            break
//        case .scorpio:
//            return "天蝎座"
//            break
//        case .sagittarius:
//            return "射手座"
//            break
//        case .capricorn:
//            return "摩羯座"
//            break
//        }
//        return ""
//    }
}

