//
//  WithDrawalController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/31.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD

class WithDrawalController: ViewController {
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
        let cancelAttributeTitle = NSAttributedString.init(string: "取消", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)])
        cancelBtn.setAttributedTitle(cancelAttributeTitle, for: .normal)
        cancelBtn.sizeToFit()
        cancelBtn.addTarget(self, action: #selector(dealCancel), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: cancelBtn)
        
        if let _money = self.mycashModel?.money{
            self.ableToBeWithdrawal.text = _money.decimalValue()
            self.withDrawAmount.text = _money.decimalValue()
        }
        
        self.withDrawAmount.addTarget(self, action: #selector(textFeildDidChange(textField:)), for: .editingChanged)
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
    }

    //MARK: - misc
    @objc func dealCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dealTapAlipay(_ sender: Any) {
        let btn = sender as! UIButton
        btn.isSelected = !btn.isSelected
    }
    
    @IBAction func dealWithdrawal(_ sender: Any) {
        if IsEmpty(textField: self.withDrawAmount){
            SVProgressHUD.showInfo(withStatus: "请输入提现金额")
            return
        }
        if !self.alipayBtn.isSelected{
            SVProgressHUD.showInfo(withStatus: "请选择提现方式")
            return
        }
        if (self.withDrawAmount.text?.doubleValue())!  >  (self.ableToBeWithdrawal.text?.doubleValue())!{
            SVProgressHUD.showInfo(withStatus: "提现金额不能大于余额")
            return
        }
        let alipayAcountController = AlipayAcountController()
//        alipayAcountController.withdrawAmount = self.withDrawAmount.text
        alipayAcountController.withdrawAmount = "0.1"
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
