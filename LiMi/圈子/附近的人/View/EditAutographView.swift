//
//  EditAutographView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import SVProgressHUD

class EditAutographView: UIView {
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var autographContainView: UIView!
    @IBOutlet weak var autograph: UITextField!
    @IBOutlet weak var finishedBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containView.layer.cornerRadius = 5
        self.containView.clipsToBounds = true
        
        self.autographContainView.layer.cornerRadius = 20
        self.autographContainView.clipsToBounds = true
        self.autographContainView.layer.borderWidth = 1
        self.autographContainView.layer.borderColor = RGBA(r: 153, g: 153, b: 153, a: 1).cgColor
        
        self.finishedBtn.layer.cornerRadius = 20
        self.finishedBtn.clipsToBounds = true
    }
    
    @IBAction func dealClose(_ sender: Any) {
        self.removeFromSuperview()
    }
    @IBAction func dealFinished(_ sender: Any) {
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let updateContent = UpdateContent(content: self.autograph.text)
        _ = moyaProvider.rx.request(.targetWith(target: updateContent)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            HandleResultWith(model: baseModel)
            self.removeFromSuperview()
            SVProgressHUD.showResultWith(model: baseModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}
