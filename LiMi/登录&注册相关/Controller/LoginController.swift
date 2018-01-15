//
//  LoginController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import ObjectMapper
import Moya

class LoginController: ViewController {
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var veritificationCode: UITextField!
    @IBOutlet weak var errorMsg: UILabel!   //用来显示错误信息
    @IBOutlet weak var getVertificationCodeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getVertificationCodeBtn.layer.cornerRadius = 12
        self.getVertificationCodeBtn.clipsToBounds = true
        self.getVertificationCodeBtn.layer.borderWidth = 1
        self.getVertificationCodeBtn.layer.borderColor = RGBA(r: 47, g: 213, b: 233, a: 1).cgColor
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //取消登录
    @IBAction func dealCancelLogin(_ sender: Any) {
        Helper.loginServiceToMainController(loginRootController: self.navigationController)
        self.dismiss(animated: true, completion: nil)
    }
    
    //登录
    @IBAction func dealLogIn(_ sender: Any) {
        SVProgressHUD.show(withStatus: nil)
         let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let login = Login(phone: self.phoneNum.text, code: self.veritificationCode.text)
        _ = moyaProvider.rx.request(.targetWith(target: login)).subscribe(onSuccess: { (response) in
            let loginModel = Mapper<LoginModel>().map(jsonData: response.data)
            if loginModel?.user_info_status == 0{
                    //跳转性别、姓名填写界面
                    let finishPersonInfoController = FinishPersonInfoController()
                    finishPersonInfoController.loginModel = loginModel
                    self.navigationController?.pushViewController(finishPersonInfoController, animated: true)
            }else{
                //存储userid、token
                Helper.saveUserId(userId: loginModel?.id)
                Helper.saveToken(token: loginModel?.token)
                if loginModel?.user_info_status == 1{
                    //进入大学信息填写界面
                    let identityAuthInfoController = Helper.getViewControllerFrom(sbName: .loginRegister ,sbID: "IdentityAuthInfoController") as! IdentityAuthInfoController
                    self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
                }
                if loginModel?.user_info_status == 2{
                    Helper.loginServiceToMainController(loginRootController: self.navigationController)
                }
            }
            SVProgressHUD.showErrorWith(model: loginModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @IBAction func dealRequestVertificationCode(_ sender: Any) {
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let requestAuthCode = RequestAuthCode(phone: self.phoneNum.text)
        _ = moyaProvider.rx.request(.targetWith(target: requestAuthCode)).subscribe(onSuccess: { (response) in
            if let authCodeModel = Mapper<TmpAuthCodeModel>().map(jsonData: response.data){
                SVProgressHUD.showSuccess(withStatus: authCodeModel.code)
            }
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }

}
