//
//  RewardRedPacketController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/20.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import Moya
import ObjectMapper

class RewardRedPacketController: ViewController {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountContainView: UIView!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var numContainView: UIView!
    @IBOutlet weak var num: UITextField!
    @IBOutlet weak var allSelected: UIButton!
    @IBOutlet weak var girlSelected: UIButton!
    @IBOutlet weak var boySelected: UIButton!
    @IBOutlet weak var redPacketBtn: UIButton!
    var sentRedPacketSuccessBlock:((Double,SendRedPacketResultModel?)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "打赏红包"
        self.heightConstraint.constant = SCREEN_HEIGHT-64
        self.dealSelectAll(self.allSelected)
        
        self.amountContainView.layer.cornerRadius = 25
        self.amountContainView.clipsToBounds = true
        
        self.numContainView.layer.cornerRadius = 25
        self.numContainView.clipsToBounds = true
        
        self.redPacketBtn.layer.cornerRadius = 25
        self.redPacketBtn.clipsToBounds = true
        
        self.amount.addTarget(self, action: #selector(textFeildDidChange(textField:)), for: .editingChanged)
        self.num.addTarget(self, action: #selector(textFeildDidChange(textField:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAlipayResultWith(notification:)), name: FINISHED_ALIPAY_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWXPayResultWith(notificaton:)), name: FINISHED_WXPAY_NOTIFICATION, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: FINISHED_ALIPAY_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: FINISHED_WXPAY_NOTIFICATION, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        let backBtn = UIButton.init(type: .custom)
        backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        backBtn.sizeToFit()
        backBtn.addTarget(self, action: #selector(dealBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
    }

    //MARK: - misc
    @objc func dealBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dealSelectAll(_ sender: Any) {
        self.allSelected.isSelected = true
        self.girlSelected.isSelected = false
        self.boySelected.isSelected = false
    }
    @IBAction func dealSelectGirl(_ sender: Any) {
        self.allSelected.isSelected = false
        self.girlSelected.isSelected = true
        self.boySelected.isSelected = false
    }
    @IBAction func dealSelectBoy(_ sender: Any) {
        self.allSelected.isSelected = false
        self.girlSelected.isSelected = false
        self.boySelected.isSelected = true
    }
    
    @IBAction func dealToGiveRedPacket(_ sender: Any) {
        if IsEmpty(textField: self.amount){
            SVProgressHUD.showInfo(withStatus: "请输入红包金额")
            return
        }
        if IsEmpty(textField: self.num){
            SVProgressHUD.showInfo(withStatus: "请输入红包个数")
            return
        }
        if self.amount.text!.doubleValue()! > 100.0{
            SVProgressHUD.showInfo(withStatus: "红包不能超过100元")
            return
        }
        if let _num = self.num.text?.intValue(){
            if _num < 1{
                SVProgressHUD.showInfo(withStatus: "至少发一个红包")
                return
            }
            if _num > 100{
                SVProgressHUD.showInfo(withStatus: "一次最多发100个红包")
                return
            }
        }
        
        if let amountValue = self.amount.text?.doubleValue(),let redPacketCount = self.num.text?.intValue(){
            if amountValue/Double(redPacketCount) < 0.01{
                SVProgressHUD.showInfo(withStatus: "每个红包至少0.01元")
                return
            }else{
                var type = 2
                if self.allSelected.isSelected{type = 2}
                if self.girlSelected.isSelected{type = 0}
                if self.boySelected.isSelected{type = 1}
                self.generatePayWayWith(amount: amountValue, count: redPacketCount, type: type)
            }
        }else{
            SVProgressHUD.showInfo(withStatus: "输入数值格式有误")
        }
    }
    
    //请求我的现金，判断金额是否足够，判断是否已经设置支付密码
    func generatePayWayWith(amount:Double,count:Int,type:Int){
        SVProgressHUD.show(withStatus: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let myCash = MyCash()
        _ = moyaProvider.rx.request(.targetWith(target: myCash)).subscribe(onSuccess: { (response) in
            let mycashModel = Mapper<MyCashModel>().map(jsonData: response.data)
            HandleResultWith(model: mycashModel)
            //账户余额
            if let _money = mycashModel?.money{
                //账户余额足够
//                if _money >= amount{
//                    //0 设置了密码未被禁用 1：未设置密码 2：密码被禁用（错误次数过多）
//                    //未设置密码
//                    if mycashModel?.is_set_passwd != 0{
//                        let setPayPasswordController = SetPayPasswordController()
//                        self.navigationController?.pushViewController(setPayPasswordController, animated: true)
//                    }else{
//                        let payPasswordInputView = GET_XIB_VIEW(nibName: "PayPasswordInputView") as! PayPasswordInputView
//                        payPasswordInputView.frame = SCREEN_RECT
//                        payPasswordInputView.amountValue = amount
//                        payPasswordInputView.finishedInputPasswordBlock = {(password) in
//                            self.dealPlugMoneyToRedPacketWith(money: amount, num: count, type: type, password: password)
//                        }
//                        UIApplication.shared.keyWindow?.addSubview(payPasswordInputView)
//                    }
//                }
//                //账户余额不足
//                if _money < amount{
                    let selectPayWayView = GET_XIB_VIEW(nibName: "SelectPayWayView") as! SelectPayWayView
                    selectPayWayView.selectPayWayBlock = {way in
                        PayManager.shared.preRechageWith(payWay: way, amountText: self.amount.text)
                    }
                    selectPayWayView.frame = SCREEN_RECT
                    UIApplication.shared.keyWindow?.addSubview(selectPayWayView)
//                }
            }else{
                SVProgressHUD.showErrorWith(msg: "网络错误")
            }
            SVProgressHUD.showErrorWith(model: mycashModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func dealPlugMoneyToRedPacketWith(money:Double?,num:Int,type:Int,password:String?,trade_no:String? = nil){
        SVProgressHUD.show(withStatus: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let personCenter = SendRedpacket(money: money, num: num, type: type, password: password)
        _ = moyaProvider.rx.request(.targetWith(target: personCenter)).subscribe(onSuccess: { (response) in
            let sendRedPacketResultModel = Mapper<SendRedPacketResultModel>().map(jsonData: response.data)
            if sendRedPacketResultModel?.commonInfoModel?.status == successState{
                if let _sentRedPacketSuccessBlock = self.sentRedPacketSuccessBlock{
                    _sentRedPacketSuccessBlock(money!,sendRedPacketResultModel)
                }
                //延时0.8秒执行
                let time: TimeInterval = 0.8
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            SVProgressHUD.showErrorWith(model: sendRedPacketResultModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    
    /// 处理支付宝的回调结果
    ///
    /// - Parameter notification:
    @objc func handleAlipayResultWith(notification: Notification){
        let alipayResultContainModel = Mapper<AlipayResultContainModel>().map(JSONObject: notification.userInfo)
        if alipayResultContainModel?.resultStatus == "9000"{
            var type = 2
            if self.allSelected.isSelected{type = 2}
            if self.girlSelected.isSelected{type = 0}
            if self.boySelected.isSelected{type = 1}
            let trandNum = alipayResultContainModel?.result?.alipay_trade_app_pay_response?.trade_no
            self.dealPlugMoneyToRedPacketWith(money: self.amount.text?.doubleValue(), num: (self.num.text?.intValue())!, type: type, password: nil, trade_no: trandNum)
        }else{
//            self.showAliPayErrorWith(code: alipayResultContainModel?.resultStatus)
        }
    }
    
    
    /// 处理微信支付回调结果
    ///
    /// - Parameter notificaton:
    @objc func handleWXPayResultWith(notificaton:Notification){
        let resp = notificaton.userInfo![WXPAY_RESULT_KEY] as! BaseResp
        if resp.errCode == WXSuccess.rawValue{
            var type = 2
            if self.allSelected.isSelected{type = 2}
            if self.girlSelected.isSelected{type = 0}
            if self.boySelected.isSelected{type = 1}
            self.dealPlugMoneyToRedPacketWith(money: self.amount.text?.doubleValue(), num: (self.num.text?.intValue())!, type: type, password: nil, trade_no: PayManager.shared.signedResultModel?.out_trade_no)
        }else{
            SVProgressHUD.showErrorWith(msg: resp.errStr)
        }
    }
}

extension RewardRedPacketController{
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
