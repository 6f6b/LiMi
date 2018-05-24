//
//  UserDetailsController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import MJRefresh
import Moya
import SVProgressHUD
import ObjectMapper

class UserDetailsController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolsContainView: UIView!
    @IBOutlet weak var liaoBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var toolContainViewBottomConstraint: NSLayoutConstraint!
    
    var userDetailHeadView:UserDetailHeadView?
    var userDetailSelectTrendsTypeCell:UserDetailSelectTrendsTypeCell?
    var userInfoModel:UserInfoModel?
    var type = "action"
    var skillPage = 1
    var actionPage = 1
    var refreshTimeInterval:Int? = Int(Date().timeIntervalSince1970)
    var skillDataArray = [TrendModel]()
    var actionDataArray = [TrendModel]()
    @objc var userId:Int = 0
    var emptyInfo = "太低调了，还没有发动态"
    var isSpread:Bool = false
    var schoolInfoCell = UserDetailSingleInfoCell()
    var academyInfoCell = UserDetailSingleInfoCell()
    var gradeInfoCell = UserDetailSingleInfoCell()
    var trueNameInfoCell = UserDetailSingleInfoWithQuestionCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if SYSTEM_VERSION <= 11.0{
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }else{
            self.tableView.contentInset = UIEdgeInsets.init(top: -64, left: 0, bottom: 0, right: 0)
        }
        self.tableView.estimatedRowHeight = 1000
        self.tableView.estimatedSectionFooterHeight = 100
        self.tableView.estimatedSectionHeaderHeight = 100
        registerTrendsCellFor(tableView: self.tableView)
        self.tableView.register(UINib.init(nibName: "EmptyTrendsCell", bundle: nil), forCellReuseIdentifier: "EmptyTrendsCell")

        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            if self.type == "skill"{self.skillPage += 1}
            if self.type == "action"{self.actionPage += 1}
            self.loadData()
        }
        
        if self.userId != Defaults[.userId]{
            let moreBtn = UIButton.init(type: .custom)
            moreBtn.setImage(UIImage.init(named: "xq_nav_more"), for: .normal)
            moreBtn.sizeToFit()
            moreBtn.addTarget(self, action: #selector(dealMoreOperation(_:)), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: moreBtn)
        }
        
        loadData()
        //添加IM登录代理
        NIMSDK.shared().loginManager.add(self)
    }

    deinit {
        NIMSDK.shared().loginManager.remove(self)
        print("详情界面销毁")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //替换ViewController的导航栏返回按钮
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "xq_nav_back"), for: .normal)
        }
        if self.userId == Defaults[.userId]{self.toolContainViewBottomConstraint.constant = 50}
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    func refreshToolContainViewWith(model:UserInfoModel?){
        if model?.is_attention == 0{
            self.followBtn.setTitle("关注", for: .normal)
            self.followBtn.setImage(UIImage.init(named: "xq_ic_guanzhu"), for: .normal)
        }
        if model?.is_attention == 1{
            self.followBtn.setTitle("已关注", for: .normal)
            self.followBtn.setImage(UIImage.init(named: "xq_ic_ygz"), for: .normal)
        }
        if model?.is_attention == 2{
            self.followBtn.setTitle("互相关注", for: .normal)
            self.followBtn.setImage(UIImage.init(named: "xq_ic_hxgz"), for: .normal)
        }
        
    }
    
    //改变关注关系
    @IBAction func dealChangeRelationship(_ sender: Any) {
        if !AppManager.shared.checkUserStatus(){return}
        if self.userInfoModel?.is_attention == 0{
            self.changeRelationship()
        }else{
            let popViewForChooseToUnFollow = PopViewForChooseToUnFollow.init(frame: SCREEN_RECT)
            popViewForChooseToUnFollow.tapRightBlock = {[unowned self] () in
                self.changeRelationship()
            }
            popViewForChooseToUnFollow.show()
        }
        
    }
    
    func changeRelationship(){
        Toast.showStatusWith(text: nil)
        if let userId = self.userInfoModel?.user_id{
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            let addAttention = AddAttention.init(attention_id: userId)
            _ = moyaProvider.rx.request(.targetWith(target: addAttention)).subscribe(onSuccess: {[unowned self] (response) in
                let personCenterModel = Mapper<PersonCenterModel>().map(jsonData: response.data)
                self.userInfoModel?.is_attention = personCenterModel?.user_info?.is_attention
                if personCenterModel?.commonInfoModel?.status == successState{
                    self.refreshToolContainViewWith(model: personCenterModel?.user_info)
                }
                Toast.showErrorWith(model: personCenterModel)
                }, onError: { (error) in
                    Toast.showErrorWith(msg: error.localizedDescription)
            })
        }
    }
    /// 更多操作
    ///
    /// - Parameters:
    ///   - operationType: 操作类型如：拉黑、删除、举报、发消息
    ///   - trendModel: 动态模型
    func dealMoreOperationWith(operationType:OperationType){
        if !AppManager.shared.checkUserStatus(){return}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        var type:String? = nil
        if operationType == .defriend{type = "black"}
        if operationType == .delete{type = "delete"}
        if operationType == .report{type = "report"}
        if operationType == .sendMsg{
            ChatWith(toUserId: self.userId, navigationController: self.navigationController)
            return
        }
        let moreOperation = MoreOperation(type: type, action_id: nil, user_id: self.userId)
        _ = moyaProvider.rx.request(.targetWith(target: moreOperation)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            Toast.showResultWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @objc func dealMoreOperation(_ sender: Any) {
        let actionReport = SuspensionMenuAction.init(title: "举报", action: {
            self.dealMoreOperationWith(operationType: .report)
        })
        
        let actionDefriend = SuspensionMenuAction(title: "拉黑", action: {
            self.dealMoreOperationWith(operationType: .defriend)
        })
        
        let actionSendMsg = SuspensionMenuAction(title: "发消息", action: {
            self.dealMoreOperationWith(operationType: .sendMsg)
        })

        let actions = [actionReport,actionDefriend,actionSendMsg]
        let suspensionExpandMenu = SuspensionExpandMenu.init(actions: actions)
        suspensionExpandMenu.showAround(view: self.navigationItem.rightBarButtonItem?.customView)
    }
    
    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let pageIndex = self.type == "action" ? self.actionPage : self.skillPage
        let userDetails = UserDetails(page: pageIndex, user_id: self.userId, type: self.type,time:self.refreshTimeInterval)
        _ = moyaProvider.rx.request(.targetWith(target: userDetails)).subscribe(onSuccess: {[unowned self] (response) in
            let userDetailModel = Mapper<UserDetailModel>().map(jsonData: response.data)
            self.refreshTimeInterval = userDetailModel?.timestamp == nil ? self.refreshTimeInterval : userDetailModel?.timestamp
            self.userInfoModel = userDetailModel?.user
            //self.tableView.reloadData()
            self.userDetailHeadView?.configWith(model: self.userInfoModel)
            self.refreshToolContainViewWith(model: userDetailModel?.user)
            Toast.showErrorWith(model: userDetailModel)
            self.tableView.mj_footer.endRefreshing()

            if let trends = userDetailModel?.action_list{
                if self.type == "action"{
                    if self.actionPage == 1{self.actionDataArray.removeAll()}
                    for trend in trends{
                        self.actionDataArray.append(trend)
                    }
                }
                if self.type == "skill"{
                    if self.skillPage == 1{self.skillDataArray.removeAll()}
                    for trend in trends{
                        self.skillDataArray.append(trend)
                    }
                }
                if self.type == "action" && self.actionPage > 1 && trends.count == 0{return}
                if self.type == "skill" && self.skillPage > 1 && trends.count == 0{return}
                self.tableView.reloadData()
            }
        }, onError: { (error) in
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @IBAction func dealLiao(_ sender: Any) {
        if !AppManager.shared.checkUserStatus(){return}
        //判断登录状态
        let appState = AppManager.shared.appState()
        if appState == .imOnlineBusinessOnline || appState == .imOfflineBusinessOnline{
            ChatWith(toUserId: self.userId, navigationController: self.navigationController)
        }
        if appState == .imOnlineBusinessOffline{
            NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil, userInfo: [LOG_OUT_MESSAGE_KEY:"请先登录APP"])
        }
        if appState == .imOffLineBusinessOffline{
            NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil, userInfo: [LOG_OUT_MESSAGE_KEY:"请先登录APP"])
        }
    }
    
}

extension UserDetailsController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.userInfoModel == nil{return 0}
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 0}
        if section == 1{
            if self.isSpread{return 4}
            if !self.isSpread{return 2}
        }
        if section == 2{
            let dataArray = self.type == "action" ? self.actionDataArray :self.skillDataArray
            if dataArray.count == 0{return 1}
            return dataArray.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{}
        if indexPath.section == 1{return UITableViewAutomaticDimension}
        if indexPath.section == 2{return UITableViewAutomaticDimension}
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{return UITableViewAutomaticDimension}
        if section == 1{return UITableViewAutomaticDimension}
        if section == 2{return UITableViewAutomaticDimension}
        return 0.001
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            if let _ = self.userDetailHeadView{}else{
                self.userDetailHeadView = GET_XIB_VIEW(nibName: "UserDetailHeadView") as? UserDetailHeadView
                self.userDetailHeadView?.backImageView?.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 230)
            }
            self.userDetailHeadView?.configWith(model: self.userInfoModel)
            return userDetailHeadView
        }
        if section == 1{
            let userDetailChooseHiddenOrNotView = UserDetailChooseHiddenOrNotView.init(isSpread: self.isSpread)
            userDetailChooseHiddenOrNotView.tapBtnBlock = {[unowned self] (button) in
                self.isSpread = !button.isSelected
                self.tableView.reloadData()
            }
            return userDetailChooseHiddenOrNotView
        }
        if section == 2{
            var userDetailSelectTrendsTypeView:UserDetailSelectTrendsTypeView!
            if self.type == "action"{
                 userDetailSelectTrendsTypeView = UserDetailSelectTrendsTypeView(initialIndex: 0)
            }else{
                userDetailSelectTrendsTypeView = UserDetailSelectTrendsTypeView(initialIndex: 1)
            }
            userDetailSelectTrendsTypeView.tapBlock = {[unowned self] (index) in
                if self.type == "action" && index == 0{return}
                if self.type == "skill" && index == 1{return}
                self.type = index == 0 ? "action" : "skill"
                self.emptyInfo = index == 0 ?  "太低调了，还没发动态" : "太低调了，还没发需求"
                self.loadData()
                self.tableView.reloadData()
            }
            return userDetailSelectTrendsTypeView
        }
        return nil
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{return UITableViewCell()}
        if indexPath.section == 1{
            if indexPath.row == 0{
                var info = "学校  "
                if let _college = self.userInfoModel?.college{
                    info.append(_college)
                }
                self.schoolInfoCell.infoLabel.text = info
                return self.schoolInfoCell
            }
            if indexPath.row == 1{
                var info = "学院  "
                if let academy = self.userInfoModel?.school{
                    info.append(academy)
                }
                self.academyInfoCell.infoLabel.text = info
                return self.academyInfoCell
            }
            if indexPath.row == 2{
                var info = "年级  "
                if let grade = self.userInfoModel?.grade{
                    info.append(grade)
                }
                self.gradeInfoCell.infoLabel.text = info
                return self.gradeInfoCell
            }
            if indexPath.row == 3{
                var info = "姓名  "
                if let name = self.userInfoModel?.true_name{
                    info.append(name)
                    self.trueNameInfoCell.questionBtn.isHidden = true
                }else{
                    info.append("无法透露")
                    self.trueNameInfoCell.questionBtn.isHidden = false
                }
                self.trueNameInfoCell.infoLabel.text = info
                return self.trueNameInfoCell
            }
        }
        if indexPath.section == 2{
            var dataArray = self.type == "action" ? self.actionDataArray : self.skillDataArray
            if dataArray.count != 0{
                if indexPath.row >= dataArray.count{
                    return UITableViewCell()
                }
                let model = dataArray[indexPath.row]
                let trendsCell = cellFor(indexPath: indexPath, tableView: tableView, model: model, trendsCellStyle: .inPersonCenter)
                //评论
                trendsCell.trendsBottomToolsContainView.tapCommentBtnBlock = {[unowned self] in
                    let commentsWithTrendController = CommentsWithTrendController()
                    commentsWithTrendController.trendModel = model
                    self.navigationController?.pushViewController(commentsWithTrendController, animated: true)
                }
                //抢红包
                trendsCell.catchRedPacketBlock = {[unowned self] in
                    let catchRedPacketView = GET_XIB_VIEW(nibName: "CatchRedPacketView") as! CatchRedPacketView
                    catchRedPacketView.showWith(trendModel: model)
                }
                trendsCell.configWith(model: model)
                return trendsCell
            }
            if dataArray.count == 0{
                let emptyTrendsCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTrendsCell", for: indexPath) as! EmptyTrendsCell
                emptyTrendsCell.configWith(info: self.emptyInfo, style: .inPersonCenter)
                return emptyTrendsCell
            }
        }
        return UITableViewCell()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y > 230{
//            //导航栏颜色
//            self.navigationController?.navigationBar.backgroundColor = UIColor.white
//            //返回按钮颜色
//            let backBtn = self.navigationItem.leftBarButtonItem?.customView as! UIButton
//            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
//            //title
//            self.title = "个人中心"
//            //更多
//            let moreBtn = self.navigationItem.rightBarButtonItem?.customView as! UIButton
//            moreBtn.setImage(UIImage.init(named: "btn_jubao"), for: .normal)
//        }else{
//            //导航栏颜色
//            self.navigationController?.navigationBar.backgroundColor = UIColor.clear
//            //返回按钮颜色
//            let backBtn = self.navigationItem.leftBarButtonItem?.customView as! UIButton
//            backBtn.setImage(UIImage.init(named: "nav_back"), for: .normal)
//            //title
//            self.title = nil
//            //更多
//            
//            if let moreBtn = self.navigationItem.rightBarButtonItem?.customView as? UIButton{
//                moreBtn.setImage(UIImage.init(named: "nav_btn_jubao"), for: .normal)
//            }
//        }
        return
        let offsetY = -scrollView.contentOffset.y
        if offsetY > 0{
            let tmpX = -(SCREEN_WIDTH/230)*(offsetY*0.5)
            let tmpY = -offsetY
            let tmpW = SCREEN_WIDTH+(SCREEN_WIDTH/230)*offsetY
            let tmpH = 230 + offsetY
            self.userDetailHeadView?.backImageView?.frame = CGRect.init(x: tmpX, y: tmpY, width: tmpW, height: tmpH)
        }else{
            let frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 230)
            self.userDetailHeadView?.backImageView?.frame = frame
        }
    }
}

extension UserDetailsController:NIMLoginManagerDelegate{
    func onLogin(_ step: NIMLoginStep) {
        print(step)
    }
    
    func onAutoLoginFailed(_ error: Error) {
        Toast.showErrorWith(msg: error.localizedDescription)
    }
}
