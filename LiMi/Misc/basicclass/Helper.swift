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

    
    static func logOut(){
        //
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

