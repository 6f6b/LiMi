//
//  RechargeController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD

class RechargeController: ViewController {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var rechargeAmount: UITextField!
    @IBOutlet weak var wechatRecharge: UIButton!
    @IBOutlet weak var alipayRecharge: UIButton!
    @IBOutlet weak var rechargeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "充值"
        
        self.heightConstraint.constant = SCREEN_HEIGHT-64
        
        let cancelBtn = UIButton.init(type: .custom)
        let cancelAttributeTitle = NSAttributedString.init(string: "取消", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)])
        cancelBtn.setAttributedTitle(cancelAttributeTitle, for: .normal)
        cancelBtn.sizeToFit()
        cancelBtn.addTarget(self, action: #selector(dealCancel), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: cancelBtn)
        
        self.containView.layer.cornerRadius = 10
        self.containView.clipsToBounds = true
        self.rechargeBtn.layer.cornerRadius = 20
        self.rechargeBtn.clipsToBounds = true
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

    //MARK: - misc
    @objc func dealCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dealSelectWechat(_ sender: Any) {
            self.wechatRecharge.isSelected  = !self.wechatRecharge.isSelected
            self.alipayRecharge.isSelected = !self.wechatRecharge.isSelected
    }
    
    @IBAction func dealSelectAlipay(_ sender: Any) {
        self.alipayRecharge.isSelected = !self.alipayRecharge.isSelected
        self.wechatRecharge.isSelected = !self.alipayRecharge.isSelected
    }
    
    @IBAction func dealToRecharge(_ sender: Any) {
        if !self.wechatRecharge.isSelected && !self.alipayRecharge.isSelected{
            SVProgressHUD.showInfo(withStatus: "请选择支付方式")
            return
        }
        if IsEmpty(textField: self.rechargeAmount){
            SVProgressHUD.showInfo(withStatus: "请输入充值金额")
            return
        }
    }
    
}
