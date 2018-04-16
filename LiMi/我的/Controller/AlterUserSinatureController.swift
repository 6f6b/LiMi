//
//  AlterUserSinatureController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import ObjectMapper
import Moya

class AlterUserSinatureController: ViewController {
    @IBOutlet weak var signature: UITextField!
    var initialUserSinatrue:String?
    var alterSinatureBlock:((String?)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改个性签名"
        
        let sumbitBtn = UIButton.init(type: .custom)
        let sumBitAttributeTitle = NSAttributedString.init(string: "保存", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:APP_THEME_COLOR])
        sumbitBtn.setAttributedTitle(sumBitAttributeTitle, for: .normal)
        sumbitBtn.sizeToFit()
        sumbitBtn.addTarget(self, action: #selector(dealSumbit), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sumbitBtn)
        
        self.signature.text = self.initialUserSinatrue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - misc
    //提交
    @objc func dealSumbit(){
        Toast.showStatusWith(text: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let editUserInfo = EditUsrInfo(nickname: nil, signature: self.signature.text,sex:nil)
        _ = moyaProvider.rx.request(.targetWith(target: editUserInfo)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                if let alterBlock = self.alterSinatureBlock{
                    alterBlock(self.signature.text)
                }
                self.navigationController?.popViewController(animated: true)
            }
            Toast.showResultWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }

}
