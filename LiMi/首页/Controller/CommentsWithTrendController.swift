//
//  CommentsWithTrendController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/20.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Moya
import SVProgressHUD
import ObjectMapper
import MJRefresh

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
    var trendModel:TrendModel?
    var dataArray = [CommentModel]()
    var pageIndex = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "评论"
        
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 100
        registerTrendsCellFor(tableView: self.tableView)
        self.tableView.register(TrendCommentCell.self, forCellReuseIdentifier: "TrendCommentCell")
        self.tableView.register(UINib.init(nibName: "EmptyCommentCell", bundle: nil), forCellReuseIdentifier: "EmptyCommentCell")
        
        self.inputContainView.layer.cornerRadius = 20
        self.inputContainView.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)

        self.contentText.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: .editingChanged)
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.pageIndex = 1
            self.loadData()
        })
        self.tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            self.pageIndex += 1
            self.loadData()
        })
        self.loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(dealDidMoreOperation(notification:)), name: DID_MORE_OPERATION, object: nil)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: DID_MORE_OPERATION, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - misc
    func loadData(){
        if pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let commentList = CommentList(action_id: self.trendModel?.action_id?.stringValue(),page:self.pageIndex)
        _ = moyaProvider.rx.request(.targetWith(target: commentList)).subscribe(onSuccess: { (response) in
            let commentListModel = Mapper<CommentListModel>().map(jsonData: response.data)
            HandleResultWith(model: commentListModel)
            self.trendModel = commentListModel?.trend
            if let comments = commentListModel?.comments{
                for comment in comments{
                    self.dataArray.append(comment)
                }
            }
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            SVProgressHUD.showErrorWith(model: commentListModel)
        }, onError: { (error) in
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
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
        self.contentText.resignFirstResponder()
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let addComment = AddComment(action_id: self.trendModel?.action_id?.stringValue(), content: self.contentText.text)
        _ = moyaProvider.rx.request(.targetWith(target: addComment)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            HandleResultWith(model: resultModel)
            self.pageIndex = 1
            self.loadData()
            SVProgressHUD.showErrorWith(model: resultModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
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
    
    /// 更多操作
    ///
    /// - Parameters:
    ///   - operationType: 操作类型如：拉黑、删除、举报、发消息
    ///   - trendModel: 动态模型
    func dealMoreOperationWith(operationType:OperationType,trendModel:TrendModel?){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        var type:String? = nil
        if operationType == .defriend{type = "black"}
        if operationType == .delete{type = "delete"}
        if operationType == .report{type = "report"}
        if operationType == .sendMsg{
            let session = NIMSession.init(trendModel!.user_id!.stringValue(), type: .P2P)
            let sessionVC = NTESSessionViewController.init(session: session)
            self.navigationController?.pushViewController(sessionVC!, animated: true)
            return
        }
        let moreOperation = MoreOperation(type: type, action_id: trendModel?.action_id,user_id:trendModel?.user_id)
        _ = moyaProvider.rx.request(.targetWith(target: moreOperation)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            HandleResultWith(model: baseModel)
            if baseModel?.commonInfoModel?.status == successState{
                let moreOperationModel = MoreOperationModel(action_id: trendModel?.action_id, user_id: trendModel?.user_id, operationType: operationType)
                NotificationCenter.default.post(name: DID_MORE_OPERATION, object: nil, userInfo: [MORE_OPERATION_KEY:moreOperationModel])
            }
            SVProgressHUD.showResultWith(model: baseModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    
    /// 处理操作结果
    ///
    /// - Parameter notification: 通知对象
    @objc func dealDidMoreOperation(notification:Notification){
        if let userInfo = notification.userInfo{
            if let operationModel = userInfo[MORE_OPERATION_KEY] as? MoreOperationModel{
                //拉黑
                if operationModel.operationType == .defriend{
                }
                //删除
                if operationModel.operationType == .delete{
                    self.navigationController?.popViewController(animated: true)
                }
                if operationModel.operationType == .sendMsg{
                    
                }
            }
        }
    }
}

extension CommentsWithTrendController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        if section == 1{
            if self.dataArray.count != 0{return self.dataArray.count}
            if self.dataArray.count == 0{return 1}
        }
        return 0
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0{
            let footerView = UIView()
            footerView.backgroundColor = UIColor.groupTableViewBackground
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let model = self.trendModel
            let trendsCell = cellFor(indexPath: indexPath, tableView: tableView, model: model,trendsCellStyle: .normal)
            //点击头像
            trendsCell.trendsTopToolsContainView.tapHeadBtnBlock = {
                let userDetailsController = UserDetailsController()
                userDetailsController.userId = (model?.user_id)!
                self.navigationController?.pushViewController(userDetailsController, animated: true)
            }
            //点击更多
            trendsCell.trendsTopToolsContainView.tapMoreOperationBtnBlock = {
                let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let actionReport = UIAlertAction.init(title: "举报", style: .default, handler: { _ in
                    self.dealMoreOperationWith(operationType: .report, trendModel: model)
                })
                let actionDefriend = UIAlertAction.init(title: "拉黑", style: .default, handler: { _ in
                    self.dealMoreOperationWith(operationType: .defriend, trendModel: model)
                })
                let actionSendMsg = UIAlertAction.init(title: "发消息", style: .default, handler: { _ in
                    self.dealMoreOperationWith(operationType: .sendMsg, trendModel: model)
                })
                let actionDelete = UIAlertAction.init(title: "删除", style: .default, handler: { _ in
                    let alertController = UIAlertController.init(title: nil, message: "删除动态后，将无法恢复此动态！", preferredStyle: .alert)
                    let actionOK = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
                        self.dealMoreOperationWith(operationType: .delete, trendModel: model)
                    })
                    let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                    alertController.addAction(actionOK)
                    alertController.addAction(actionCancel)
                    self.present(alertController, animated: true, completion: nil)
                })
                let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                if model?.user_id != Defaults[.userId]{
                    actionController.addAction(actionReport)
                    actionController.addAction(actionDefriend)
                    actionController.addAction(actionSendMsg)
                    
                }else{
                    actionController.addAction(actionDelete)
                }
                actionController.addAction(actionCancel)
                self.present(actionController, animated: true, completion: nil)
            }
            //评论
            trendsCell.trendsBottomToolsContainView.tapCommentBtnBlock = {
                self.contentText.becomeFirstResponder()
            }
            //抢红包
            trendsCell.catchRedPacketBlock = {
                let catchRedPacketView = GET_XIB_VIEW(nibName: "CatchRedPacketView") as! CatchRedPacketView
                let model = self.trendModel
                catchRedPacketView.showWith(trendModel: model)
            }
            return trendsCell
        }
        if indexPath.section == 1{
            if self.dataArray.count != 0{
                let commentModel = self.dataArray[indexPath.row]
                let trendCommentCell = tableView.dequeueReusableCell(withIdentifier: "TrendCommentCell", for: indexPath) as! TrendCommentCell
                trendCommentCell.configWith(model: commentModel)
                trendCommentCell.commentTopToolsContainView.tapHeadBtnBlock = {
                    let userDetailsController = UserDetailsController()
                    userDetailsController.userId = commentModel.user_id!
                    self.navigationController?.pushViewController(userDetailsController, animated: true)
                }
                return trendCommentCell
            }else{
                let emptyCommentCell = tableView.dequeueReusableCell(withIdentifier: "EmptyCommentCell", for: indexPath)
                return emptyCommentCell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
    }
}
