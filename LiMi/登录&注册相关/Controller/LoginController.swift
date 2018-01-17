//
//  LoginController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/17.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import ObjectMapper
import Moya

class LoginController: UITableViewController {
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var veritificationCode: UITextField!
    @IBOutlet weak var errorMsg: UILabel!   //用来显示错误信息
    @IBOutlet weak var getVertificationCodeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 200
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //取消登录
    @IBAction func dealCancelLogin(_ sender: Any) {
        LoginServiceToMainController(loginRootController: self.navigationController)
        self.dismiss(animated: true, completion: nil)
    }
    
    func showErrorMsgOnLabelWith(msg:String?){
        self.errorMsg.text = msg
        self.errorMsg.isHidden = false
    }
    
    //登录
    @IBAction func dealLogIn(_ sender: Any) {
        self.errorMsg.isHidden = true
        //检测手机号
        if !IS_PHONE_NUMBER(phoneNum: self.phoneNum.text){
            self.showErrorMsgOnLabelWith(msg: "手机号格式不正确")
            return
        }
        //检测验证码
        if IsEmpty(textField: self.veritificationCode){
            self.showErrorMsgOnLabelWith(msg: "请输入验证码")
            //SVProgressHUD.showInfo(withStatus: "请输入正确验证码")
            return
        }
        SVProgressHUD.show(withStatus: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let login = Login(phone: self.phoneNum.text, code: self.veritificationCode.text)
        _ = moyaProvider.rx.request(.targetWith(target: login)).subscribe(onSuccess: { (response) in
            let loginModel = Mapper<LoginModel>().map(jsonData: response.data)
            if loginModel?.commonInfoModel?.status ==  successState{
                Defaults[.userPhone] = self.phoneNum.text
            }
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
            if loginModel?.commonInfoModel?.status != successState{
                self.showErrorMsgOnLabelWith(msg: loginModel?.commonInfoModel?.msg)
            }
            //SVProgressHUD.showErrorWith(model: loginModel)
            SVProgressHUD.dismiss()
        }, onError: { (error) in
            self.showErrorMsgOnLabelWith(msg: error.localizedDescription)
            SVProgressHUD.dismiss()
            //SVProgressHUD.showErrorWith(msg: error.localizedDescription)
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
                SVProgressHUD.showSuccess(withStatus: authCodeModel.code)
            }
        }, onError: { (error) in
            self.showErrorMsgOnLabelWith(msg: error.localizedDescription)
            SVProgressHUD.dismiss()
            //SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
