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

class SetPayPasswordController: ViewController {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置支付密码"
        if let originalPhoneStr = Defaults[.userPhone]{
            let nsPhoneStr = NSString.init(string: originalPhoneStr)
            let handledPhoneStr = nsPhoneStr.replacingCharacters(in: NSRange.init(location: 3, length: 4), with: "****")
            self.info.text = "温馨提示：为了保障您的支付安全，需要验证您的账号身份：\(String.init(handledPhoneStr))"
        }
        self.heightConstraint.constant = SCREEN_HEIGHT-64
        
        let backBtn = UIButton.init(type: .custom)
        backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        backBtn.sizeToFit()
        backBtn.addTarget(self, action: #selector(dealBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
        
        self.authCodeContainView.layer.cornerRadius = 20
        self.authCodeContainView.clipsToBounds = true
        self.authCodeContainView.layer.borderColor = APP_THEME_COLOR.cgColor
        self.authCodeContainView.layer.borderWidth = 1
        
        self.passwordFirstContainView.layer.cornerRadius = 20
        self.passwordFirstContainView.clipsToBounds = true
        self.passwordFirstContainView.layer.borderColor = APP_THEME_COLOR.cgColor
        self.passwordFirstContainView.layer.borderWidth = 1
        
        self.passwordSecondContainView.layer.cornerRadius = 20
        self.passwordSecondContainView.clipsToBounds = true
        self.passwordSecondContainView.layer.borderColor = APP_THEME_COLOR.cgColor
        self.passwordSecondContainView.layer.borderWidth = 1
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - misc
    
    @objc func dealBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
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
        if IsEmpty(textField: self.passwordFisrt){
            SVProgressHUD.showInfo(withStatus: "请输入密码")
            return
        }
        if IsEmpty(textField: self.passwordSecond){
            SVProgressHUD.showInfo(withStatus: "请输入确认密码")
            return
        }
        if !(self.passwordSecond.text == self.passwordFisrt.text){
            SVProgressHUD.showInfo(withStatus: "两次输入密码不一致")
            return
        }
        if self.passwordFisrt.text?.count != 6{
            SVProgressHUD.showInfo(withStatus: "请输入6位密码")
            return
        }
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let setPayPassword = SetPayPassword(code: self.authCode.text, password1: self.passwordFisrt.text, password2: self.passwordSecond.text)
        _ = moyaProvider.rx.request(.targetWith(target: setPayPassword)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            SVProgressHUD.showResultWith(model: resultModel)
            if resultModel?.commonInfoModel?.status == successState{
                self.navigationController?.popViewController(animated: true)
            }
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}
