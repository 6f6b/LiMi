//
//  TrendsListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import ObjectMapper
import MJRefresh
import DZNEmptyDataSet

enum OperationType {
    case report
    case delete
    case defriend
    case sendMsg
}
class TrendsListController: ViewController{
    @IBOutlet weak var tableView: UITableView!
    var dataArray = [TrendModel]()
    var pageIndex:Int = 1
    var type:String?
    var collegeId:String?
    var academyId:String?
    var gradeId:String?
    var sex:String?
    var skillId:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的动态"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.estimatedRowHeight = 100
        registerTrendsCellFor(tableView: self.tableView)
        
        self.loadData()
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.pageIndex = 1
            self.loadData()
        })
        self.tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            self.pageIndex += 1
            self.loadData()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealPostATrendSuccess), name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.dataArray.count == 0{
            self.tableView.mj_header.beginRefreshing()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    func loadData(){
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let trendsList = TrendsList(type: self.type, page: self.pageIndex.stringValue(), college_id: self.collegeId, school_id: self.academyId, grade_id: self.gradeId, sex: self.sex, skill_id: self.skillId)
        _ = moyaProvider.rx.request(.targetWith(target: trendsList)).subscribe(onSuccess: { (response) in
            let trendsListModel = Mapper<TrendsListModel>().map(jsonData: response.data)
            HandleResultWith(model: trendsListModel)
            if let trends = trendsListModel?.trends{
                for trend in trends{
                    self.dataArray.append(trend)
                }
            }
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            SVProgressHUD.showErrorWith(model: trendsListModel)
        }, onError: { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
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
         if operationType == .sendMsg{type = "sendmsg"}
        let moreOperation = MoreOperation(type: type, action_id: trendModel?.action_id,user_id:trendModel?.user_id)
        _ = moyaProvider.rx.request(.targetWith(target: moreOperation)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            HandleResultWith(model: baseModel)
            SVProgressHUD.showResultWith(model: baseModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    //成功发送了一条动态
    @objc func dealPostATrendSuccess(){
        self.tableView.mj_header.beginRefreshing()
    }
}

extension TrendsListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= self.dataArray.count{return UITableViewCell()}
        let model = self.dataArray[indexPath.row]
        let trendsCell = cellFor(indexPath: indexPath, tableView: tableView, model:model)
        //完善相关block
        //点击头像
        trendsCell.trendsTopToolsContainView.tapHeadBtnBlock = {
            let userDetailsController = UserDetailsController()
            userDetailsController.userId = self.dataArray[indexPath.row].user_id
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
                self.dealMoreOperationWith(operationType: .delete, trendModel: model)
            })
            let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            if model.user_id != Defaults[.userId]{
                actionController.addAction(actionReport)
                actionController.addAction(actionDefriend)
                actionController.addAction(actionSendMsg)
                
            }else{
                actionController.addAction(actionDelete)
            }
            actionController.addAction(actionCancel)
            self.present(actionController, animated: true, completion: nil)
        }
        //点赞
        trendsCell.trendsBottomToolsContainView.tapThumbUpBtnBlock = {(thumUpBtn) in
            let trendModel = self.dataArray[indexPath.row]
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            let thumbUp = ThumbUp(action_id: trendModel.action_id?.stringValue())
            _ = moyaProvider.rx.request(.targetWith(target: thumbUp)).subscribe(onSuccess: { (response) in
                let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
                HandleResultWith(model: resultModel)
                if resultModel?.commonInfoModel?.status == successState{
                    thumUpBtn.isSelected = !thumUpBtn.isSelected
                    if thumUpBtn.isSelected{
                        trendModel.click_num! += 1
                        trendModel.is_click = 1
                    }else{
                        trendModel.is_click = 0
                        trendModel.click_num! -= 1
                    }
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
                SVProgressHUD.showErrorWith(model: resultModel)
            }, onError: { (error) in
                SVProgressHUD.showErrorWith(msg: error.localizedDescription)
            })
        }
        //评论
        trendsCell.trendsBottomToolsContainView.tapCommentBtnBlock = {
            let commentsWithTrendController = CommentsWithTrendController()
            commentsWithTrendController.trendModel = self.dataArray[indexPath.row]
            self.navigationController?.pushViewController(commentsWithTrendController, animated: true)
        }
        //抢红包
        trendsCell.catchRedPacketBlock = {
            let catchRedPacketView = GET_XIB_VIEW(nibName: "CatchRedPacketView") as! CatchRedPacketView
            catchRedPacketView.closeBlock = {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            catchRedPacketView.showWith(trendModel: self.dataArray[indexPath.row])
        }
        return trendsCell
    }
}

extension TrendsListController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "qsy_img_nosx")
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
