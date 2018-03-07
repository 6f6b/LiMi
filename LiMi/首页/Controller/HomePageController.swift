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

class HomePageController: ViewController {
    var slidingMenuBar:SlidingMenuBar!
    var controllersContainScrollView:UIScrollView!
    var findTrendsListController:TrendsListController!
    var trendsListController:TrendsListController!
    var conditionScreeningView:ConditionScreeningView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screeningBtn = SuitableHotSpaceButton.init(type: .custom)
        screeningBtn.setImage(UIImage.init(named: "nav_icon_sx"), for: .normal)
        screeningBtn.sizeToFit()
        screeningBtn.addTarget(self, action: #selector(dealScreening), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: screeningBtn)
        
        let systemMessageNumView = GET_XIB_VIEW(nibName: "SystemMessageNumView") as! SystemMessageNumView
        systemMessageNumView.frame = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        systemMessageNumView.tapBlock = {
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
        slidingMenuBar.tapBlock = {(index) in
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
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: POST_TREND_SUCCESS_NOTIFICATION, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = Defaults[.userToken],let _ = Defaults[.userId]{
            //如果本地没有 性别信息、认证状态信息，则重新请求个人信息
            if let _ = Defaults[.userSex],let _ = Defaults[.userCertificationState]{
            }else{
                self.requestUserInfoData()
            }
        }
        
        if AppManager.shared.appState() != .imOffLineBusinessOffline{
            self.navigationItem.leftBarButtonItem?.customView?.isHidden = false
        }else{
            self.navigationItem.leftBarButtonItem?.customView?.isHidden = true
        }
        if let systemMessageNumView = self.navigationItem.leftBarButtonItem?.customView as? SystemMessageNumView{
            systemMessageNumView.showWith(unreadSystemMsgNum: 99)

//            systemMessageNumView.showWith(unreadSystemMsgNum: NIMSDK.shared().systemNotificationManager.allUnreadCount())
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
            SVProgressHUD.showErrorWith(model: personCenterModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
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
            SVProgressHUD.showErrorWith(model: appUpgradeModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
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
            conditionScreeningView?.screeningConditionsSelectBlock = {(college,academy,grade,sex,skill) in
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

