
//
//  AliyunChooseClassTypeController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/15.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

@objc protocol AliyunChooseClassTypeControllerDelegate : class {
    func aliyunChooseClassTypeController(controller:AliyunChooseClassTypeController,classType:Int)
}

class AliyunChooseClassTypeController: UIViewController {
    @IBOutlet weak var inclassContainView: UIView!
    @IBOutlet weak var outClassContainView: UIView!
    @objc weak var delegate:AliyunChooseClassTypeControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        //上课为1 下课为0
        self.inclassContainView.tag = 101
        self.outClassContainView.tag = 100
        
        let tapInclass = UITapGestureRecognizer.init(target: self, action: #selector(dealTapContainViewWith(tap:)))
        let tapOutclass = UITapGestureRecognizer.init(target: self, action: #selector(dealTapContainViewWith(tap:)))
        self.inclassContainView.addGestureRecognizer(tapInclass)
        self.outClassContainView.addGestureRecognizer(tapOutclass)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func dealTapContainViewWith(tap:UITapGestureRecognizer){
        let type = (tap.view?.tag)!-100
        self.delegate.aliyunChooseClassTypeController(controller: self, classType: type)
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}
