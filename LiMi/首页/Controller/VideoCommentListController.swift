//
//  VideoCommentListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/6.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Moya
import SVProgressHUD
import ObjectMapper
import MJRefresh

class VideoCommentListController: ViewController {
    override var prefersStatusBarHidden: Bool{
        return true
    }
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var commentNum: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var inputBarContainView: UIView!
    @IBOutlet weak var emojiBtn: UIButton!
    //@IBOutlet weak var inputContainView: UIView!
    @IBOutlet weak var contentText: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    //@IBOutlet weak var topCoverView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var videoTrendModel:VideoTrendModel?
    var dataArray:[CommentModel] = [CommentModel]()
    var keyboard:STEmojiKeyboard?
    var pageIndex = 1
    var refreshTimeInterval:String? = String(Date().timeIntervalSince1970)
    var becommentedSubCommentModel:CommentModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        let tapTopView = UITapGestureRecognizer.init(target: self, action: #selector(dismissCommentController))
        self.topView.addGestureRecognizer(tapTopView)
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 1000
        self.tableView.estimatedSectionFooterHeight = 100
        self.tableView.estimatedSectionHeaderHeight = 100
        registerTrendsCellFor(tableView: self.tableView)
        VideoTrendCommentCellFactory.shared.registerTrendCommentCellWith(tableView: self.tableView)
        self.tableView.register(UINib.init(nibName: "EmptyCommentCell", bundle: nil), forCellReuseIdentifier: "EmptyCommentCell")
    
        
        self.contentText.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: .editingChanged)
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealDeleteCommentWith(notification:)), name: DELETE_COMMENT_SUCCESS_NOTIFICATION, object: nil)
        self.contentText.attributedPlaceholder = NSAttributedString.init(string: "说点什么...", attributes: [NSAttributedStringKey.foregroundColor:RGBA(r: 114, g: 114, b: 114, a: 15),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 15)])
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismissCommentController()
    }
    @objc func dismissCommentController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
//        UIApplication.shared.statusBarStyle = .lightContent
//        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
//        self.navigationController?.navigationBar.tintColor = UIColor.white
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        
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
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        
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
            if commentModel.video_id == self.videoTrendModel?.id{
                self.loadData()
            }
        }
    }
    
    //查看更多子评论
    @objc func dealCheckMoreSubCommentsWith(notification:Notification){
        self.tableView.reloadData()
        if let commentModel = notification.userInfo![COMMENT_MODEL_KEY] as? CommentModel{
            if let commentId = commentModel.id{
//                let commentsWithParentCommentController = CommentsWithParentCommentController()
//                commentsWithParentCommentController.parentCommentId = commentId
////                commentsWithParentCommentController.trendModel = self.videoTrendModel
//                self.navigationController?.pushViewController(commentsWithParentCommentController, animated: true)
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
                self.contentText.attributedPlaceholder = NSAttributedString.init(string: "回复：\(_name)", attributes: [NSAttributedStringKey.foregroundColor:RGBA(r: 114, g: 114, b: 114, a: 15),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 15)])
            }
            _ = self.contentText.becomeFirstResponder()
        }
    }
    //长按评论
    @objc func  dealLongpressCommentWith(notification:Notification){
        if let commentModel = notification.userInfo![COMMENT_MODEL_KEY] as? CommentModel{
            if commentModel.video_id == self.videoTrendModel?.id && commentModel.user_id == Defaults[.userId]{
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
        let videoDeleteDiscuss = VideoDeleteDiscuss.init(discuss_id: commentModel?.id)
        _ = moyaProvider.rx.request(.targetWith(target: videoDeleteDiscuss)).subscribe(onSuccess: { (response) in
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
        let videoDiscussList = VideoDiscussList.init(page: self.pageIndex, time: self.refreshTimeInterval, video_id: self.videoTrendModel?.id)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: videoDiscussList)).subscribe(onSuccess: { (response) in
            let commentListModel = Mapper<CommentListModel>().map(jsonData: response.data)
            if let timestamp = commentListModel?.timestamp{
                self.refreshTimeInterval = String(timestamp)
            }
            if let _discussNum = commentListModel?.discuss_num{
                self.commentNum.text = _discussNum + "条评论"
            }
            if let comments = commentListModel?.discuss_list{
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

        let videoDiscussAction = VideoDiscussAction.init(video_id: self.videoTrendModel?.id, content: self.contentText.text, parent_id: self.becommentedSubCommentModel?.id, parent_uid: self.becommentedSubCommentModel?.user_id)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: videoDiscussAction)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            self.pageIndex = 1
            self.loadData()
            NotificationCenter.default.post(name: COMMENT_SUCCESS_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:self.videoTrendModel])
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
        self.contentText.attributedPlaceholder = NSAttributedString.init(string: "说点什么...", attributes: [NSAttributedStringKey.foregroundColor:RGBA(r: 114, g: 114, b: 114, a: 15),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 15)])
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

}

extension VideoCommentListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.dataArray.count != 0{
            let commentModel = self.dataArray[indexPath.row]
            let trendCommentCell = VideoTrendCommentCellFactory.shared.trendCommentCellWith(indexPath: indexPath, tableView: tableView, commentModel: commentModel)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.contentText.isFirstResponder{
            self.contentText.resignFirstResponder()
        }
    }
}

