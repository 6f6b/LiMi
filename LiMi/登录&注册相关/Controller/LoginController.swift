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
        self.dismiss(animated: true, completion: nil)
    }
    
    //登录
    @IBAction func dealLogIn(_ sender: Any) {
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let login = Login(phone: self.phoneNum.text, code: self.veritificationCode.text)
        _ = moyaProvider.rx.request(.targetWith(target: login)).subscribe(onSuccess: { (response) in
            do {
                let model = try response.mapObject(LoginModel.self)
                if model.commonInfoModel?.flag == successState{
                    let finishPersonInfoController = FinishPersonInfoController()
                    finishPersonInfoController.userIdParameters = model.id
                    finishPersonInfoController.tokenParameters = model.token
                    self.navigationController?.pushViewController(finishPersonInfoController, animated: true)
                }
                SVProgressHUD.showResultWith(model: model)
            }
            catch{SVProgressHUD.showErrorWith(msg: error.localizedDescription)}
            if let model = try? response.mapObject(BaseModel.self){
                SVProgressHUD.showResultWith(model: model)
            }
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @IBAction func dealRequestVertificationCode(_ sender: Any) {
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let requestAuthCode = RequestAuthCode(phone: self.phoneNum.text)
        _ = moyaProvider.rx.request(.targetWith(target: requestAuthCode)).subscribe(onSuccess: { (response) in
            do {
                let model = try response.mapObject(TmpAuthCodeModel.self)
                SVProgressHUD.showSuccessWith(msg: model.code)
            }
            catch{SVProgressHUD.showErrorWith(msg: error.localizedDescription)}
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }

}
