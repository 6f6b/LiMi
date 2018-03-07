//
//  SVProgressHUDExtension.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import SVProgressHUD

extension SVProgressHUD{
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
    
//    //
//    //均显示
//    static func showResultWith(model:BaseModel?){
//        if model?.commonInfoModel?.status == successState{
//            showSuccessWith(model: model)
//        }else{
//            showErrorWith(model: model)
//        }
//    }
//    //只显示错误信息
//    static func showErrorWith(model:BaseModel?){
//        if let status  = model?.commonInfoModel?.status{
//            if status != successState{
//                //对错误信息进行截获
//                //如果code=1000
//                if model?.commonInfoModel?.code == 1000{
//                    SVProgressHUD.dismiss()
//                    HandleResultWith(model: model)
//                }else{
//                    SVProgressHUD.showErrorWith(msg: model?.commonInfoModel?.msg)
//                }
//            }else{SVProgressHUD.dismiss()}
//        }else{SVProgressHUD.dismiss()}
//    }
//    //只显示成功信息
//    static func showSuccessWith(model:BaseModel?){
//        if let status  = model?.commonInfoModel?.status{
//            if status == successState{
//                SVProgressHUD.showSuccessWith(msg: model?.commonInfoModel?.msg)
//            }else{SVProgressHUD.dismiss()}
//        }else{SVProgressHUD.dismiss()}
//    }
//    //显示自定义错误信息
//    static func showErrorWith(msg:String?){
//        if let msg = msg{
//            SVProgressHUD.showError(withStatus: msg)
//        }else{
//            SVProgressHUD.dismiss()
//        }
//        //SVProgressHUD.dismiss(withDelay: 1.5)
//    }
//    //显示自定义成功信息
//    static func showSuccessWith(msg:String?){
//        if let msg = msg{
//            SVProgressHUD.showSuccess(withStatus: msg)
//        }else{
//            SVProgressHUD.dismiss()
//        }
//        //SVProgressHUD.dismiss(withDelay: 1.5)
//    }
//
}
