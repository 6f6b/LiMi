//
//  IdentityAuthStateController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit


enum IdentityAuthState {
    case inProcessing
    case finished
}
class IdentityAuthStateController: UIViewController {
    @IBOutlet weak var stateImg: UIImageView!
    @IBOutlet weak var stateInfo: UILabel!
    @IBOutlet weak var stateBtn: UIButton!
    var state:IdentityAuthState = .inProcessing
    var isFromPersonCenter = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "学生认证"
        self.stateBtn.layer.cornerRadius = 20
        self.stateBtn.clipsToBounds = true
        self.refreshUIWith(state: self.state)
    }

    func refreshUIWith(state:IdentityAuthState){
        switch state {
        case .inProcessing:
            self.stateImg.image = UIImage.init(named: "tijiao")
            self.stateInfo.text = "已提交认证，预计5~10分钟"
            self.stateBtn.setTitle("返回首页", for: .normal)
            break
        case .finished:
            self.stateImg.image = UIImage.init(named: "tonguo")
            self.stateInfo.text = "身份认证已通过"
            self.stateBtn.setTitle("开启互助之旅", for: .normal)
            break
        }
    }
    
    deinit {
        print("认证状态销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func dealTapStateBtn(_ sender: Any) {
        if isFromPersonCenter{
            self.navigationController?.popToRootViewController(animated: true)
            //self.navigationController?.popViewController(animated: true)
        }else{
            LoginServiceToMainController(loginRootController: self.navigationController)
        }
    }
    
}
