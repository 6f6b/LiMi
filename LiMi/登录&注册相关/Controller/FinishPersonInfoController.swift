//
//  FinishPersonInfoController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD

class FinishPersonInfoController: ViewController {
    @IBOutlet weak var realName: UITextField!
    @IBOutlet weak var girlPreImg: UIImageView!

    @IBOutlet weak var boyPreImg: UIImageView!
    
    @IBOutlet weak var nextBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "完善个人信息"
        self.nextBtn.layer.cornerRadius = 20
        self.nextBtn.clipsToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    //选择男性
    @IBAction func dealSelectBoy(_ sender: Any) {
        self.boyPreImg.isHidden = false
        self.girlPreImg.isHidden = true
    }
    
    //选择女性
    @IBAction func dealSelectGirl(_ sender: Any) {
        self.boyPreImg.isHidden = true
        self.girlPreImg.isHidden = false
    }
    
    @IBAction func dealTapNext(_ sender: Any) {
        //判断是否选择了性别
        if self.boyPreImg.isHidden == true && self.girlPreImg.isHidden == true{
            SVProgressHUD.showError(withStatus: "请选择性别")
            return
        }
        //判断是否填写了姓名
        if isEmpty(textField: self.realName){
            SVProgressHUD.showError(withStatus: "请输入姓名")
            return
        }
        let identityAuthInfoController = Helper.getViewControllerFrom(sbName: .loginRegister ,sbID: "IdentityAuthInfoController")
        self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
    }
}
