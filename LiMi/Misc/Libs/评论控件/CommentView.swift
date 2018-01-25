//
//  CommentView.swift
//  YONews
//
//  Created by dev.liufeng on 2017/2/7.
//  Copyright © 2017年 YONEWS. All rights reserved.
//

import UIKit
import SVProgressHUD

class CommentView: UIView {
    @IBOutlet weak var topView: UIVisualEffectView!
    
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentContainView: UIView!
    @IBOutlet weak var textFieldContainView: UIView!
    @IBOutlet weak var commentTextfield: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    
    let screentWidth = UIScreen.main.bounds.size.width
    let screentHeight = UIScreen.main.bounds.size.height
    var publishBlock:((String)->Void)?
    override func awakeFromNib() {
        self.frame = CGRect(x: 0, y: 0, width: screentWidth, height: screentHeight)
        self.constraint.constant = -GET_DISTANCE(ratio: 290/640)
        self.textFieldContainView.layer.borderColor = UIColor.gray.cgColor
        self.textFieldContainView.layer.cornerRadius = 3
        
        self.layoutIfNeeded()
        
        let tapG = UITapGestureRecognizer(target: self, action: #selector(dealTapTopView))
//        let blur = UIBlurEffect(style: .light)
//        topView.alpha = 0.95
//        topView.effect = blur
        self.topView.addGestureRecognizer(tapG)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func dealTapTopView(){
        self.commentTextfield.resignFirstResponder()
    }
    
    //弹出键盘
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.commentTextfield.becomeFirstResponder()
    }
    
    //隐藏键盘，执行block
    @IBAction func dealPublish(_ sender: Any) {
        self.commentTextfield.resignFirstResponder()
//        if let newsModel = self.newsModel{
//            let newsCode = newsModel.newsCode!
//            if IsEmpty(textView: self.commentTextfield){
//                SVProgressHUD.showInfo(withStatus: "内容不能为空")
//            }
//            let content = self.commentTextfield.text
//            let commentApi = YOToCommentAPI(newsCode: newsCode, content: content!, imei: IMEI!, longitude: "", latitude: "", address: "", files: "")
//            commentApi.responseJSON(completionHandler: { (result) in
//                if let publishBlock = self.publishBlock{
//                    publishBlock("")
//                }
//            })
//        }
    }
    
    //键盘的出现
    @objc func keyBoardWillShow(_ notification: Notification){
        //获取userInfo
        let kbInfo = notification.userInfo
        //获取键盘的size
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //键盘的y偏移量
        let changeY = SCREEN_HEIGHT - kbRect.origin.y
        //键盘弹出的时间
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        //界面偏移动画
        UIView.animate(withDuration: duration, animations: {
            self.constraint.constant = changeY
            self.topView.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.3)
            self.layoutIfNeeded()
        }) { (_) in
        }
    }
    
    //键盘的隐藏
    @objc func keyBoardWillHide(_ notification: Notification){
        
        let kbInfo = notification.userInfo
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            self.constraint.constant = -GET_DISTANCE(ratio: 290/640)
            self.topView.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0)
            self.layoutIfNeeded()
            
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    deinit {
            print("销毁")
    }
}
