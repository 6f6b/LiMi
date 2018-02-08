////
////  AliSdkManager.swift
////  LiMi
////
////  Created by dev.liufeng on 2018/2/7.
////  Copyright © 2018年 dev.liufeng. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//public class AliSdkManager: NSObject {
//    public static var aliSdkManager:AliSdkManager!
//    internal var orderPayController:OrderPayController!
//
//    public static func sharedManager () -> AliSdkManager{
//        AliSdkManager.aliSdkManager = AliSdkManager.init()
//        return AliSdkManager.aliSdkManager
//    }
//    internal func showResult(result:NSDictionary){
//        //        9000  订单支付成功
//        //        8000  正在处理中
//        //        4000  订单支付失败
//        //        6001  用户中途取消
//        //        6002  网络连接出错
//        let returnCode:String = result["resultStatus"] as! String
//        var returnMsg:String = result["memo"] as! String
//        var subResultMsg:String = ""
//        switch  returnCode{
//        case "6001":
//            break
//        case "8000":
//            orderPayController.paySuccess(PaymentType.ALIPAY, payResult: PaymentResult.PROCESS)
//            break
//        case "4000":
//            orderPayController.paySuccess(PaymentType.ALIPAY, payResult: PaymentResult.FAIL)
//            break
//        case "9000":
//            returnMsg = "支付成功"
//            //支付返回信息：外系统订单号、内部系统订单号等信息
//            JSON.init(parseJSON: (result["result"] as! String))["alipay_trade_app_pay_response"]["sub_msg"].stringValue
//            orderPayController.paySuccess(PaymentType.ALIPAY, payResult: PaymentResult.SUCCESS)
//            break
//        default:
//            break
//        }
//    }
//}
//
//public class AliPayUtils: NSObject {
//    var context:UIViewController;
//
//    public init(context:UIViewController) {
//        self.context = context;
//    }
//
//    public func pay(sign:String){
//        let decodedData = sign.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
//        let decodedString:String = (NSString(data: decodedData, encoding: String.Encoding.utf8.rawValue))! as String
//
//        AlipaySDK.defaultService().payOrder(decodedString, fromScheme: "com.xmars.porsche.m2m", callback: { (resp) in
//            print(resp)
//        } )
//    }
//}
//
//作者：晴天mk1992
//链接：https://www.jianshu.com/p/9b75bd8e9001
//來源：简书
//著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

