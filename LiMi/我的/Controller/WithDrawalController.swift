//
//  WithDrawalController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/31.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD

class WithDrawalController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}

    @IBOutlet weak var withdrawalContainView: UIView!
    @IBOutlet weak var ableToBeWithdrawal: UILabel! //可提现金额
    @IBOutlet weak var withDrawAmount: UITextField! //提现金额
    @IBOutlet weak var alipayBtn: UIButton!
    @IBOutlet weak var withdrawalBtn: UIButton!
    var mycashModel:MyCashModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "提现"
        
        self.withdrawalContainView.layer.cornerRadius = 10
        self.withdrawalBtn.layer.cornerRadius = 20
        self.withdrawalBtn.clipsToBounds = true
        
        let cancelBtn = UIButton.init(type: .custom)
        let cancelAttributeTitle = NSAttributedString.init(string: "取消", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        cancelBtn.setAttributedTitle(cancelAttributeTitle, for: .normal)
        cancelBtn.sizeToFit()
        cancelBtn.addTarget(self, action: #selector(dealCancel), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: cancelBtn)
        
        if let _money = self.mycashModel?.money{
            self.ableToBeWithdrawal.text = _money.decimalValue()
            //self.withDrawAmount.text = _money.decimalValue()
        }
        
        self.withDrawAmount.addTarget(self, action: #selector(textFeildDidChange(textField:)), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(dealWithdrawSuccessed), name: WITHDRAW_SUCCESSED_NOTIFICATION, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: WITHDRAW_SUCCESSED_NOTIFICATION, object: nil)
        print("提现界面销毁")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    //MARK: - misc
    @objc func dealWithdrawSuccessed(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func dealCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dealTapAlipay(_ sender: Any) {
        let btn = sender as! UIButton
        btn.isSelected = !btn.isSelected
    }
    
    @IBAction func dealWithdrawal(_ sender: Any) {
        if IsEmpty(textField: self.withDrawAmount){
            Toast.showInfoWith(text:"请输入提现金额")
            return
        }
        if !self.alipayBtn.isSelected{
            Toast.showInfoWith(text:"请选择提现方式")
            return
        }
        if (self.withDrawAmount.text?.doubleValue())!  >  (self.ableToBeWithdrawal.text?.doubleValue())!{
            Toast.showInfoWith(text:"余额不足")
            return
        }
        if self.withDrawAmount.text!.doubleValue()! < 10.0 || self.withDrawAmount.text!.doubleValue()! > 2000.0{
            Toast.showInfoWith(text: "单次提现金额：10~2000元")
            return
        }
        let alipayAcountController = AlipayAcountController()
        alipayAcountController.withdrawAmount = self.withDrawAmount.text
        self.navigationController?.pushViewController(alipayAcountController, animated: true)
    }
    
}

extension WithDrawalController{
    @objc func textFeildDidChange(textField:UITextField){
        if let text = textField.text,let amount = textField.text?.doubleValue(){
            let nsText = NSString.init(string: text)
            //不包含小数点
            if nsText.range(of: ".").location == NSNotFound{
                textField.text = String.init(format: "%d", Int(amount))
            }else{
                //包含小数点
                if let substrs = textField.text?.split(separator: "."){
                    if substrs.count == 2{
                        let decimalStr = substrs[1]
                        if decimalStr.count == 1{
                            textField.text = String.init(format: "%.1f", amount)
                        }
                        if decimalStr.count >= 2{
                            textField.text = String.init(format: "%.2f", amount)
                        }
                    }
                }
            }
        }
    }
}
