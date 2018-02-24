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

class AlipayAcountController: ViewController {
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
        self.authCodeContainView.layer.borderColor = APP_THEME_COLOR.cgColor
        self.authCodeContainView.layer.borderWidth = 1
        
        self.alipayAcountContainView.layer.cornerRadius = 20
        self.alipayAcountContainView.clipsToBounds = true
        self.alipayAcountContainView.layer.borderColor = APP_THEME_COLOR.cgColor
        self.alipayAcountContainView.layer.borderWidth = 1
        
        self.alipayAcountNameContainView.layer.cornerRadius = 20
        self.alipayAcountNameContainView.clipsToBounds = true
        self.alipayAcountNameContainView.layer.borderColor = APP_THEME_COLOR.cgColor
        self.alipayAcountNameContainView.layer.borderWidth = 1
        
        self.sumbitBtn.layer.cornerRadius = 20
        self.sumbitBtn.clipsToBounds = true
        self.sumbitBtn.layer.borderColor = APP_THEME_COLOR.cgColor
        self.sumbitBtn.layer.borderWidth = 1
        
        self.containView.layer.cornerRadius = 10
        self.containView.clipsToBounds = true
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
        
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
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
                SVProgressHUD.showSuccess(withStatus: authCodeModel.code)
            }
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @IBAction func dealToSumbit(_ sender: Any) {
        if IsEmpty(textField: self.authCode){
            SVProgressHUD.showInfo(withStatus: "请输入验证码")
            return
        }
        if IsEmpty(textField: self.alipayAcount){
            SVProgressHUD.showInfo(withStatus: "请输入支付宝账号")
            return
        }
        if IsEmpty(textField: self.alipayAcountName){
            SVProgressHUD.showInfo(withStatus: "请输入支付宝账户名")
            return
        }
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        
        let withDrawCash = WithdrawCash(money: self.withdrawAmount.doubleValue(), account: self.alipayAcount.text, true_name: self.alipayAcountName.text, code: self.authCode.text)
        _ = moyaProvider.rx.request(.targetWith(target: withDrawCash)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            SVProgressHUD.showResultWith(model: resultModel)
            if resultModel?.commonInfoModel?.status == successState{
                let delayTime:TimeInterval = 1.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delayTime, execute: {
                    SVProgressHUD.dismiss()
                    NotificationCenter.default.post(name: WITHDRAW_SUCCESSED_NOTIFICATION, object: nil)
                })
            }
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
}
