//
//  CommentsWithTrendController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/20.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import AGEmojiKeyboard

class CommentsWithTrendController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var inputBarContainView: UIView!
    @IBOutlet weak var emojiBtn: UIButton!
    @IBOutlet weak var inputContainView: UIView!
    @IBOutlet weak var contentText: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var topCoverView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var keyboard:STEmojiKeyboard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "评论"
        
        let backBtn = UIButton.init(type: .custom)
        backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        backBtn.sizeToFit()
        backBtn.addTarget(self, action: #selector(dealBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 100
        self.tableView.register(TrendsWithTextCell.self, forCellReuseIdentifier: "TrendsWithTextCell")
        self.tableView.register(TrendCommentCell.self, forCellReuseIdentifier: "TrendCommentCell")
        
        self.inputContainView.layer.cornerRadius = 20
        self.inputContainView.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)

        self.contentText.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: .editingChanged)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - misc
    @objc func dealBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dealTapEmoji(_ sender: Any) {
        emojiBtn.isSelected = !emojiBtn.isSelected
        if emojiBtn.isSelected{
            if self.keyboard == nil{
                self.keyboard = STEmojiKeyboard()
            }
            self.keyboard?.textView = self.contentText
        }else{
            self.contentText.inputView = nil
        }
        self.contentText.reloadInputViews()
        self.contentText.becomeFirstResponder()
    }
    
    @IBAction func dealSent(_ sender: Any) {
        print(self.contentText.text)
        self.contentText.text = nil
        self.sendBtn.isEnabled = false
    }
    
    @objc func textFieldValueChanged(textField:UITextField!){
        self.sendBtn.isEnabled = !IsEmpty(textField: textField)
    }
    
    @objc func keyboardWillShow(notification:Notification){
        self.topCoverView.isHidden = false
        let userInfo = notification.userInfo!
        let  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let deltaY = keyBoardBounds.size.height
        let animations:(() -> Void) = {
            //键盘的偏移量
            self.bottomConstraint.constant = deltaY
            self.view.layoutIfNeeded()
        }
        
        if duration > 0 {
            UIView.animate(withDuration: duration, animations: animations)
        }else{
            animations()
        }
    }
    
    @objc func keyboardWillHidden(notification:Notification){
        self.topCoverView.isHidden = true
        let userInfo  = notification.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations:(() -> Void) = {
            //键盘的偏移量
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
}

extension CommentsWithTrendController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        else{return 10}
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{return 0.001}
        return 47
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{return 7}
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let commentListHeaderView = CommentListHeaderView()
            return commentListHeaderView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let trendsWithTextCell = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextCell", for: indexPath)
            return trendsWithTextCell
        }
        if indexPath.section == 1{
            let trendCommentCell = tableView.dequeueReusableCell(withIdentifier: "TrendCommentCell", for: indexPath)
            return trendCommentCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
