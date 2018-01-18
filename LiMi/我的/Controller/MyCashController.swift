//
//  MyCashController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class MyCashController: ViewController {
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var rechargeBtn: UIButton!
    @IBOutlet weak var withdrawalBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的现金"
        
        self.balance.text = "0"
        self.rechargeBtn.layer.cornerRadius = 20
        self.rechargeBtn.clipsToBounds = true
        self.withdrawalBtn.layer.cornerRadius = 20
        self.withdrawalBtn.clipsToBounds = true
        self.withdrawalBtn.layer.borderColor = APP_THEME_COLOR.cgColor
        self.withdrawalBtn.layer.borderWidth = 1
        
        let transactionRecordBtn = UIButton.init(type: .custom)
        let transactionRecordAttribute = NSAttributedString.init(string: "交易记录", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        transactionRecordBtn.setAttributedTitle(transactionRecordAttribute, for: .normal)
        transactionRecordBtn.sizeToFit()
        transactionRecordBtn.addTarget(self, action: #selector(dealToTransactionRecord), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: transactionRecordBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    @IBAction func dealRecharge(_ sender: Any) {
    }
    
    @IBAction func dealWithDrawal(_ sender: Any) {
    }
    
    @objc func dealToTransactionRecord(){
        let transactionRecordController = TransactionRecordController()
        self.navigationController?.pushViewController(transactionRecordController, animated: true)
    }
}
