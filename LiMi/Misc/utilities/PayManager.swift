//
//  PayManager.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/7.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import SVProgressHUD
import ObjectMapper
import Moya

class PayManager {
    static let shareManager = PayManager()
    
    /// 向服务器统一下单、请求签名
    ///
    /// - Parameter payWay: 支付方式
    ///   - amountText: 支付金额
    func preRechageWith(payWay:PayWay,amountText:String?){
        let type = payWay == .alipay ? "1" : "2"
        let getRechargeOrderInfo = GetRechargeOrderInfo(money: amountText, type: type)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: getRechargeOrderInfo)).subscribe(onSuccess: { (response) in
            let signedResultModel = Mapper<SignedResultModel>().map(jsonData: response.data)
            HandleResultWith(model: signedResultModel)
            self.rechageWith(signedResultModel: signedResultModel, payWay: payWay)
            SVProgressHUD.showErrorWith(model: signedResultModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    /// 根据下单结果发起支付请求
    ///
    /// - Parameters:
    ///   - signedResultModel: 下单结果
    ///   - payWay: 支付方式
    func rechageWith(signedResultModel:SignedResultModel?,payWay:PayWay){
        if payWay == .alipay{
            if let code = signedResultModel?.alipay_signed_str{
                // NOTE: 调用支付结果开始支付
                AlipaySDK.defaultService().payOrder(code, fromScheme: APP_SCHEME, callback: { (resultDic) in
                    NotificationCenter.default.post(name: FINISHED_ALIPAY_NOTIFICATION, object: nil, userInfo: resultDic)
                })
            }
        }
        if payWay == .wechatPay{
            // NOTE: 组装支付信息开始调起微信
            let request =  PayReq()
            request.partnerId = signedResultModel?.partnerid
            request.prepayId = signedResultModel?.prepayid
            request.package = signedResultModel?.package
            request.nonceStr = signedResultModel?.noncestr
            if let _timeStamp = signedResultModel?.timestamp{
                request.timeStamp = _timeStamp
            }else{
                SVProgressHUD.showErrorWith(msg: "下单失败")
                return
            }
            request.sign = signedResultModel?.sign
            WXApi.send(request)
        }
    }
}
