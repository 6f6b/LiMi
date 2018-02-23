//
//  AppManager.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

enum AppState {
    ///im登录，app登录
    case imOnlineBusinessOnline
    ///im登录，app未登录
    case imOnlineBusinessOffline
    ///im未登录，app登录
    case imOfflineBusinessOnline
    ///im未录，app未登录
    case imOffLineBusinessOffline
    ///其他
    case unknown
}
import Foundation
import SVProgressHUD

class AppManager:NSObject {
    static let shared = AppManager()
    
    
    /// 当前APP 登录状态以及 IM的登录状态
    ///
    /// - Returns:
    func appState()->AppState{
        let isImOnline = self.autoLoginIM()
        var isBusinessOnline = false
        if let _ = Defaults[.userId],let _ = Defaults[.userToken]{
            isBusinessOnline = true
        }
        /*****状态判断*****/
        if isImOnline && isBusinessOnline{return .imOnlineBusinessOnline}
        if isImOnline && !isBusinessOnline{return .imOnlineBusinessOffline}
        if !isImOnline && isBusinessOnline{return .imOfflineBusinessOnline}
        if !isImOnline && !isBusinessOnline{return .imOffLineBusinessOffline}
        return .unknown
    }
    
    
    /// 清空所有登录信息
    func resetAllLoginInfo(){
        Defaults[.userId] = nil //置空本地userid
        Defaults[.userToken] = nil  //置空本地usertoken
        Defaults[.userSex] = nil    //置空本地性别
        Defaults[.userCertificationState] = nil //置空本地认证状态
        Defaults[.userImToken] = nil    //置空im token
        Defaults[.userAccid] = nil  //置空accid
        NTESLoginManager.shared().currentLoginData = nil
        NTESServiceManager.shared().destory()
        NIMSDK.shared().loginManager.logout { (error) in
            if let _error = error{
                SVProgressHUD.showErrorWith(msg: _error.localizedDescription)
            }
        }
    }
    
    ///自动登录im,并返回登录状态
    ///
    /// - Returns: 是否为登录状态
    func autoLoginIM()->Bool{
        if NIMSDK.shared().loginManager.isLogined(){return true}else{
            if let _accid = Defaults[.userAccid], let _imToken = Defaults[.userImToken]{
                let autoLoginData = NIMAutoLoginData()
                autoLoginData.account = _accid.stringValue()
                autoLoginData.token = _imToken
                NIMSDK.shared().loginManager.autoLogin(autoLoginData)
                NTESServiceManager.shared().start()
            }
        }
        return NIMSDK.shared().loginManager.isLogined()
    }
        
}

