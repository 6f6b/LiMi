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
    @IBOutlet weak var failedContainView: UIView!
    
    @IBOutlet weak var failedThenRePayBtn: UIButton!
    @IBOutlet weak var failedThenBackToHomeBtn: UIButton!
    
    @IBOutlet weak var successThenBackToHomeBtn: UIButton!
    @IBOutlet weak var successThenCheckOrderBtn: UIButton!
    
    var baseModel:BaseModel?
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showWith(model: self.baseModel)
    }
    
    func showWith(model:BaseModel?){
        if model?.commonInfoModel?.status == successState{
            self.failedContainView.isHidden = true
            self.successContainView.isHidden = false
        }else{
            self.failedContainView.isHidden = false
            self.successContainView.isHidden = true
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
