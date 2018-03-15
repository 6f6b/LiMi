//
//  LoginController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import ObjectMapper
import Moya
import IQKeyboardManagerSwift

class LoginController: ViewController {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var veritificationCode: UITextField!
    @IBOutlet weak var errorMsg: UILabel!   //用来显示错误信息
    @IBOutlet weak var getVertificationCodeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.heightConstraint.constant = SCREEN_HEIGHT-20
        self.getVertificationCodeBtn.layer.cornerRadius = 12
        self.getVertificationCodeBtn.clipsToBounds = true
        self.getVertificationCodeBtn.layer.borderWidth = 1
        self.getVertificationCodeBtn.layer.borderColor = RGBA(r: 47, g: 213, b: 233, a: 1).cgColor
        if let phoneNum = Defaults[.userPhone]{
            self.phoneNum.text = phoneNum
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    deinit {
        print("登录销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - misc
    
    //进入用户协议
    @IBAction func dealToAgreement(_ sender: Any) {
        let userAgreementController = UserAgreementController()
        self.navigationController?.pushViewController(userAgreementController, animated: true)
    }
    //取消登录
    @IBAction func dealCancelLogin(_ sender: Any) {
        LoginServiceToMainController(loginRootController: self.navigationController)
        //self.dismiss(animated: true, completion: nil)
    }
    
    func showErrorMsgOnLabelWith(msg:String?){
        self.errorMsg.text = msg
        self.errorMsg.isHidden = false
    }
    
    //登录
    @IBAction func dealLogIn(_ sender: Any) {
//        var name:String?
//        print(name!)
        self.errorMsg.isHidden = true
        //检测手机号
        if !IS_PHONE_NUMBER(phoneNum: self.phoneNum.text){
            self.showErrorMsgOnLabelWith(msg: "手机号格式不正确")
            return
        }
        //检测验证码
        if IsEmpty(textField: self.veritificationCode){
            self.showErrorMsgOnLabelWith(msg: "请输入验证码")
            //Toast.showInfoWith(text:"请输入正确验证码")
            return
        }
        Toast.showStatusWith(text: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let login = Login(phone: self.phoneNum.text, code: self.veritificationCode.text)
        _ = moyaProvider.rx.request(.targetWith(target: login)).subscribe(onSuccess: { (response) in
            let loginModel = Mapper<LoginModel>().map(jsonData: response.data)
            if loginModel?.commonInfoModel?.status ==  successState{
                Defaults[.userPhone] = self.phoneNum.text
            }
            //未认证
//            if loginModel?.identity_status == 0{
                if loginModel?.user_info_status == 0{
                    //跳转性别、姓名填写界面
                    let finishPersonInfoController = FinishPersonInfoController()
                    finishPersonInfoController.loginModel = loginModel
                    self.navigationController?.pushViewController(finishPersonInfoController, animated: true)
                }else{
                    //存储userid、token
                    Defaults[.userId] = loginModel?.id
                    Defaults[.userToken] = loginModel?.token
                    if loginModel?.user_info_status == 1{
                        //进入大学信息填写界面
                        let identityAuthInfoController = GetViewControllerFrom(sbName: .loginRegister ,sbID: "IdentityAuthInfoController") as! IdentityAuthInfoController
                        self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
                    }
                    if loginModel?.user_info_status == 2{
                        //进入主界面
                        LoginServiceToMainController(loginRootController: self.navigationController)
                    }
                }
//            }
//            //认证中或者认证完成
//            if loginModel?.identity_status == 1 || loginModel?.identity_status == 2{}
//            //认证失败
//            if loginModel?.identity_status == 3{
//
//            }
            if loginModel?.commonInfoModel?.status != successState{
                self.showErrorMsgOnLabelWith(msg: loginModel?.commonInfoModel?.msg)
            }
            Toast.dismiss()
        }, onError: { (error) in
            self.showErrorMsgOnLabelWith(msg: error.localizedDescription)
            Toast.dismiss()
            //Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @IBAction func dealRequestVertificationCode(_ sender: Any) {
        self.errorMsg.isHidden = true
        if !IS_PHONE_NUMBER(phoneNum: self.phoneNum.text){
            self.showErrorMsgOnLabelWith(msg: "请输入正确的手机号")
            return
        }
        MakeAuthCodeBtnCannotBeHandleWith(button: sender as! UIButton)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let requestAuthCode = RequestAuthCode(phone: self.phoneNum.text)
        _ = moyaProvider.rx.request(.targetWith(target: requestAuthCode)).subscribe(onSuccess: { (response) in
            if let authCodeModel = Mapper<TmpAuthCodeModel>().map(jsonData: response.data){
                Toast.showSuccessWith(msg: authCodeModel.commonInfoModel?.msg)
            }
        }, onError: { (error) in
            self.showErrorMsgOnLabelWith(msg: error.localizedDescription)
            Toast.dismiss()
            //Toast.showErrorWith(msg: error.localizedDescription)
        })
    }

}
