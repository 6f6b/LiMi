//
//  TopicListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import ObjectMapper
import Moya
import MJRefresh
import DZNEmptyDataSet


enum TopicType {
    case newest
    case hottest
}

class TopicListController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var topicType:TopicType = .newest
    var pageIndex = 1
    var refreshTimeInterval:Int? = Int(Date().timeIntervalSince1970)
    var topicsContainModel:TopicsContainModel?
    var dataArray = [TrendModel]()
    var topicCircleId:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的订单"
        
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        registerTrendsCellFor(tableView: self.tableView)
        tableView.register(UINib.init(nibName: "TopicCircleSummaryCell", bundle: nil), forCellReuseIdentifier: "TopicCircleSummaryCell")
        tableView.register(UINib.init(nibName: "EmptyTrendsCell", bundle: nil), forCellReuseIdentifier: "EmptyTrendsCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealPostTopicSuccess), name: POST_TOPIC_SUCCESS_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealDidMoreOperation(notification:)), name: DID_TOPIC_MORE_OPERATION, object: nil)

    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: POST_TOPIC_SUCCESS_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: DID_TOPIC_MORE_OPERATION, object: nil)
        print("话题容器界面销毁")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        if self.dataArray.count == 0{
            self.loadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - misc
    @objc func dealPostTopicSuccess(){
        if self.topicType == .newest{
            self.tableView.mj_header.beginRefreshing()
        }
    }
    
    func loadData(){
        
        if self.pageIndex == 1{
            self.dataArray.removeAll()
        }
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let type = self.topicType == .hottest ? "hot" : "new"
        print(type)
        let oneTopicList = OneTopicList(page: pageIndex, topic_id: self.topicCircleId, type: type,time:self.refreshTimeInterval)
        _ = moyaProvider.rx.request(.targetWith(target: oneTopicList)).subscribe(onSuccess: { (response) in
            let topicsContainModel = Mapper<TopicsContainModel>().map(jsonData: response.data)
            self.refreshTimeInterval = topicsContainModel?.timestamp == nil ? self.refreshTimeInterval : topicsContainModel?.timestamp
            if nil == self.topicsContainModel{
                self.topicsContainModel = topicsContainModel
            }
            if let trendModels = topicsContainModel?.actionList{
                for trendModel in trendModels{
                    self.dataArray.append(trendModel)
                }
                if trendModels.count > 0 {
                    self.tableView.reloadData()
                }
            }
            if self.tableView.emptyDataSetDelegate == nil{
                self.tableView.emptyDataSetDelegate = self
                self.tableView.emptyDataSetSource = self
                if self.dataArray.count == 0{
                    self.tableView.reloadData()
                }
            }
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: topicsContainModel)
        }, onError: { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            if self.tableView.emptyDataSetDelegate == nil{
                self.tableView.emptyDataSetDelegate = self
                self.tableView.emptyDataSetSource = self
                if self.dataArray.count == 0{
                    self.tableView.reloadData()
                }
            }
            Toast.showErrorWith(msg: error.localizedDescription)
        })
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
        let multiFunction = MultiFunction(type: type, topic_action_id: trendModel?.action_id,user_id:trendModel?.user_id)
        _ = moyaProvider.rx.request(.targetWith(target: multiFunction)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                var moreOperationModel = MoreOperationModel()
                moreOperationModel.operationType = operationType
                moreOperationModel.action_id = trendModel?.action_id
                moreOperationModel.user_id = trendModel?.user_id
                NotificationCenter.default.post(name: DID_TOPIC_MORE_OPERATION, object: nil, userInfo: [MORE_OPERATION_KEY:moreOperationModel])
            }
            Toast.showResultWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @objc func dealDidMoreOperation(notification:Notification){
        if let userInfo = notification.userInfo{
            if let operationModel = userInfo[MORE_OPERATION_KEY] as? MoreOperationModel{
                //拉黑
                if operationModel.operationType == .defriend{
                    self.defriendUserWith(user_id: operationModel.user_id)
                }
                //删除
                if operationModel.operationType == .delete{
                    self.deleteTrendsWith(actionId: operationModel.action_id)
                }
            }
        }
    }
    
    /// 拉黑某个人后，删除列表中这个人的动态
    ///
    /// - Parameter trendModel: 动态model
    func defriendUserWith(user_id:Int?){
        for i in 0 ..< self.dataArray.count{
            let _trendModel = self.dataArray[i]
            
            if _trendModel.user_id == user_id{
                self.dataArray.remove(at: i)
                print("操作++++++++++")
                self.defriendUserWith(user_id:user_id )
                return
            }
        }
        self.tableView.reloadData()
    }
    
    /// 删除某条动态
    ///
    /// - Parameter trendModel: 动态model
    func deleteTrendsWith(actionId:Int?){
        for i in 0 ..< self.dataArray.count{
            let _trendModel = self.dataArray[i]
            if _trendModel.action_id == actionId{
                self.dataArray.remove(at: i)
                break
            }
        }
        self.tableView.reloadData()
    }
}

