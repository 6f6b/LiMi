//
//  Helper.swift
//  SpaceFlight
//
//  Created by Min on 2017/8/1.
//  Copyright © 2017年 cdu.com. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
class Helper {
    /** 单一入口 */
    static let shareInstance = Helper()
    
    /** 设置和取字符串值 */
    static func setStringValue(key: String, token : String) {
        Defaults[key] = token
    }
    
    static func getStringValue(key: String) -> String? {
        return Defaults[key].string
    }

    /** 设置和取布尔值 */
    static func setBoolValue(key: String, token : Bool) {
        Defaults[key] = token
    }
    
    static func getBoolValue(key: String) -> Bool? {
        return Defaults[key].bool
    }
    
//    static func setRegister(token : Bool) {
//        Defaults["register"] = token
//    }
//    
//    static func getRegister() -> Bool {
//        return Defaults["register"].bool!
//    }
    
    /** 从storyboard获取ViewController */
    static func getViewControllerFrom(sbName:String,sbID:String) -> UIViewController {
        let sb = UIStoryboard.init(name: sbName, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: sbID)
        return vc
    }
    
    static func getViewFromXib(name:String)->UIView?{
        if  let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.last as? UIView{
            return view
        }
        return nil
    }
    /** 清理图片缓存 */
//    static func clearCacheWith(Type:ClearCacheType){
//        let cache = KingfisherManager.shared.cache
//        switch Type {
//        case .AllCache:
//            cache.clearDiskCache()//清除硬盘缓存
//            cache.clearMemoryCache()//清理网络缓存
//            cache.cleanExpiredDiskCache()//清理过期的，或者超过硬盘限制大小的
//        case .DiskCache:
//            cache.clearDiskCache()
//        case .ExpiredDiskCache:
//            cache.cleanExpiredDiskCache()
//        case .MemoryCache:
//            cache.clearMemoryCache()
//        }
//    }
    
    
    private init() {
    }
}

enum ClearCacheType {
    case DiskCache,MemoryCache,ExpiredDiskCache,AllCache
}
//
///** KingFisher网络加载图片 */
//extension UIImageView {
//    func setImageWith(Url:String?){
//        if let subUrl = Url{
//            let strUrl = serviceAddress+subUrl
//            if let url = URL.init(string: strUrl){
//                self.kf.setImage(with: ImageResource(downloadURL: url), placeholder: nil, options: [KingfisherOptionsInfoItem.transition(ImageTransition.none), KingfisherOptionsInfoItem.forceRefresh], progressBlock: nil, completionHandler: nil)
//            }
//        }
//    }
//}

