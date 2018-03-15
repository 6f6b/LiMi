//
//  AlterUserNameController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import ObjectMapper
import Moya

class AlterUserNameController: ViewController {
    @IBOutlet weak var userName: UITextField!
    var initialUserName:String?
    var alterUserNameBlock:((String?)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改姓名"
        let sumbitBtn = UIButton.init(type: .custom)
        let sumBitAttributeTitle = NSAttributedString.init(string: "提交", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        sumbitBtn.setAttributedTitle(sumBitAttributeTitle, for: .normal)
        sumbitBtn.sizeToFit()
        sumbitBtn.addTarget(self, action: #selector(dealSumbit), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sumbitBtn)
        
        self.userName.text = self.initialUserName
    }

    deinit {
        print("修改姓名销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - misc
    //提交
    @objc func dealSumbit(){
        Toast.showStatusWith(text: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let editUsrInfo = EditUsrInfo(field: "true_name", value: self.userName.text)
        _ = moyaProvider.rx.request(.targetWith(target: editUsrInfo)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                if let alterBlock = self.alterUserNameBlock{
                    alterBlock(self.userName.text)
                }
                self.navigationController?.popViewController(animated: true)
            }
            Toast.showResultWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }

}
