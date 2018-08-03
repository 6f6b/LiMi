//
//  AlipayAcountController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/31.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import ObjectMapper

class AlipayAcountController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}

    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var authCodeContainView: UIView!
    @IBOutlet weak var authCode: UITextField!
    @IBOutlet weak var requestAuthCodeBtn: UIButton!
    
    @IBOutlet weak var alipayAcountContainView: UIView!
    @IBOutlet weak var alipayAcount: UITextField!
    
    @IBOutlet weak var alipayAcountNameContainView: UIView!
    @IBOutlet weak var alipayAcountName: UITextField!
    @IBOutlet weak var sumbitBtn: UIButton!
    
    var withdrawAmount:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "支付宝账号"
        
        if let originalPhoneStr = Defaults[.userPhone]{
            let nsPhoneStr = NSString.init(string: originalPhoneStr)
            let handledPhoneStr = nsPhoneStr.replacingCharacters(in: NSRange.init(location: 3, length: 4), with: "****")
            self.info.text = "温馨提示：为了保障您的支付安全，需要验证您的账号身份：\(String.init(handledPhoneStr))"
        }
        
        self.authCodeContainView.layer.cornerRadius = 20
        self.authCodeContainView.clipsToBounds = true
        self.authCodeContainView.layer.borderColor = RGBA(r: 53, g: 53, b: 53, a: 53).cgColor
        self.authCodeContainView.layer.borderWidth = 1
        self.authCode.setValue(RGBA(r: 114, g: 114, b: 114, a: 1), forKeyPath: "_placeholderLabel.textColor")
        
        self.alipayAcountContainView.layer.cornerRadius = 20
        self.alipayAcountContainView.clipsToBounds = true
        self.alipayAcountContainView.layer.borderColor = RGBA(r: 53, g: 53, b: 53, a: 53).cgColor
        self.alipayAcountContainView.layer.borderWidth = 1
        self.alipayAcount.setValue(RGBA(r: 114, g: 114, b: 114, a: 1), forKeyPath: "_placeholderLabel.textColor")

        
        self.alipayAcountNameContainView.layer.cornerRadius = 20
        self.alipayAcountNameContainView.clipsToBounds = true
        self.alipayAcountNameContainView.layer.borderColor = RGBA(r: 53, g: 53, b: 53, a: 53).cgColor
        self.alipayAcountNameContainView.layer.borderWidth = 1
        self.alipayAcountName.setValue(RGBA(r: 114, g: 114, b: 114, a: 1), forKeyPath: "_placeholderLabel.textColor")
        
        self.sumbitBtn.layer.cornerRadius = 20
        self.sumbitBtn.clipsToBounds = true
        
        self.containView.layer.cornerRadius = 10
        self.containView.clipsToBounds = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
    }
    
    deinit {
        print("支付宝提现销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    
    @IBAction func dealToRequestAuthCode(_ sender: Any) {
        MakeAuthCodeBtnCannotBeHandleWith(button: sender as! UIButton)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let requestAuthCode = RequestAuthCode(phone: Defaults[.userPhone])
        _ = moyaProvider.rx.request(.targetWith(target: requestAuthCode)).subscribe(onSuccess: { (response) in
            if let authCodeModel = Mapper<TmpAuthCodeModel>().map(jsonData: response.data){
                Toast.showResultWith(model: authCodeModel)
            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @IBAction func dealToSumbit(_ sender: Any) {
        if IsEmpty(textField: self.authCode){
            Toast.showInfoWith(text:"请输入验证码")
            return
        }
        if IsEmpty(textField: self.alipayAcount){
            Toast.showInfoWith(text:"请输入支付宝账号")
            return
        }
        if IsEmpty(textField: self.alipayAcountName){
            Toast.showInfoWith(text:"请输入支付宝账户名")
            return
        }
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        
        let withDrawCash = WithdrawCash(money: self.withdrawAmount.doubleValue(), account: self.alipayAcount.text, true_name: self.alipayAcountName.text, code: self.authCode.text)
        _ = moyaProvider.rx.request(.targetWith(target: withDrawCash)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            Toast.showResultWith(model: resultModel)
            if resultModel?.commonInfoModel?.status == successState{
                let delayTime:TimeInterval = 1.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delayTime, execute: {
                    Toast.dismiss()
                    NotificationCenter.default.post(name: WITHDRAW_SUCCESSED_NOTIFICATION, object: nil)
                })
            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}
