//
//  PayResultController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class PayResultController: ViewController {
    @IBOutlet weak var successContainView: UIView!
    @IBOutlet weak var successInfo: UILabel!
    
    @IBOutlet weak var failedContainView: UIView!
    
    @IBOutlet weak var failedThenRePayBtn: UIButton!
    @IBOutlet weak var failedThenBackToHomeBtn: UIButton!
    
    @IBOutlet weak var successThenBackToHomeBtn: UIButton!
    @IBOutlet weak var successThenCheckOrderBtn: UIButton!
    
    var baseModel:BaseModel?
    override func viewDidLoad() {
        super.viewDidLoad()

        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
        
        self.failedThenRePayBtn.layer.cornerRadius = 5
        self.failedThenRePayBtn.clipsToBounds = true
        self.failedThenRePayBtn.layer.borderWidth = 1
        self.failedThenRePayBtn.layer.borderColor = APP_THEME_COLOR.cgColor
        
        self.failedThenBackToHomeBtn.layer.cornerRadius = 5
        self.failedThenBackToHomeBtn.clipsToBounds = true
        self.failedThenBackToHomeBtn.layer.borderWidth = 1
        self.failedThenBackToHomeBtn.layer.borderColor = RGBA(r: 153, g: 153, b: 153, a: 153).cgColor
        
        self.successThenBackToHomeBtn.layer.cornerRadius = 5
        self.successThenBackToHomeBtn.clipsToBounds = true
        self.successThenBackToHomeBtn.layer.borderWidth = 1
        self.successThenBackToHomeBtn.layer.borderColor = APP_THEME_COLOR.cgColor
        
        self.successThenCheckOrderBtn.layer.cornerRadius = 5
        self.successThenCheckOrderBtn.clipsToBounds = true
        self.successThenCheckOrderBtn.layer.borderWidth = 1
        self.successThenCheckOrderBtn.layer.borderColor = RGBA(r: 153, g: 153, b: 153, a: 153).cgColor
        
        let phoneText = "24小时内，我们会通过手机号与您联系；请保持电话通畅，如有疑问，请致电\(PHONE_NUMBER)"
        let nsPhoneText = NSString.init(string: phoneText)
        let phoneNumRange = nsPhoneText.range(of: PHONE_NUMBER)
        let attrPhoneText = NSMutableAttributedString.init(string: phoneText)
        attrPhoneText.yy_font = self.successInfo.font
        attrPhoneText.yy_color = self.successInfo.textColor
        attrPhoneText.yy_setTextHighlight(phoneNumRange, color: APP_THEME_COLOR, backgroundColor: nil) { (view, str, range, rect) in
            
        }
        self.successInfo.attributedText = attrPhoneText
        self.successInfo.yb_addAttributeTapAction(with: [PHONE_NUMBER], delegate: self)
    }

    deinit {
        print("订单结果销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showWith(model: self.baseModel)

        
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }
    
    func showWith(model:BaseModel?){
        if model?.commonInfoModel?.status == successState{
            self.failedContainView.isHidden = true
            self.successContainView.isHidden = false
            self.title = "支付成功"
        }else{
            self.failedContainView.isHidden = false
            self.successContainView.isHidden = true
            self.title = "支付失败"
        }
    }
    
    //Mark: - misc
    /**失败**/
    //重新支付
    @IBAction func failedThenRePay(_ sender: Any) {
        
    }
    
    //返回首页
    @IBAction func failedThenBackToHome(_ sender: Any) {
    self.navigationController?.popToRootViewController(animated: true)
    }
    
    /**成功**/
    //返回首页
    @IBAction func successThenBackToHome(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)

    }
    
    //查看订单
    @IBAction func successThenCheckOrder(_ sender: Any) {
        let myOrderListController = MyOrderListController()
        self.navigationController?.pushViewController(myOrderListController, animated: true)
    }
    
}

extension PayResultController:YBAttributeTapActionDelegate{
    func yb_attributeTapReturn(_ string: String!, range: NSRange, index: Int) {
        UIApplication.shared.openURL(URL(string: "tel:\(PHONE_NUMBER)")!)
    }
}
