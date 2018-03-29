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
import AVKit

enum OperationType {
    case report
    case delete
    case defriend
    case sendMsg
    case notInteresting
    case none
}
class TrendsListController: ViewController{
    @IBOutlet weak var tableView: UITableView!
    var dataArray = [TrendModel]()
    var pageIndex:Int = 1
    var type:String?
    var collegeModel:CollegeModel?
    var academyModel:AcademyModel?
    var gradeModel:GradeModel?
    var sexModel:SexModel?
    var skillModel:SkillModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的动态"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 1000

        registerTrendsCellFor(tableView: self.tableView)
        
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }

        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
    
        NotificationCenter.default.addObserver(self, selector: #selector(dealPostATrendSuccess), name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealDidMoreOperation(notification:)), name: DID_MORE_OPERATION, object: nil)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: DID_MORE_OPERATION, object: nil)
        print("动态列表销毁")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    
   @objc func tableViewRefresh(){
        self.pageIndex = 1
        self.loadData()
    }
    
    @objc func tableViewLoadMore(){
        self.pageIndex += 1
        self.loadData()
    }
    
    func loadData(){
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        
        let trendsList = TrendsList(type: self.type, page: self.pageIndex.stringValue(), college_id: self.collegeModel?.coid?.stringValue(), school_id: self.academyModel?.scid?.stringValue(), grade_id: self.gradeModel?.id?.stringValue(), sex: self.sexModel?.id?.stringValue(), skill_id: self.skillModel?.id?.stringValue())
        _ = moyaProvider.rx.request(.targetWith(target: trendsList)).subscribe(onSuccess: { (response) in
            let trendsListModel = Mapper<TrendsListModel>().map(jsonData: response.data)
            if let trends = trendsListModel?.trends{
                for trend in trends{
                    self.dataArray.append(trend)
                }
                if trends.count > 0{self.tableView.reloadData()}
                if self.dataArray.count == 0{self.tableView.reloadData()}
            }else{self.tableView.reloadData()}
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: trendsListModel)
            if self.tableView.emptyDataSetDelegate == nil{
                self.tableView.emptyDataSetDelegate = self
                self.tableView.emptyDataSetSource = self
                 if self.dataArray.count == 0{self.tableView.reloadData()}
            }
        }, onError: { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
            if self.tableView.emptyDataSetDelegate == nil{
                self.tableView.emptyDataSetDelegate = self
                self.tableView.emptyDataSetSource = self
                 if self.dataArray.count == 0{self.tableView.reloadData()}
            }
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
        let moreOperation = MoreOperation(type: type, action_id: trendModel?.action_id,user_id:trendModel?.user_id)
        _ = moyaProvider.rx.request(.targetWith(target: moreOperation)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                var moreOperationModel = MoreOperationModel()
                moreOperationModel.operationType = operationType
                moreOperationModel.action_id = trendModel?.action_id
                moreOperationModel.user_id = trendModel?.user_id
                NotificationCenter.default.post(name: DID_MORE_OPERATION, object: nil, userInfo: [MORE_OPERATION_KEY:moreOperationModel])
            }
            Toast.showResultWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
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
    
    //成功发送了一条动态
    @objc func dealPostATrendSuccess(){
        self.tableView.mj_header.beginRefreshing()
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
}

extension TrendsListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= self.dataArray.count{return UITableViewCell()}
        let model = self.dataArray[indexPath.row]
        let trendsCell = cellFor(indexPath: indexPath, tableView: tableView, model:model)
        //完善相关block
        //点击头像
        trendsCell.trendsTopToolsContainView.tapHeadBtnBlock = {[unowned self] in
            let userDetailsController = UserDetailsController()
            userDetailsController.userId = self.dataArray[indexPath.row].user_id!
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
            if model.user_id != Defaults[.userId]{
                actions.append(actionReport)
                actions.append(actionDefriend)
                actions.append(actionSendMsg)
            }else{
                actions.append(actionDelete)
            }
            let suspensionExpandMenu = SuspensionExpandMenu.init(actions: actions)
            suspensionExpandMenu.showAround(view: btn)
//            let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            let actionReport = UIAlertAction.init(title: "举报", style: .default, handler: { _ in
//                self.dealMoreOperationWith(operationType: .report, trendModel: model)
//            })
//            let actionDefriend = UIAlertAction.init(title: "拉黑", style: .default, handler: { _ in
//                self.dealMoreOperationWith(operationType: .defriend, trendModel: model)
//            })
//            let actionSendMsg = UIAlertAction.init(title: "发消息", style: .default, handler: { _ in
//                self.dealMoreOperationWith(operationType: .sendMsg, trendModel: model)
//            })
//            let actionDelete = UIAlertAction.init(title: "删除", style: .default, handler: { _ in
//                let alertController = UIAlertController.init(title: nil, message: "删除动态后，将无法恢复此动态！", preferredStyle: .alert)
//                let actionOK = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
//                    self.dealMoreOperationWith(operationType: .delete, trendModel: model)
//                })
//                let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
//                alertController.addAction(actionOK)
//                alertController.addAction(actionCancel)
//                self.present(alertController, animated: true, completion: nil)
//            })
//            let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
//            if model.user_id != Defaults[.userId]{
//                actionController.addAction(actionReport)
//                actionController.addAction(actionDefriend)
//                actionController.addAction(actionSendMsg)
//
//            }else{
//                actionController.addAction(actionDelete)
//            }
//            actionController.addAction(actionCancel)
//            self.present(actionController, animated: true, completion: nil)
        }
        //评论
        trendsCell.trendsBottomToolsContainView.tapCommentBtnBlock = {[unowned self] in
            let commentsWithTrendController = CommentsWithTrendController()
            commentsWithTrendController.trendModel = self.dataArray[indexPath.row]
            self.navigationController?.pushViewController(commentsWithTrendController, animated: true)
        }
        //抢红包
        trendsCell.catchRedPacketBlock = {[unowned self] in
            let catchRedPacketView = GET_XIB_VIEW(nibName: "CatchRedPacketView") as! CatchRedPacketView
            catchRedPacketView.showWith(trendModel: self.dataArray[indexPath.row])
        }
        trendsCell.configWith(model: model)
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
