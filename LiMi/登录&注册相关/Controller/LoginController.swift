//
//  LoginController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

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
        let finishPersonInfoController = FinishPersonInfoController()
        self.navigationController?.pushViewController(finishPersonInfoController, animated: true)
    }
    
    @IBAction func dealRequestVertificationCode(_ sender: Any) {
//        moyaProvider.request(.init(url: <#T##URLConvertible#>, method: <#T##HTTPMethod#>, headers: <#T##HTTPHeaders?#>), completion: <#T##Completion##Completion##(Result<Response, MoyaError>) -> Void#>)
    }

}
