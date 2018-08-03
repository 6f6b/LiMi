//
//  SetPayPasswordController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import Moya
import ObjectMapper

class SetPayPasswordController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}

    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var authCodeContainView: UIView!
    @IBOutlet weak var authCode: UITextField!
    @IBOutlet weak var requestAuthCodeBtn: UIButton!
    
    @IBOutlet weak var passwordFirstContainView: UIView!
    @IBOutlet weak var passwordFisrt: UITextField!
    
    @IBOutlet weak var passwordSecondContainView: UIView!
    @IBOutlet weak var passwordSecond: UITextField!
    @IBOutlet weak var sumbitBtn: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var isPopNavigationBarChange = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置支付密码"
        if let originalPhoneStr = Defaults[.userPhone]{
            let nsPhoneStr = NSString.init(string: originalPhoneStr)
            let handledPhoneStr = nsPhoneStr.replacingCharacters(in: NSRange.init(location: 3, length: 4), with: "****")
            self.info.text = "温馨提示：为了保障您的支付安全，需要验证您的账号身份：\(String.init(handledPhoneStr))"
        }
        self.heightConstraint.constant = SCREEN_HEIGHT-64
        
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
        
        self.authCodeContainView.layer.cornerRadius = 20
        self.authCodeContainView.clipsToBounds = true
        self.authCodeContainView.layer.borderColor = RGBA(r: 53, g: 53, b: 53, a: 1).cgColor
        self.authCodeContainView.layer.borderWidth = 1
        self.authCode.setValue(RGBA(r: 114, g: 114, b: 114, a: 1), forKeyPath: "_placeholderLabel.textColor")
        
        self.passwordFirstContainView.layer.cornerRadius = 20
        self.passwordFirstContainView.clipsToBounds = true
        self.passwordFirstContainView.layer.borderColor = RGBA(r: 53, g: 53, b: 53, a: 1).cgColor
        self.passwordFirstContainView.layer.borderWidth = 1
        self.passwordFisrt.setValue(RGBA(r: 114, g: 114, b: 114, a: 1), forKeyPath: "_placeholderLabel.textColor")
        
        self.passwordSecondContainView.layer.cornerRadius = 20
        self.passwordSecondContainView.clipsToBounds = true
        self.passwordSecondContainView.layer.borderColor = RGBA(r: 53, g: 53, b: 53, a: 1).cgColor
        self.passwordSecondContainView.layer.borderWidth = 1
        self.passwordSecond.setValue(RGBA(r: 114, g: 114, b: 114, a: 1), forKeyPath: "_placeholderLabel.textColor")

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
    }
    
    deinit {
        print("设置支付密码销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - misc
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
        if IsEmpty(textField: self.passwordFisrt){
            Toast.showInfoWith(text:"请输入密码")
            return
        }
        if IsEmpty(textField: self.passwordSecond){
            Toast.showInfoWith(text:"请输入确认密码")
            return
        }
        if !(self.passwordSecond.text == self.passwordFisrt.text){
            Toast.showInfoWith(text:"两次输入密码不一致")
            return
        }
        if self.passwordFisrt.text?.count != 6{
            Toast.showInfoWith(text:"请输入6位密码")
            return
        }
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let setPayPassword = SetPayPassword(code: self.authCode.text, password1: self.passwordFisrt.text, password2: self.passwordSecond.text)
        _ = moyaProvider.rx.request(.targetWith(target: setPayPassword)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            Toast.showResultWith(model: resultModel)
            if resultModel?.commonInfoModel?.status == successState{
                //延时1秒执行
                let delayTime : TimeInterval = 1
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: {
                    Toast.dismiss()
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}
