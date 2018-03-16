//
//  AppManager.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Moya
import ObjectMapper

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
    
    ///会话消息管理
    var conversationManager = NIMSDK.shared().conversationManager
    ///系统消息管理
    var systemNotificationManager = NIMSDK.shared().systemNotificationManager
    ///自定义系统消息管理
    var customSystemMessageManager = CustomSystemMessageManager.shared

    
    override init() {
        super.init()
        ///接收通过认证消息
        NotificationCenter.default.addObserver(self, selector: #selector(dealIdentityStatusOk), name: IDENTITY_STATUS_OK_NOTIFICATION, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: IDENTITY_STATUS_OK_NOTIFICATION, object: nil)
    }
    
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
                Toast.showErrorWith(msg: _error.localizedDescription)
            }
        }
    }
    
    ///根据本地存储的accid、IMtoken等信息，自动登录im,并返回登录状态
    ///
    /// - Returns: 是否为登录状态
    func autoLoginIM()->Bool{
        if NIMSDK.shared().loginManager.isLogined(){return true}else{
            if let _accid = Defaults[.userAccid], let _imToken = Defaults[.userImToken]{
                let autoLoginData = NIMAutoLoginData()
                autoLoginData.account = _accid
                autoLoginData.token = _imToken
                NIMSDK.shared().loginManager.autoLogin(autoLoginData)
                NTESServiceManager.shared().start()
            }
        }
        return NIMSDK.shared().loginManager.isLogined()
    }
    
    
    /// 向服务器请求accid、IMtoken等信息，并进行登录
    func manualLoginIM(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let getImToken = GetIMToken()
        _ = moyaProvider.rx.request(.targetWith(target: getImToken)).subscribe(onSuccess: { (response) in
            let imModel = Mapper<IMModel>().map(jsonData: response.data)
            if let _accid = imModel?.accid,let _token = imModel?.token{
                NIMSDK.shared().loginManager.login(_accid, token: _token, completion: { (error) in
                    if let _error = error{
                        Toast.showErrorWith(msg: _error.localizedDescription)
                    }
                })
            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    
    /// 检查用户状态，是否能进行操作
    ///
    /// - Returns: 是否能进行操作
    func checkUserStatus()->Bool{
        //判断是否登录
        if Defaults[.userId] == nil{
            NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil)
            return false
        }
        let certificationState = Defaults[.userCertificationState]
        //是否通过认证
        if certificationState == 0{
            let identityAuthInfoWithSexAndNameController = GetViewControllerFrom(sbName: .personalCenter, sbID: "IdentityAuthInfoWithSexAndNameController") as! IdentityAuthInfoWithSexAndNameController
            let tabBarController = UIApplication.shared.keyWindow?.rootViewController as! TabBarController
            let navController = tabBarController.selectedViewController as! NavigationController
            navController.pushViewController(identityAuthInfoWithSexAndNameController, animated: true)
            return false
        }
        if certificationState == 1{
            Toast.showInfoWith(text: "认证中")
            return false
        }
        if certificationState == 2{
        }
        if certificationState == 3{
            Toast.showInfoWith(text: "认证失败")
            return false
        }
        return true
    }
}

//认证通过通知
extension AppManager{
    @objc func dealIdentityStatusOk(){
        self.manualLoginIM()
    }
}
