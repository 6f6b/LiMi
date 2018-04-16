//
//  AlterUserSexController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/16.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import ObjectMapper
import Moya

class AlterUserSexController: ViewController {
    @IBOutlet weak var girlPreImg: UIImageView!
    @IBOutlet weak var boyPreImg: UIImageView!
    var alterUserSexBlock:((String?)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改性别"
        let sumbitBtn = UIButton.init(type: .custom)
        let sumBitAttributeTitle = NSAttributedString.init(string: "提交", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:APP_THEME_COLOR])
        sumbitBtn.setAttributedTitle(sumBitAttributeTitle, for: .normal)
        sumbitBtn.sizeToFit()
        sumbitBtn.addTarget(self, action: #selector(dealSumbit), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sumbitBtn)
    }

    deinit {
        print("修改性别销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - misc
    //选择男性
    @IBAction func dealSelectBoy(_ sender: Any) {
        self.boyPreImg.isHidden = false
        self.girlPreImg.isHidden = true
    }
    
    //选择女性
    @IBAction func dealSelectGirl(_ sender: Any) {
        self.boyPreImg.isHidden = true
        self.girlPreImg.isHidden = false
    }
    
    //提交
    @objc func dealSumbit(){
        return
        //判断是否选择了性别
        if self.boyPreImg.isHidden == true && self.girlPreImg.isHidden == true{
            Toast.showErrorWith(msg: "请选择性别")
            return
        }
        Toast.showStatusWith(text: nil)
        var sex = "0"
        if !self.boyPreImg.isHidden{
            sex = "1"
        }
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let editUsrInfo = EditUsrInfo.init(nickname: nil, signature: nil, sex: nil)
        _ = moyaProvider.rx.request(.targetWith(target: editUsrInfo)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                if let alterBlock = self.alterUserSexBlock{
                    var sex = "女"
                    if !self.boyPreImg.isHidden{
                        sex = "男"
                    }
                    alterBlock(sex)
                }
            }
            self.navigationController?.popViewController(animated: true)
            Toast.showResultWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}
