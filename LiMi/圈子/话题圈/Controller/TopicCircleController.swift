//
//  TopicCircleController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import MJRefresh
import Moya
import ObjectMapper
import SVProgressHUD

class TopicCircleController: ViewController {
    var tableView:UITableView!
    var dataArray = [TopicCircleModel]()
    var pageIndex = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "话题圈"
        
        self.tableView = UITableView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64), style:.plain)
        self.view.addSubview(self.tableView)
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = self
        self.tableView.dataSource = self
        TopicCircleCellFactory.registerTrendsCellFor(tableView: self.tableView)
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.pageIndex = 1
            self.loadData()
        })
        self.tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            self.pageIndex += 1
            self.loadData()
        })
        
        
        let createTopicCircleBtn = UIButton.init(type: .custom)
        let sumBitAttributeTitle = NSAttributedString.init(string: "创建", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        createTopicCircleBtn.setAttributedTitle(sumBitAttributeTitle, for: .normal)
        createTopicCircleBtn.sizeToFit()
        createTopicCircleBtn.addTarget(self, action: #selector(dealCreat), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: createTopicCircleBtn)
        
        //TopicCircleCell
        self.loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addTopicCircleSuccessed), name: ADD_TOPIC_CIRCLE_SUCCESS_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealDidMoreOperation(notification:)), name: DID_MORE_OPERATION, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ADD_TOPIC_CIRCLE_SUCCESS_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: DID_MORE_OPERATION, object: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //Mark: - misc
    @objc func dealDidMoreOperation(notification:Notification){
        if let userInfo = notification.userInfo{
            if let operationModel = userInfo[MORE_OPERATION_KEY] as? MoreOperationModel{
                //拉黑
                if operationModel.operationType == .notInteresting{
                    self.notInterestingWith(topic_id: operationModel.topic_circle_id)
                }
            }
        }
    }
    
    func notInterestingWith(topic_id:Int?){
        for i in 0 ..< self.dataArray.count{
            let _trendModel = self.dataArray[i]
            if _trendModel.id == topic_id{
                self.dataArray.remove(at: i)
                break
            }
        }
        self.tableView.reloadData()
    }
    
    @objc func addTopicCircleSuccessed(){
        self.tableView.mj_header.beginRefreshing()
    }
    
    func loadData(){
//        AllTopicList
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let allTopicList = AllTopicList(page: self.pageIndex)
        _ = moyaProvider.rx.request(.targetWith(target: allTopicList)).subscribe(onSuccess: { (response) in
            let topicCircleContainModel = Mapper<TopicCircleContainModel>().map(jsonData: response.data)
            if let _topicCircleModels = topicCircleContainModel?.data{
                for topicCircleModel in _topicCircleModels{
                    self.dataArray.append(topicCircleModel)
                }
            }
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            SVProgressHUD.showErrorWith(model: topicCircleContainModel)
        }, onError: { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @objc func dealCreat(){
        let createTopicCircleController = CreateTopicCircleController()
        let navCreatTopicCircleController = NavigationController.init(rootViewController: createTopicCircleController)
        self.present(navCreatTopicCircleController, animated: true, completion: nil)
    }
    
    /// 更多操作
    ///
    /// - Parameters:
    ///   - operationType: 操作类型如：拉黑、删除、举报、发消息
    ///   - trendModel: 动态模型
    func dealMoreOperationWith(operationType:OperationType,topicCircleModel:TopicCircleModel?){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        var type:String? = nil
        if operationType == .defriend{type = "black"}
        if operationType == .delete{type = "delete"}
        if operationType == .report{type = "report"}
        if operationType == .notInteresting{
            let unlikeTopic = UnlikeTopic(topic_id: topicCircleModel?.id)
            _ = moyaProvider.rx.request(.targetWith(target: unlikeTopic)).subscribe(onSuccess: { (response) in
                let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
                if baseModel?.commonInfoModel?.status == successState{
                    let moreOperationModel = MoreOperationModel(action_id: nil, user_id: nil, operationType: .notInteresting, topic_circle_id: topicCircleModel?.id)
                    NotificationCenter.default.post(name: DID_MORE_OPERATION, object: nil, userInfo: [MORE_OPERATION_KEY:moreOperationModel])
                }
                SVProgressHUD.showResultWith(model: baseModel)
            }, onError: { (error) in
                SVProgressHUD.showErrorWith(msg: error.localizedDescription)
            })
        }
    }

}

extension TopicCircleController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topicCircleModel = self.dataArray[indexPath.row]
        let topicCircleCell = TopicCircleCellFactory.cellFor(indexPath: indexPath, tableView: tableView, model: topicCircleModel) as! TrendsCell
        topicCircleCell.selectionStyle = .none
        topicCircleCell.trendsTopToolsContainView.tapMoreOperationBtnBlock = {
            let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let actionNotInterestion = UIAlertAction.init(title: "不感兴趣", style: .default, handler: { _ in
                self.dealMoreOperationWith(operationType: .notInteresting, topicCircleModel: topicCircleModel)
            })
            let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            actionController.addAction(actionNotInterestion)

            actionController.addAction(actionCancel)
            self.present(actionController, animated: true, completion: nil)
        }
        return topicCircleCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topicListContainController = TopicListContainController()
        topicListContainController.topicCircleModel = self.dataArray[indexPath.row]
        self.navigationController?.pushViewController(topicListContainController, animated: true)
    }
}
