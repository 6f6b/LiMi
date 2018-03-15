//
//  Toast.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/7.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class Toast: NSObject {
    
    ///消失
    static func dismiss(){
        ToastView.shared.dissmiss()
    }
    
    ///单纯显示文本信息
    static func showInfoWith(text:String?){
        ToastView.shared.showInfoWith(text: text)
    }
    
    ///耗时操作下的显示
    static func showStatusWith(text:String?){
        ToastView.shared.showStatusWith(text: text)
    }
    
    //均显示
    static func showResultWith(model:BaseModel?){
        if model?.commonInfoModel?.status == successState{
            showSuccessWith(model: model)
        }else{
            showErrorWith(model: model)
        }
    }
    //只显示错误信息
    static func showErrorWith(model:BaseModel?){
        if let status  = model?.commonInfoModel?.status{
            if status != successState{
                //对错误信息进行截获
                //如果code=1000
                if model?.commonInfoModel?.code == 1000{
                    ToastView.shared.dissmiss()
                    HandleResultWith(model: model)
                }else{
                    ToastView.shared.showErrorWith(text: model?.commonInfoModel?.msg)
                }
            }else{ToastView.shared.dissmiss()}
        }else{ToastView.shared.dissmiss()}
    }
    //只显示成功信息
    static func showSuccessWith(model:BaseModel?){
        if let status  = model?.commonInfoModel?.status{
            if status == successState{
                ToastView.shared.showSuccessWith(text: model?.commonInfoModel?.msg)
            }else{ToastView.shared.dissmiss()}
        }else{ToastView.shared.dissmiss()}
    }
    //显示自定义错误信息
    static func showErrorWith(msg:String?){
        if let msg = msg{
            ToastView.shared.showErrorWith(text: msg)
        }else{
            ToastView.shared.dissmiss()
        }
    }
    //显示自定义成功信息
    static func showSuccessWith(msg:String?){
        if let msg = msg{
            ToastView.shared.showSuccessWith(text: msg)
        }else{
            ToastView.shared.dissmiss()
        }
    }
    
}
