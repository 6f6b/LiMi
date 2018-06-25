//
//  CommentsWithParentCommentController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import IQKeyboardManagerSwift

class CommentsWithParentCommentController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var inputBarContainView: UIView!
    @IBOutlet weak var emojiBtn: UIButton!
    @IBOutlet weak var inputContainView: UIView!
    @IBOutlet weak var contentText: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var topCoverView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //评论所属动态
    var trendModel:TrendModel?
    
    var videoTrendModel:VideoTrendModel?
    
    //父级评论id
    var parentCommentId:Int?
    //父级评论模型，通过网络请求获取
    var parentCommentModel:CommentModel?
    var pageIndex = 1
    var dataArray = [CommentModel]()
    var refreshTimeInterval:Int? = Int(Date().timeIntervalSince1970)
    var becommentedSubCommentModel:CommentModel?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "评论回复"
        
        self.inputContainView.layer.cornerRadius = 20
        self.inputContainView.clipsToBounds = true
        self.contentText.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: .editingChanged)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 100
        self.tableView.estimatedSectionHeaderHeight = 100
        self.tableView.estimatedSectionFooterHeight = 100
        
        self.tableView.register(TrendCommentCell.self, forCellReuseIdentifier: "TrendCommentCell")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enable = true
        
        NotificationCenter.default.removeObserver(self, name: TAPED_COMMENT_PERSON_NAME_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: TAPED_COMMENT_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: LONGPRESS_COMMENT_NOTIFICATION, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealTapCommentPersonNameWith(notification:)), name: TAPED_COMMENT_PERSON_NAME_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealTapCommentWith(notification:)), name: TAPED_COMMENT_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealLongpressCommentWith(notification:)), name: LONGPRESS_COMMENT_NOTIFICATION, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("评论详情界面销毁")
    }
    
    //MARK: - misc
    
    @objc func dealDeleteCommentWith(notification:Notification){
        if let commentModel = notification.userInfo![COMMENT_MODEL_KEY] as? CommentModel{
            if commentModel.action_id == self.trendModel?.action_id{
                self.loadData()
            }
        }
    }
    
    //产看更多子评论
    @objc func dealCheckMoreSubCommentsWith(notification:Notification){
        if let commentModel = notification.userInfo![COMMENT_MODEL_KEY] as? CommentModel{
            if let commentId = commentModel.id{
                let commentsWithParentCommentController = CommentsWithParentCommentController()
                commentsWithParentCommentController.parentCommentId = commentId
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
            if commentModel.action_id != nil{
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
            if commentModel.video_id != nil{
                if commentModel.video_id == self.videoTrendModel?.id && self.videoTrendModel?.user_id == Defaults[.userId]{
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
    
    @IBAction func dealSent(_ sender: Any) {
        var body:TargetType!
        if nil == self.parentCommentModel?.topic_action_id{
            if nil == self.becommentedSubCommentModel{
                body = AddComment(action_id: self.parentCommentModel?.action_id, content: self.contentText.text, parent_id: self.parentCommentModel?.id, parent_uid: self.parentCommentModel?.user_id)
            }
            if nil != self.becommentedSubCommentModel{
                body = AddComment(action_id: self.parentCommentModel?.action_id, content: self.contentText.text, parent_id: self.becommentedSubCommentModel?.id, parent_uid: self.becommentedSubCommentModel?.user_id)
            }
        }else{
                if nil == self.becommentedSubCommentModel{
                    body = DiscussAction(topic_action_id: self.parentCommentModel?.action_id, content: self.contentText.text, parent_id: self.parentCommentModel?.id, parent_uid: self.parentCommentModel?.user_id)
                }
                if nil != self.becommentedSubCommentModel{
                    body = DiscussAction(topic_action_id: self.parentCommentModel?.action_id, content: self.contentText.text, parent_id: self.becommentedSubCommentModel?.id, parent_uid: self.becommentedSubCommentModel?.user_id)
                }
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
    
    func loadData(){
        if self.pageIndex == 1{self.dataArray.removeAll()}
        var body:TargetType!
        if self.trendModel?.topic_action_id == nil{
            body = DiscussOneFather(discuss_father_id: self.parentCommentId, page: self.pageIndex, time: self.refreshTimeInterval)
        }
        if self.trendModel?.topic_action_id != nil{
            body = TopicDiscussOneFather(discuss_father_id: self.parentCommentId, page: self.pageIndex, time: self.refreshTimeInterval)
        }
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: body)).subscribe(onSuccess: { (response) in
            let subCommentsContainModel = Mapper<SubCommentsContainModel>().map(jsonData: response.data)
            self.refreshTimeInterval = subCommentsContainModel?.timestamp == nil ? self.refreshTimeInterval : subCommentsContainModel?.timestamp
            self.parentCommentModel = subCommentsContainModel?.data
            if let childs = subCommentsContainModel?.data?.child{
                for child in childs{
                    self.dataArray.append(child)
                }
                if childs.count > 0{self.tableView.reloadData()}
            }
            if self.dataArray.count == 0{self.tableView.reloadData()}
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(model: subCommentsContainModel)
        }, onError: { (error) in
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}

extension CommentsWithParentCommentController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        return self.dataArray.count
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
            commentListHeaderView.infoLabel.text = "所有回复"
            return commentListHeaderView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trendCommentCell = tableView.dequeueReusableCell(withIdentifier: "TrendCommentCell", for: indexPath) as! TrendCommentCell
        var model:CommentModel?
        var isForSubComment = false
        if indexPath.section == 0{
            model = self.parentCommentModel
        }
        if indexPath.section == 1{
            model = self.dataArray[indexPath.row]
        }
        if model?.parent_id != self.parentCommentModel?.id{isForSubComment = true}
        trendCommentCell.configWith(model: model,isForSubComment: isForSubComment)
        return trendCommentCell
    }
}
