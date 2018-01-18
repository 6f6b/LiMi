//
//  RequestHandler.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation

func HandleResultWith(model:BaseModel?){
    if model?.commonInfoModel?.msg == "用户身份验证失败！"{
        let alertVC = UIAlertController.init(title: model?.commonInfoModel?.msg, message: nil, preferredStyle: .alert)
        let actionOK = UIAlertAction.init(title: "确定", style: .default) {_ in
            NotificationCenter.default.post(name: Notification.Name.init("logout"), object: nil, userInfo: nil)
        }
        alertVC.addAction(actionOK)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
    }
}
