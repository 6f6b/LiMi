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
    var _actionId:Int?
    var _topicActionId:Int?
    @objc var actionId:Int {
        get{
            return 0
        }
        set{
            _actionId = newValue
        }
    }
    @objc var topicActionId:Int{
        get{
            return 0
        }
        set{
            _topicActionId = newValue
        }
    }
    var dataArray = [CommentModel]()
    var pageIndex = 1
    var refreshTimeInterval:Int? = Int(Date().timeIntervalSince1970)
    var becommentedSubCommentModel:CommentModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "动态详情"
        
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 1000
        self.tableView.estimatedSectionFooterHeight = 100
        self.tableView.estimatedSectionHeaderHeight = 100
        registerTrendsCellFor(tableView: self.tableView)
        TrendCommentCellFactory.shared.registerTrendCommentCellWith(tableView: self.tableView)
        self.tableView.register(UINib.init(nibName: "EmptyCommentCell", bundle: nil), forCellReuseIdentifier: "EmptyCommentCell")
        
        self.inputContainView.layer.cornerRadius = 20
        self.inputContainView.clipsToBounds = true

        self.contentText.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: .editingChanged)
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        self.loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(dealDeleteCommentWith(notification:)), name: DELETE_COMMENT_SUCCESS_NOTIFICATION, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        
        //NotificationCenter.default.removeObserver(self, name: DID_MORE_OPERATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: TAPED_COMMENT_PERSON_NAME_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: TAPED_COMMENT_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: LONGPRESS_COMMENT_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: CHECK_MORE_SUB_COMMENT_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealDidMoreOperation(notification:)), name: DID_MORE_OPERATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealTapCommentPersonNameWith(notification:)), name: TAPED_COMMENT_PERSON_NAME_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealTapCommentWith(notification:)), name: TAPED_COMMENT_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealLongpressCommentWith(notification:)), name: LONGPRESS_COMMENT_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealCheckMoreSubCommentsWith(notification:)), name: CHECK_MORE_SUB_COMMENT_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("评论界面销毁")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - misc
    
    @objc func dealDeleteCommentWith(notification:Notification){
        if let commentModel = notification.userInfo![COMMENT_MODEL_KEY] as? CommentModel{
            if commentModel.action_id == self.trendModel?.action_id{
                self.loadData()
            }
        }
    }
    
    //查看更多子评论
    @objc func dealCheckMoreSubCommentsWith(notification:Notification){
        if let commentModel = notification.userInfo![COMMENT_MODEL_KEY] as? CommentModel{
            if let commentId = commentModel.id{
                let commentsWithParentCommentController = CommentsWithParentCommentController()
                commentsWithParentCommentController.parentCommentId = commentId
                commentsWithParentCommentController.trendModel = self.trendModel
                self.navigationController?.pushViewController(commentsWithParentCommentController, animated: true)
            }
        }
    }
    
    //短点击评论人名
    @objc func dealTapCommentPersonNameWith(notification:Notification){
        if let commentModel = notification.userInfo![COMMENT_MODEL_KEY] as? CommentModel{
            if let userId = commentModel.user_id{
                let userDetailsController = UserDetailsController()
                userDetailsController.userId = userId
                self.navigationController?.pushViewController(userDetailsController, animated: true)
            }
        }
    }
    //短点击评论
    @objc func dealTapCommentWith(notification:Notification){
        if let commentModel = notification.userInfo![COMMENT_MODEL_KEY] as? CommentModel{
            self.becommentedSubCommentModel = commentModel
            if let _name = commentModel.nickname{
                self.contentText.placeholder = "回复：\(_name)"
            }
            _ = self.contentText.becomeFirstResponder()
        }
    }
    //长按评论
    @objc func  dealLongpressCommentWith(notification:Notification){
        if let commentModel = notification.userInfo![COMMENT_MODEL_KEY] as? CommentModel{
            if commentModel.action_id == self.trendModel?.action_id && self.trendModel?.user_id == Defaults[.userId]{
                let alertController = UIAlertController.init(title: "确认删除该条评论吗？", message: nil, preferredStyle: .alert)
                let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                let actionOK = UIAlertAction.init(title: "确定", style: .default, handler: {[unowned self] (_) in
                    self.deleteCommentWith(commentModel: commentModel)
                })
                alertController.addAction(actionCancel)
                alertController.addAction(actionOK)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func deleteCommentWith(commentModel:CommentModel?){
        Toast.showStatusWith(text: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        var body:TargetType!
        if self.trendModel?.topic_action_id == nil{
            body = DeleteDiscuss.init(discuss_id: commentModel?.id)
        }
        if self.trendModel?.topic_action_id != nil{
            body = TopicDeleteDiscuss.init(discuss_id: commentModel?.id)
        }
        _ = moyaProvider.rx.request(.targetWith(target: body)).subscribe(onSuccess: { (response) in
            let model = Mapper<BaseModel>().map(jsonData: response.data)
            if model?.commonInfoModel?.status == successState{
                NotificationCenter.default.post(name: DELETE_COMMENT_SUCCESS_NOTIFICATION, object: nil, userInfo: [COMMENT_MODEL_KEY:commentModel])
            }
            Toast.showErrorWith(model: model)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func loadData(){
        if pageIndex == 1{
            self.dataArray.removeAll()
        }
        //判断种类
        var body:TargetType!
        if self.trendModel == nil{
            if self._actionId != nil{
                body = CommentList(action_id: self._actionId,page:self.pageIndex,time:self.refreshTimeInterval)
            }
            if self._topicActionId != nil{
                body = DiscussList(page: self.pageIndex, topic_action_id: self._topicActionId,time:self.refreshTimeInterval)
            }
        }
        if self.trendModel != nil{
            if self.trendModel?.topic_action_id == nil{
                body = CommentList(action_id: self.trendModel?.action_id,page:self.pageIndex,time:self.refreshTimeInterval)
            }else{
                body = DiscussList(page: self.pageIndex, topic_action_id: self.trendModel?.topic_action_id,time:self.refreshTimeInterval)
            }
        }
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: body)).subscribe(onSuccess: { (response) in
            let commentListModel = Mapper<CommentListModel>().map(jsonData: response.data)
            self.refreshTimeInterval = commentListModel?.timestamp == nil ? self.refreshTimeInterval : commentListModel?.timestamp
            if nil != commentListModel?.trend{
                self.trendModel = commentListModel?.trend
            }
            if let comments = commentListModel?.comments{
                for comment in comments{
                    self.dataArray.append(comment)
                }
                if comments.count > 0{
                    self.tableView.reloadData()
                }
            }
            if self.dataArray.count == 0{self.tableView.reloadData()}
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(model: commentListModel)
        }, onError: { (error) in
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
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
        var body:TargetType!
        if nil == self.trendModel?.topic_action_id{
            body = AddComment(action_id: self.trendModel?.action_id, content: self.contentText.text, parent_id: self.becommentedSubCommentModel?.id, parent_uid: self.becommentedSubCommentModel?.user_id)
        }else{
            body = DiscussAction(topic_action_id: self.trendModel?.action_id, content: self.contentText.text, parent_id: self.becommentedSubCommentModel?.id, parent_uid: self.becommentedSubCommentModel?.user_id)
        }
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: body)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            self.pageIndex = 1
            self.loadData()
            Toast.showErrorWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
        self.contentText.text = nil
        self.sendBtn.isEnabled = false
        self.contentText.resignFirstResponder()
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
        let animations:(() -> Void) = {[unowned self] in
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
        self.becommentedSubCommentModel = nil
        self.contentText.placeholder = "写下你的评论"
        let userInfo  = notification.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations:(() -> Void) = {[unowned self] in
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
        if !AppManager.shared.checkUserStatus(){return}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        var type:String? = nil
        if operationType == .defriend{type = "black"}
        if operationType == .delete{type = "delete"}
        if operationType == .report{type = "report"}
        if operationType == .sendMsg{
            ChatWith(toUserId: trendModel?.user_id)
            return
        }
        //判断种类
        var body:TargetType!
        if self.trendModel?.topic_action_id == nil{
            body = MoreOperation(type: type, action_id: trendModel?.action_id,user_id:trendModel?.user_id)
        }else{
            body = MultiFunction(type: type, topic_action_id: trendModel?.action_id,user_id:trendModel?.user_id)
        }
        _ = moyaProvider.rx.request(.targetWith(target: body)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                var moreOperationModel = MoreOperationModel()
                moreOperationModel.operationType = operationType
                moreOperationModel.action_id = trendModel?.action_id
                moreOperationModel.user_id = trendModel?.user_id

                if self.trendModel?.topic_action_id == nil{
                    NotificationCenter.default.post(name: DID_MORE_OPERATION, object: nil, userInfo: [MORE_OPERATION_KEY:moreOperationModel])
                }else{
                    NotificationCenter.default.post(name: DID_TOPIC_MORE_OPERATION, object: nil, userInfo: [MORE_OPERATION_KEY:moreOperationModel])
                }
            }
            Toast.showResultWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
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
        if section == 1{return UITableViewAutomaticDimension}
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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
            let trendsCell = cellFor(indexPath: indexPath, tableView: tableView, model: model,trendsCellStyle: .inCommentList)
            //点击头像
            trendsCell.trendsTopToolsContainView.tapHeadBtnBlock = {[unowned self] in
                let userDetailsController = UserDetailsController()
                userDetailsController.userId = (model?.user_id)!
                self.navigationController?.pushViewController(userDetailsController, animated: true)
            }
            //点击更多
            trendsCell.trendsTopToolsContainView.tapMoreOperationBtnBlock = {[unowned self] btn in
                let actionReport = SuspensionMenuAction.init(title: "举报", action: {
                    self.dealMoreOperationWith(operationType: .report, trendModel: model)
                })
                
                let actionDefriend = SuspensionMenuAction(title: "拉黑", action: {
                    self.dealMoreOperationWith(operationType: .defriend, trendModel: model)
                })
                
                let actionSendMsg = SuspensionMenuAction(title: "发消息", action: {
                    self.dealMoreOperationWith(operationType: .sendMsg, trendModel: model)
                })
                
                let actionDelete = SuspensionMenuAction(title: "删除", action: {
                    let alertController = UIAlertController.init(title: nil, message: "删除动态后，将无法恢复此动态！", preferredStyle: .alert)
                    let actionOK = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
                        self.dealMoreOperationWith(operationType: .delete, trendModel: model)
                    })
                    let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                    alertController.addAction(actionOK)
                    alertController.addAction(actionCancel)
                    self.present(alertController, animated: true, completion: nil)
                })
                var actions = [SuspensionMenuAction]()
                if model?.user_id != Defaults[.userId]{
                    actions.append(actionReport)
                    actions.append(actionDefriend)
                    actions.append(actionSendMsg)
                }else{
                    actions.append(actionDelete)
                }
                let suspensionExpandMenu = SuspensionExpandMenu.init(actions: actions)
                suspensionExpandMenu.showAround(view: btn)
//                let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//                let actionReport = UIAlertAction.init(title: "举报", style: .default, handler: { _ in
//                    self.dealMoreOperationWith(operationType: .report, trendModel: model)
//                })
//                let actionDefriend = UIAlertAction.init(title: "拉黑", style: .default, handler: { _ in
//                    self.dealMoreOperationWith(operationType: .defriend, trendModel: model)
//                })
//                let actionSendMsg = UIAlertAction.init(title: "发消息", style: .default, handler: { _ in
//                    self.dealMoreOperationWith(operationType: .sendMsg, trendModel: model)
//                })
//                let actionDelete = UIAlertAction.init(title: "删除", style: .default, handler: { _ in
//                    let alertController = UIAlertController.init(title: nil, message: "删除动态后，将无法恢复此动态！", preferredStyle: .alert)
//                    let actionOK = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
//                        self.dealMoreOperationWith(operationType: .delete, trendModel: model)
//                    })
//                    let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
//                    alertController.addAction(actionOK)
//                    alertController.addAction(actionCancel)
//                    self.present(alertController, animated: true, completion: nil)
//                })
//                let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
//                if model?.user_id != Defaults[.userId]{
//                    actionController.addAction(actionReport)
//                    actionController.addAction(actionDefriend)
//                    actionController.addAction(actionSendMsg)
//
//                }else{
//                    actionController.addAction(actionDelete)
//                }
//                actionController.addAction(actionCancel)
//                self.present(actionController, animated: true, completion: nil)
            }
            //评论
            trendsCell.trendsBottomToolsContainView.tapCommentBtnBlock = {[unowned self] in
                self.contentText.becomeFirstResponder()
            }
            //抢红包
            trendsCell.catchRedPacketBlock = {[unowned self] in
                let catchRedPacketView = GET_XIB_VIEW(nibName: "CatchRedPacketView") as! CatchRedPacketView
                let model = self.trendModel
                catchRedPacketView.showWith(trendModel: model)
            }
            trendsCell.configWith(model: model)
            return trendsCell
        }
        if indexPath.section == 1{
            if self.dataArray.count != 0{
                let commentModel = self.dataArray[indexPath.row]
                let trendCommentCell = TrendCommentCellFactory.shared.trendCommentCellWith(indexPath: indexPath, tableView: tableView, commentModel: commentModel)
                trendCommentCell.configWith(model: commentModel)
                trendCommentCell.commentTopToolsContainView.tapHeadBtnBlock = {[unowned self] in
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.contentText.isFirstResponder{
            self.contentText.resignFirstResponder()
        }
    }
}
