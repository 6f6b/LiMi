//
//  RequestHandler.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation

func HandleResultWith(model:BaseModel?){
    //用户ID异常
    if model?.commonInfoModel?.code == 1000{
        PostLogOutNotificationWith(msg: model?.commonInfoModel?.msg)
    }
    if model?.commonInfoModel?.msg == "用户身份验证失败！"{
        PostLogOutNotificationWith(msg: model?.commonInfoModel?.msg)
    }
}
