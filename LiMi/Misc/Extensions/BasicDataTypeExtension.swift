//
//  BasicDataTypeExtension.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation

//MARK: - String
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
    
//    func md5()->String{
//        let str = self.cString(using: String.Encoding.utf8)
//    }
//    var md5: String! {
//        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
//        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
//        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
//        CC_MD5(str!, strLen, result)
//        let hash = NSMutableString()
//        for i in 0..<digestLen {
//            hash.appendFormat("%02x", result[i])
//        }
//        result.dealloc(digestLen)
//        return String(hash)
//    }
}


extension Double{
    func stringValue()->String{
        let string = String.init(format: "%f", self)
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

extension CGPoint{
    func inRect(rect:CGRect)->Bool{
        let xIn = (self.x >= rect.origin.x)&&(self.x <= rect.maxX)
        let yIn = (self.y >= rect.origin.y)&&(self.y <= rect.maxY)
        if xIn && yIn{return true}
        return false
    }
}
