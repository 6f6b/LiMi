//
//  RewardRedPacketController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/20.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD

class RewardRedPacketController: ViewController {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountContainView: UIView!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var numContainView: UIView!
    @IBOutlet weak var num: UITextField!
    @IBOutlet weak var allSelected: UIButton!
    @IBOutlet weak var girlSelected: UIButton!
    @IBOutlet weak var boySelected: UIButton!
    @IBOutlet weak var redPacketBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "打赏红包"
        self.heightConstraint.constant = SCREEN_HEIGHT-64
        self.dealSelectAll(self.allSelected)
        
        self.amountContainView.layer.cornerRadius = 25
        self.amountContainView.clipsToBounds = true
        
        self.numContainView.layer.cornerRadius = 25
        self.numContainView.clipsToBounds = true
        
        self.redPacketBtn.layer.cornerRadius = 25
        self.redPacketBtn.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        let backBtn = UIButton.init(type: .custom)
        backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        backBtn.sizeToFit()
        backBtn.addTarget(self, action: #selector(dealBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
    }

    //MARK: - misc
    @objc func dealBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dealSelectAll(_ sender: Any) {
        self.allSelected.isSelected = true
        self.girlSelected.isSelected = false
        self.boySelected.isSelected = false
    }
    @IBAction func dealSelectGirl(_ sender: Any) {
        self.allSelected.isSelected = false
        self.girlSelected.isSelected = true
        self.boySelected.isSelected = false
    }
    @IBAction func dealSelectBoy(_ sender: Any) {
        self.allSelected.isSelected = false
        self.girlSelected.isSelected = false
        self.boySelected.isSelected = true
    }
    
    @IBAction func dealToGiveRedPacket(_ sender: Any) {
        if IsEmpty(textField: self.amount){
            SVProgressHUD.showInfo(withStatus: "请输入红包金额")
            return
        }
        if IsEmpty(textField: self.num){
            SVProgressHUD.showInfo(withStatus: "请输入红包个数")
            return
        }
        if let amountValue = self.amount.text?.doubleValue(),let redPacketCount = self.num.text?.intValue(){
            if amountValue/Double(redPacketCount) < 0.01{
                SVProgressHUD.showInfo(withStatus: "每个红包至少0.01元")
                return
            }else{
                if amountValue >= 100{
                    let selectPayWayView = GET_XIB_VIEW(nibName: "SelectPayWayView") as! SelectPayWayView
                    selectPayWayView.frame = SCREEN_RECT
                    UIApplication.shared.keyWindow?.addSubview(selectPayWayView)
                }else{
                    let payPasswordInputView = GET_XIB_VIEW(nibName: "PayPasswordInputView") as! PayPasswordInputView
                    payPasswordInputView.frame = SCREEN_RECT
                    payPasswordInputView.amountValue = amountValue
                    UIApplication.shared.keyWindow?.addSubview(payPasswordInputView)
                }
            }
        }else{
            SVProgressHUD.showInfo(withStatus: "输入数值格式有误")
        }
    }
    
}
