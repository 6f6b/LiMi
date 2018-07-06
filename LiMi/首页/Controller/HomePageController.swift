//
//  HomePageController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import SVProgressHUD

class HomePageController: UIViewController {
    var slidingMenuBar:SlidingMenuBar!
    var controllersContainScrollView:UIScrollView!
    var findTrendsListController:TrendsListController!
    var trendsListController:TrendsListController!
    var conditionScreeningView:ConditionScreeningView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screeningBtn = UIButton.init(type: .custom)
        screeningBtn.setImage(UIImage.init(named: "home_ic_sx"), for: .normal)
        screeningBtn.sizeToFit()
        screeningBtn.addTarget(self, action: #selector(dealScreening), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: screeningBtn)
        
        let systemMessageNumView = GET_XIB_VIEW(nibName: "SystemMessageNumView") as! SystemMessageNumView
        systemMessageNumView.frame = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        systemMessageNumView.tapBlock = {[unowned self] in
            let appState = AppManager.shared.appState()
            if appState ==  .imOffLineBusinessOffline{return}
            let systemmsgContainController = SystemmsgContainController()
            self.navigationController?.pushViewController(systemmsgContainController, animated: true)
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: systemMessageNumView)

        self.controllersContainScrollView = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64-49))
        self.controllersContainScrollView.isPagingEnabled = true
        self.controllersContainScrollView.delegate = self
        self.controllersContainScrollView.showsHorizontalScrollIndicator = false
        self.controllersContainScrollView.contentSize = CGSize.init(width: SCREEN_WIDTH*2, height: 0)
        self.view.addSubview(controllersContainScrollView)
        
        slidingMenuBar = GET_XIB_VIEW(nibName: "SlidingMenuBar") as! SlidingMenuBar
        slidingMenuBar.frame = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        self.navigationItem.titleView = slidingMenuBar
        slidingMenuBar.tapBlock = {[unowned self] (index) in
            UIView.animate(withDuration: 0.5, animations: {
                self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(index), y: 0)
            })
        }
        let findTrendsListController = TrendsListController()
        self.findTrendsListController = findTrendsListController
        findTrendsListController.type = "skill"
        self.addChildViewController(findTrendsListController)
        let findTrendsListControllerView = findTrendsListController.view
        findTrendsListControllerView?.frame = self.controllersContainScrollView.bounds
        self.controllersContainScrollView.addSubview(findTrendsListControllerView!)
        
        let trendsListController = TrendsListController()
        self.trendsListController = trendsListController
        trendsListController.type = "action"
        self.addChildViewController(trendsListController)
        let trendsListControllerView = trendsListController.view
        var tmpFrame = self.controllersContainScrollView.bounds
        tmpFrame.origin.x = tmpFrame.size.width
        trendsListControllerView?.frame = tmpFrame
        self.controllersContainScrollView.addSubview(trendsListControllerView!)
        self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*1, y: 0)
        self.slidingMenuBar.select(index: 1)
        
        self.requestUpgradeInfo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealPostATrendSuccess), name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(customMessageUnreadCountChanged), name: customSystemMessageUnreadCountChanged, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: customSystemMessageUnreadCountChanged, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        
        //检测是否登录
        if let _ = Defaults[.userToken],let _ = Defaults[.userId]{
            if !NIMSDK.shared().loginManager.isLogined(){
                AppManager.shared.loginIM()
            }
            
            //已登录
            //如果本地没有 性别信息、认证状态信息，则重新请求个人信息
            if Defaults[.userSex] == nil || Defaults[.userCertificationState] == nil{
                self.requestUserInfoData()
            }
            
            //认证信息
            if Defaults[.userCertificationState] == 0{
                self.navigationItem.leftBarButtonItem?.customView?.isHidden = true
                //还未提醒过没认证
                if Defaults[.isMindedNotAuthenticated] != true{
                    let popViewForUnAuthenticated = PopViewForUnAuthenticated.init(frame: SCREEN_RECT)
                    popViewForUnAuthenticated.tapRightBlock = {[unowned self] () in
                        let identityAuthInfoController = GetViewControllerFrom(sbName: .loginRegister ,sbID: "IdentityAuthInfoController") as! IdentityAuthInfoController
                        self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
                    }
                    popViewForUnAuthenticated.show()
                    Defaults[.isMindedNotAuthenticated] = true
                }
            }
            if Defaults[.userCertificationState] == 1{
                self.navigationItem.leftBarButtonItem?.customView?.isHidden = true
            }
            if Defaults[.userCertificationState] == 2{
                self.navigationItem.leftBarButtonItem?.customView?.isHidden = false
            }
            if Defaults[.userCertificationState] == 3{
                self.navigationItem.leftBarButtonItem?.customView?.isHidden = true
                //还未提醒过认证失败
                if Defaults[.isMindedAuthenticatedFailed] != true{
                    let popViewForAuthenticateFaild = PopViewForAuthenticateFaild.init(frame: SCREEN_RECT)
                    popViewForAuthenticateFaild.tapRightBlock = {[unowned self] () in
                        let identityAuthInfoController = GetViewControllerFrom(sbName: .loginRegister ,sbID: "IdentityAuthInfoController") as! IdentityAuthInfoController
                        self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
                    }
                    popViewForAuthenticateFaild.show()
                    Defaults[.isMindedAuthenticatedFailed] = true
                }
            }
        }else{
            //未登录
            self.navigationItem.leftBarButtonItem?.customView?.isHidden = true
        }


        if let systemMessageNumView = self.navigationItem.leftBarButtonItem?.customView as? SystemMessageNumView{
            let num = AppManager.shared.customSystemMessageManager.allCommentMessageUnreadCount() + AppManager.shared.customSystemMessageManager.allThumbUpMessageUnreadCount()
            systemMessageNumView.showWith(unreadSystemMsgNum: num)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: -misc
    //请求个人中心信息
    func requestUserInfoData() {
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let personCenter = PersonCenter()
        _ = moyaProvider.rx.request(.targetWith(target: personCenter)).subscribe(onSuccess: { (response) in
            let personCenterModel = Mapper<PersonCenterModel>().map(jsonData: response.data)
            Defaults[.userSex] = personCenterModel?.user_info?.sex
            
            let tmpIdentityStatus = Defaults[.userCertificationState]
            Defaults[.userCertificationState] = 2
            //Defaults[.userCertificationState] = personCenterModel?.user_info?.is_access
            if tmpIdentityStatus != 2 && Defaults[.userCertificationState] == 2{
                //发通知
                NotificationCenter.default.post(name: IDENTITY_STATUS_OK_NOTIFICATION, object: nil)
            }
            
            Toast.showErrorWith(model: personCenterModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    //请求版本升级信息
    func requestUpgradeInfo(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let appUpdate = AppUpdate(device: "ios", version: APP_VERSION)
        _ = moyaProvider.rx.request(.targetWith(target: appUpdate)).subscribe(onSuccess: { (response) in
            let appUpgradeModel = Mapper<AppUpgradeModel>().map(jsonData: response.data)
            let appUpgradeRemindingView = GET_XIB_VIEW(nibName: "APPUpgradeRemindingView") as! APPUpgradeRemindingView
            //
            if appUpgradeModel?.update != 2{
                appUpgradeRemindingView.showWith(upgradeModel: appUpgradeModel)
            }
            if appUpgradeModel?.serviceStatus != 0{
                
            }
            Toast.showErrorWith(model: appUpgradeModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @objc func dealPostATrendSuccess(){
        self.slidingMenuBar.select(index: 1)
        if let _tapBlock = self.slidingMenuBar.tapBlock{
            _tapBlock(1)
        }
    }
    
    @objc func dealScreening(){
        if let _ = self.conditionScreeningView{
        }else{
            self.conditionScreeningView = ConditionScreeningView.shareConditionScreeningView()
            conditionScreeningView?.screeningConditionsSelectBlock = {[unowned self] (college,academy,grade,sex,skill) in
                self.findTrendsListController.collegeModel = college
                self.findTrendsListController.academyModel = academy
                self.findTrendsListController.gradeModel = grade
                self.findTrendsListController.sexModel = sex
                self.findTrendsListController.skillModel = skill
                self.findTrendsListController.tableView.mj_header.beginRefreshing()
                
                self.trendsListController.collegeModel = college
                self.trendsListController.academyModel = academy
                self.trendsListController.gradeModel = grade
                self.trendsListController.sexModel = sex
                self.trendsListController.skillModel = skill
                self.trendsListController.tableView.mj_header.beginRefreshing()
            }
        }
        self.conditionScreeningView?.show()
    }
}

extension HomePageController:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= 0{self.slidingMenuBar.select(index: 0)}else{
            self.slidingMenuBar.select(index: 1)
        }
    }
}

//MARK: - Notification  通知
extension HomePageController{
    //自定义系统消息未读数改变
    @objc func  customMessageUnreadCountChanged(){
        if let systemMessageNumView = self.navigationItem.leftBarButtonItem?.customView as? SystemMessageNumView{
            let num = AppManager.shared.customSystemMessageManager.allCommentMessageUnreadCount() + AppManager.shared.customSystemMessageManager.allThumbUpMessageUnreadCount()
            systemMessageNumView.showWith(unreadSystemMsgNum: num)
        }
    }
}

