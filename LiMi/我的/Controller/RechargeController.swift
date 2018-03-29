//
//  RechargeController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import Moya
import ObjectMapper
import Dispatch

class RechargeController: ViewController {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var rechargeAmount: UITextField!
    @IBOutlet weak var wechatRecharge: UIButton!
    @IBOutlet weak var alipayRecharge: UIButton!
    @IBOutlet weak var rechargeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "充值"
        
        self.heightConstraint.constant = SCREEN_HEIGHT-64
        
        let cancelBtn = UIButton.init(type: .custom)
        let cancelAttributeTitle = NSAttributedString.init(string: "取消", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)])
        cancelBtn.setAttributedTitle(cancelAttributeTitle, for: .normal)
        cancelBtn.sizeToFit()
        cancelBtn.addTarget(self, action: #selector(dealCancel), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: cancelBtn)
        
        self.containView.layer.cornerRadius = 10
        self.containView.clipsToBounds = true
        self.rechargeBtn.layer.cornerRadius = 20
        self.rechargeBtn.clipsToBounds = true
        
        self.rechargeAmount.addTarget(self, action: #selector(textFeildDidChange(textField:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAlipayResultWith(notification:)), name: FINISHED_ALIPAY_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWXPayResultWith(notificaton:)), name: FINISHED_WXPAY_NOTIFICATION, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: FINISHED_ALIPAY_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: FINISHED_WXPAY_NOTIFICATION, object: nil)
        print("充值界面销毁")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    @objc func dealCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dealSelectWechat(_ sender: Any) {
            self.wechatRecharge.isSelected  = !self.wechatRecharge.isSelected
            self.alipayRecharge.isSelected = !self.wechatRecharge.isSelected
    }
    
    @IBAction func dealSelectAlipay(_ sender: Any) {
        self.alipayRecharge.isSelected = !self.alipayRecharge.isSelected
        self.wechatRecharge.isSelected = !self.alipayRecharge.isSelected
    }
    
    @IBAction func dealToRecharge(_ sender: Any) {
        if !self.wechatRecharge.isSelected && !self.alipayRecharge.isSelected{
            Toast.showInfoWith(text:"请选择支付方式")
            return
        }
        if IsEmpty(textField: self.rechargeAmount){
            Toast.showInfoWith(text:"请输入充值金额")
            return
        }
        if (self.rechargeAmount.text!.doubleValue()! > 200.0) || (self.rechargeAmount.text!.doubleValue()! < 10.0){
            Toast.showInfoWith(text: "单次充值金额10~200元")
            return
        }
        //判断是否安装了微信
        let payManager = PayManager.shared
        if self.alipayRecharge.isSelected{payManager.preRechageWith(payWay: .alipay, amountText: self.rechargeAmount.text)}
        if self.wechatRecharge.isSelected{payManager.preRechageWith(payWay: .wechatPay, amountText: self.rechargeAmount.text)}
    }
    
    
    @objc func handleAlipayResultWith(notification: Notification){
            let alipayResultContainModel = Mapper<AlipayResultContainModel>().map(JSONObject: notification.userInfo)
        if alipayResultContainModel?.resultStatus == "9000"{
            self.callServerPayStateWith(tradeNumber: alipayResultContainModel?.result?.alipay_trade_app_pay_response?.out_trade_no, type: "1")
        }else{
            self.showAliPayErrorWith(code: alipayResultContainModel?.resultStatus)
        }
    }
    
    @objc func handleWXPayResultWith(notificaton:Notification){
        let resp = notificaton.userInfo![WXPAY_RESULT_KEY] as! BaseResp
        if resp.errCode == WXSuccess.rawValue{
            self.callServerPayStateWith(tradeNumber: PayManager.shared.signedResultModel?.out_trade_no, type: "2")
        }else{
            Toast.showErrorWith(msg: resp.errStr)
        }
    }
    
    /// 向服务器查询支付结果信息
    ///
    /// - Parameters:
    ///   - tradeNumber: 交易流水号
    ///   - type: 支付类型
    func callServerPayStateWith(tradeNumber:String?,type:String?){
        let getPayStatus = GetPayStaus(order_no: tradeNumber, type: type)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: getPayStatus)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            Toast.showResultWith(model: resultModel)
            if resultModel?.commonInfoModel?.status == successState{
                let delayTime : TimeInterval = 1.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: {
                    self.dismiss(animated: true, completion: {
                        Toast.dismiss()
                    })
                })
            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    /// 向服务器查询支付宝支付信息
    ///
    /// - Parameter tadeNumber: 交易流水号
//    func callServerAliPayStateWith(tadeNumber:String?){
//        let getPayStatus = GetPayStaus(order_no: tadeNumber, type: "1")
//        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
//        _ = moyaProvider.rx.request(.targetWith(target: getPayStatus)).subscribe(onSuccess: { (response) in
//            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
//            Toast.showResultWith(model: resultModel)
//            if resultModel?.commonInfoModel?.status == successState{
//                let delayTime = DispatchTime(uptimeNanoseconds: UInt64(1.5))
//                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
//                    self.dismiss(animated: true, completion: {
//                        Toast.dismiss()
//                    })
//                })
//            }
//        }, onError: { (error) in
//            Toast.showErrorWith(msg: error.localizedDescription)
//        })
//    }
    
    
    /// 向服务器查询微信支付信息
    ///
    /// - Parameter tradeNumber: 交易流水号
//    func callServerWXPayStateWith(tradeNumber:String?){
//        let getPayStatus = GetPayStaus(order_no: tradeNumber, type: "2")
//        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
//        _ = moyaProvider.rx.request(.targetWith(target: getPayStatus)).subscribe(onSuccess: { (response) in
//            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
//            Toast.showResultWith(model: resultModel)
//            if resultModel?.commonInfoModel?.status == successState{
//                let delayTime = DispatchTime(uptimeNanoseconds: UInt64(1.5))
//                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
//                    self.dismiss(animated: true, completion: {
//                        Toast.dismiss()
//                    })
//                })
//            }
//        }, onError: { (error) in
//            Toast.showErrorWith(msg: error.localizedDescription)
//        })
//    }
    
    func showAliPayErrorWith(code:String?){
        //        9000    订单支付成功
        //        8000    正在处理中
        //        4000    订单支付失败
        //        6001    用户中途取消
        //        6002    网络连接出错
        //        99    用户点击忘记密码导致快捷界面退出(only iOS)
        if code == "8000"{Toast.showStatusWith(text: "正在处理中..")}
        if code == "4000"{Toast.showErrorWith(msg: "订单支付失败")}
        if code == "6001"{Toast.showErrorWith(msg: "取消支付")}
        if code == "6002"{Toast.showErrorWith(msg: "网络连接错误")}
        if code == "99"{Toast.showErrorWith(msg: "支付失败")}

    }
}

extension RechargeController{
    @objc func textFeildDidChange(textField:UITextField){
        if let text = textField.text,let amount = textField.text?.doubleValue(){
            let nsText = NSString.init(string: text)
            //不包含小数点
            if nsText.range(of: ".").location == NSNotFound{
                textField.text = String.init(format: "%d", Int(amount))
            }else{
                //包含小数点
                if let substrs = textField.text?.split(separator: "."){
                    if substrs.count == 2{
                        let decimalStr = substrs[1]
                        if decimalStr.count == 1{
                            textField.text = String.init(format: "%.1f", amount)
                        }
                        if decimalStr.count >= 2{
                            textField.text = String.init(format: "%.2f", amount)
                        }
                    }
                }
            }
        }
    }
}