extension TopicListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.topicsContainModel == nil ? 0 : 1
        }
        return self.dataArray.count == 0 ? 1 : self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{return 7}
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("重新返回CELL")
        if indexPath.section == 0{
            print("话题简介")
            let topicCircleSummaryCell = tableView.dequeueReusableCell(withIdentifier: "TopicCircleSummaryCell", for: indexPath) as! TopicCircleSummaryCell
            topicCircleSummaryCell.configWith(model: self.topicsContainModel)
            return topicCircleSummaryCell
        }
        if indexPath.section == 1{
            if self.dataArray.count != 0{
                let trendModel = self.dataArray[indexPath.row]
                let topicCell = cellFor(indexPath: indexPath, tableView: tableView, model: trendModel, trendsCellStyle: .inTopicList)
                //完善相关block
                //点击头像
                topicCell.trendsTopToolsContainView.tapHeadBtnBlock = {[unowned self] in
                    let userDetailsController = UserDetailsController()
                    userDetailsController.userId = self.dataArray[indexPath.row].user_id!
                    self.navigationController?.pushViewController(userDetailsController, animated: true)
                }
                //点击更多
                topicCell.trendsTopToolsContainView.tapMoreOperationBtnBlock = {[unowned self] btn in
                    let actionReport = SuspensionMenuAction.init(title: "举报", action: {
                        self.dealMoreOperationWith(operationType: .report, trendModel: trendModel)
                    })
                    
                    let actionDefriend = SuspensionMenuAction(title: "拉黑", action: {
                        self.dealMoreOperationWith(operationType: .defriend, trendModel: trendModel)
                    })
                    
                    let actionSendMsg = SuspensionMenuAction(title: "发消息", action: {
                        self.dealMoreOperationWith(operationType: .sendMsg, trendModel: trendModel)
                    })
                    
                    let actionDelete = SuspensionMenuAction(title: "删除", action: {
                        let alertController = UIAlertController.init(title: nil, message: "删除动态后，将无法恢复此动态！", preferredStyle: .alert)
                        let actionOK = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
                            self.dealMoreOperationWith(operationType: .delete, trendModel: trendModel)
                        })
                        let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                        alertController.addAction(actionOK)
                        alertController.addAction(actionCancel)
                        self.present(alertController, animated: true, completion: nil)
                    })
                    var actions = [SuspensionMenuAction]()
                    if trendModel.user_id != Defaults[.userId]{
                        actions.append(actionReport)
                        actions.append(actionDefriend)
                        actions.append(actionSendMsg)
                    }else{
                        actions.append(actionDelete)
                    }
                    let suspensionExpandMenu = SuspensionExpandMenu.init(actions: actions)
                    suspensionExpandMenu.showAround(view: btn)
                }
                //评论
                topicCell.trendsBottomToolsContainView.tapCommentBtnBlock = {[unowned self] in
                    let commentsWithTrendController = CommentsWithTrendController()
                    commentsWithTrendController.trendModel = self.dataArray[indexPath.row]
                    self.navigationController?.pushViewController(commentsWithTrendController, animated: true)
                }
                topicCell.configWith(model: trendModel)
                //topicCell.configWith(model: trendModel, tableView: tableView, indexPath: indexPath)
                print("执行--------")
                return topicCell
            }else{
                let emptyTrendsCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTrendsCell", for: indexPath) as! EmptyTrendsCell
                emptyTrendsCell.configWith(info: "暂无相关信息", style: .inTopicCircleList)
                return emptyTrendsCell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension TopicListController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "qsy_img_nodt")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "暂时没有相关信息"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:RGBA(r: 153, g: 153, b: 153, a: 1)]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
}
