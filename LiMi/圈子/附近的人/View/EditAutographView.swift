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
    @IBOutlet weak var containViewCenterYConstraint: NSLayoutConstraint!
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        self.loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: - misc
    func loadData(){
//        ShowEditContent
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let showEditContent = ShowEditContent()
        _ = moyaProvider.rx.request(.targetWith(target: showEditContent)).subscribe(onSuccess: { (response) in
            let autographModel = Mapper<AutographModel>().map(jsonData: response.data)
            HandleResultWith(model: autographModel)
            self.autograph.text = autographModel?.autograph
            SVProgressHUD.showErrorWith(model: autographModel)
        }, onError: { (error) in

            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
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

    //MARK: - keyboard
    @objc func keyboardWillShow(notification:Notification){
        let userInfo = notification.userInfo!
        let  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let deltaY = keyBoardBounds.size.height
//        let rectInWindow = self.finishedBtn.convert(finishedBtn.frame, to: UIApplication.shared.keyWindow)
        let rectInWindow = self.finishedBtn.frame
        let finishBtnDeltaY = SCREEN_HEIGHT - CGFloat(rectInWindow.origin.y + rectInWindow.size.height+49+64)
        let offset = MIN(parametersA: 0, parametersB: Double(finishBtnDeltaY-deltaY))
        let animations:(() -> Void) = {
            //键盘的偏移量
            self.containViewCenterYConstraint.constant = CGFloat(offset)
            self.layoutIfNeeded()
        }
        
        if duration > 0 {
            UIView.animate(withDuration: duration, animations: animations)
        }else{
            animations()
        }
    }
    
    @objc func keyboardWillHidden(notification:Notification){
        let userInfo  = notification.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations:(() -> Void) = {
            //键盘的偏移量
            self.containViewCenterYConstraint.constant = 0
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
}
