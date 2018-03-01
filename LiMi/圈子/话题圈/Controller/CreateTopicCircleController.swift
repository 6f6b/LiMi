//
//  CreateTopicCircleController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import  SVProgressHUD
import ObjectMapper
//import <#module#>

class CreateTopicCircleController: ViewController {
    @IBOutlet weak var containView: UIView!
    
    @IBOutlet weak var topicTitle: UITextField!
    
    @IBOutlet weak var placeHolder: UILabel!
    @IBOutlet weak var summary: UITextView!
    
    @IBOutlet weak var finishBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "创建话题"
        
        let cancelBtn = UIButton.init(type: .custom)
        let cancelAttributeTitle = NSAttributedString.init(string: "取消", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        cancelBtn.setAttributedTitle(cancelAttributeTitle, for: .normal)
        cancelBtn.sizeToFit()
        cancelBtn.addTarget(self, action: #selector(dealCancel), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: cancelBtn)

        self.containView.layer.cornerRadius = 5
        self.containView.clipsToBounds = true
        
        self.finishBtn.layer.cornerRadius = 20
        self.finishBtn.clipsToBounds = true

        self.summary.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //Mark: - misc
    @objc func dealCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func dealFinish(_ sender: Any) {
        
        self.topicTitle.resignFirstResponder()
        self.summary.resignFirstResponder()
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let addTopic = AddTopic(title: self.topicTitle.text, content: self.summary.text)
        _ = moyaProvider.rx.request(.targetWith(target: addTopic)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            HandleResultWith(model: resultModel)
            if resultModel?.commonInfoModel?.status == successState{
                NotificationCenter.default.post(name: ADD_TOPIC_CIRCLE_SUCCESS_NOTIFICATION, object: nil, userInfo: nil)
                //延时1秒执行
                let delayTime : TimeInterval = 1.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                    self.dismiss(animated: true, completion: {
                        SVProgressHUD.dismiss()
                    })
                }
            }
            SVProgressHUD.showResultWith(model: resultModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
}

extension CreateTopicCircleController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.placeHolder.isHidden = !IsEmpty(textView: textView)
//        if let _textChangeBlock = self.textChangeBlock{
//            _textChangeBlock(textView)
//        }
    }
}

