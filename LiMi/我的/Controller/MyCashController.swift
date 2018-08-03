//
//  MyCashController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import ObjectMapper
import SVProgressHUD
import Moya
//import

class MyCashController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}

    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var rechargeBtn: UIButton!
    @IBOutlet weak var withdrawalBtn: UIButton!
    @IBOutlet weak var setPayPwdBtn: UIButton!
    var userInfoModel:UserInfoModel?
    var mycashModel:MyCashModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的现金"
        
        self.balance.text = "0"
        
        let transactionRecordBtn = UIButton.init(type: .custom)
        let transactionRecordAttribute = NSAttributedString.init(string: "交易记录", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        transactionRecordBtn.setAttributedTitle(transactionRecordAttribute, for: .normal)
        transactionRecordBtn.sizeToFit()
        transactionRecordBtn.addTarget(self, action: #selector(dealToTransactionRecord), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: transactionRecordBtn)
        
//        if let _money = self.personCenterModel?.money{
//            self.balance.text = _money.decimalValue()
//        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }
    
    deinit {
        print("我的现金销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let myCash = MyCash()
        _ = moyaProvider.rx.request(.targetWith(target: myCash)).subscribe(onSuccess: { (response) in
            let mycashModel = Mapper<MyCashModel>().map(jsonData: response.data)
            self.refreshUIWith(model: mycashModel)
            Toast.showErrorWith(model: mycashModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func refreshUIWith(model:MyCashModel?){
        self.mycashModel = model
        if let _cash = model?.money{
            self.balance.text = _cash.decimalValue()
        }
        //0 设置了密码未被禁用 1：未设置密码 2：密码被禁用（错误次数过多）
        if model?.is_set_passwd == 0{
            self.setPayPwdBtn.setTitle("修改支付密码", for: .normal)
        }
        if model?.is_set_passwd == 1{
            self.setPayPwdBtn.setTitle("设置支付密码", for: .normal)
        }
        if model?.is_set_passwd == 2{
            self.setPayPwdBtn.setTitle("密码被禁用", for: .normal)
        }
    }
    
    @IBAction func dealRecharge(_ sender: Any) {
        let rechargeController = RechargeController()
        let rechargeNav = CustomNavigationController(rootViewController: rechargeController)
        self.present(rechargeNav, animated: true, completion: nil)
    }
    
    @IBAction func dealWithDrawal(_ sender: Any) {
        if let _myCahsModel = self.mycashModel{
            let withDrawalController = WithDrawalController()
            withDrawalController.mycashModel = _myCahsModel
            let withDrawalNav = CustomNavigationController(rootViewController: withDrawalController)
            self.present(withDrawalNav, animated: true, completion: nil)
        }else{
            Toast.showInfoWith(text:"请稍后..")
        }
    }
    
    @IBAction func dealToSetPayPassword(_ sender: Any) {
        let setPayPasswordController = SetPayPasswordController()
        self.navigationController?.pushViewController(setPayPasswordController, animated: true)
    }
    
    
    @objc func dealToTransactionRecord(){
        let transactionRecordController = TransactionRecordController()
        self.navigationController?.pushViewController(transactionRecordController, animated: true)
    }
}
