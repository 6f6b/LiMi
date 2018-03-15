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
    @IBOutlet weak var liaoBtn: UIButton!
    var userDetailHeadView:UserDetailHeadView?
    var userDetailSelectTrendsTypeCell:UserDetailSelectTrendsTypeCell?
    var userInfoModel:UserInfoModel?
    var type = "action"
    var skillPage = 1
    @objc var actionPage = 1
    var skillDataArray = [TrendModel]()
    var actionDataArray = [TrendModel]()
    @objc var userId:Int = 0
    var emptyInfo = "太低调了，还没有发需求"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if SYSTEM_VERSION <= 11.0{
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }else{
            self.tableView.contentInset = UIEdgeInsets.init(top: -64, left: 0, bottom: 0, right: 0)
        }
        self.tableView.estimatedRowHeight = 100
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //替换ViewController的导航栏返回按钮
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "xq_nav_back"), for: .normal)
        }
        if self.userId == Defaults[.userId]{self.liaoBtn.isHidden = true}
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    deinit {
        print("详情界面销毁")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    
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
            let session = NIMSession.init(self.userId.stringValue(), type: .P2P)
            let sessionVC = NTESSessionViewController.init(session: session)
            self.navigationController?.pushViewController(sessionVC!, animated: true)
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
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionReport = UIAlertAction.init(title: "举报", style: .default, handler: { _ in
            self.dealMoreOperationWith(operationType: .report)
        })
        let actionDefriend = UIAlertAction.init(title: "拉黑", style: .default, handler: { _ in
            self.dealMoreOperationWith(operationType: .defriend)
        })
        let actionSendMsg = UIAlertAction.init(title: "发消息", style: .default, handler: { _ in
            self.dealMoreOperationWith(operationType: .sendMsg)
        })
        let actionCancel = UIAlertAction.init(title: "取消", style: .cancel)
        
        actionController.addAction(actionReport)
        actionController.addAction(actionDefriend)
        actionController.addAction(actionSendMsg)
        actionController.addAction(actionCancel)
        
        self.present(actionController, animated: true, completion: nil)
    }
    
    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let pageIndex = self.type == "action" ? self.actionPage : self.skillPage
        let userDetails = UserDetails(page: pageIndex, user_id: self.userId, type: self.type)
        _ = moyaProvider.rx.request(.targetWith(target: userDetails)).subscribe(onSuccess: { (response) in
            let userDetailModel = Mapper<UserDetailModel>().map(jsonData: response.data)
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
            }
            self.userInfoModel = userDetailModel?.user
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(model: userDetailModel)
        }, onError: { (error) in
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @IBAction func dealLiao(_ sender: Any) {
//        UINavigationController *nav = self.navigationController;
//        NIMSession *session = [NIMSession session:self.userHomePageModel.imaccid type:NIMSessionTypeP2P];
//        NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
//        [nav pushViewController:vc animated:YES];
//        UIViewController *root = nav.viewControllers[0];
//        nav.viewControllers = @[root,vc];
        if !AppManager.shared.checkUserStatus(){return}
        //判断登录状态
        let appState = AppManager.shared.appState()
        if appState == .imOnlineBusinessOnline{
            let session = NIMSession.init((self.userId.stringValue()), type: .P2P)
            let sessionVC = NTESSessionViewController.init(session: session)
            self.navigationController?.pushViewController(sessionVC!, animated: true)
        }
        if appState == .imOnlineBusinessOffline{
            NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil, userInfo: [LOG_OUT_MESSAGE_KEY:"请先登录APP"])
        }
        if appState == .imOfflineBusinessOnline{
            //判断是否认证
            if Defaults[.userCertificationState] == 0{
                
                
                Toast.showInfoWith(text: "还未认证")
                return
            }
            if Defaults[.userCertificationState] == 1{
                Toast.showInfoWith(text: "认证中")
                return
            }
            if Defaults[.userCertificationState] == 2{
                NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil, userInfo: [LOG_OUT_MESSAGE_KEY:"IM登录已失效，请重新登录"])
                return
            }
            if Defaults[.userCertificationState] == 3{
                Toast.showInfoWith(text: "认证失败")
                return
            }
            if Defaults[.userCertificationState] == nil{
                Toast.showInfoWith(text: "可能发生异步错误")
                return
            }
        }
        if appState == .imOffLineBusinessOffline{
            NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil, userInfo: [LOG_OUT_MESSAGE_KEY:"请先登录APP"])
        }
    }
    
}

extension UserDetailsController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        let dataArray = self.type == "action" ? self.actionDataArray :self.skillDataArray
        if dataArray.count != 0{return dataArray.count}else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{return UITableViewAutomaticDimension}
        return 0.001
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            if let _ = self.userDetailHeadView{}else{
                self.userDetailHeadView = GET_XIB_VIEW(nibName: "UserDetailHeadView") as? UserDetailHeadView
                self.userDetailHeadView?.headImgV?.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 230)
            }
            self.userDetailHeadView?.configWith(model: self.userInfoModel)
            return userDetailHeadView
        }
        return nil
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if let _ = self.userDetailSelectTrendsTypeCell{}else{
                self.userDetailSelectTrendsTypeCell = GET_XIB_VIEW(nibName: "UserDetailSelectTrendsTypeCell") as? UserDetailSelectTrendsTypeCell
                self.userDetailSelectTrendsTypeCell?.selectTrendsBlock = {[unowned self] (index) in
                    if 0 == index{
                        self.type = "action"
                        self.emptyInfo = "太低调了，还没发动态"
                        self.actionPage = 1
                    }
                    if 1 == index{
                        self.type = "skill"
                        self.emptyInfo = "太低调了，还没发需求"
                        self.skillPage = 1
                    }
                    self.loadData()
                }
            }
            return self.userDetailSelectTrendsTypeCell!
        }
        
        if indexPath.section == 1{
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
                return trendsCell
            }
            if dataArray.count == 0{
                let emptyTrendsCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTrendsCell", for: indexPath) as! EmptyTrendsCell
                emptyTrendsCell.configWith(info: self.emptyInfo)
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
            self.userDetailHeadView?.headImgV?.frame = CGRect.init(x: tmpX, y: tmpY, width: tmpW, height: tmpH)
        }else{
            let frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 230)
            self.userDetailHeadView?.headImgV?.frame = frame
        }
    }
}
