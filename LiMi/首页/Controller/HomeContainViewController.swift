//
//  HomeContainViewController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/4.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

class HomeContainViewController: ViewController {
    var statusBarHidden:Bool = true
    override var prefersStatusBarHidden: Bool{return statusBarHidden}
    private var subControllerContainView:UIView!
    private var homeTopView:HomeTopView!
    private var choosedSchoolInfoLabel:UILabel?
    private var scanVideosController:ScanVideosController!
    private var myFollowsVideosController:MyFollowsVideosController!
    private var schoolsVideosController:SchoolsVideosController!
    var currentSelectedControllerIndex = 0
    
    /*变量*/
    var _pageIndex:Int = 1
    var _dataArray:[VideoTrendModel] = [VideoTrendModel]()
    var _time:Int? = Int(Date().timeIntervalSince1970)
    var _currentVideoTrendIndex:Int = 0

    private var timer:Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.subControllerContainView = UIView.init(frame: SCREEN_RECT)
        self.view.addSubview(self.subControllerContainView)
        
        self.homeTopView = HomeTopView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT), initialIndex: 0, delegate: self)
        self.view.addSubview(self.homeTopView)
        
        self.scanVideosController = ScanVideosController()
        self.scanVideosController.delegate = self
        self.subControllerContainView.addSubview(self.scanVideosController.view)
        self.addChildViewController(self.scanVideosController)
        
        self.myFollowsVideosController = MyFollowsVideosController()
        self.subControllerContainView.addSubview(self.myFollowsVideosController.view)
        self.addChildViewController(self.myFollowsVideosController)
        
        self.schoolsVideosController = SchoolsVideosController()
        self.subControllerContainView.addSubview(self.schoolsVideosController.view)
        self.addChildViewController(self.schoolsVideosController)
        
        self.subControllerContainView.bringSubview(toFront: self.scanVideosController.view)
        
        self.choosedSchoolInfoLabel = UILabel.init(frame: CGRect.init(x: 15, y: self.homeTopView.frame.maxY + 6, width: SCREEN_WIDTH-30, height: 34))
        self.choosedSchoolInfoLabel?.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.7)
        self.choosedSchoolInfoLabel?.layer.cornerRadius = 17
        self.choosedSchoolInfoLabel?.clipsToBounds = true
        self.choosedSchoolInfoLabel?.textColor = UIColor.white
        self.choosedSchoolInfoLabel?.font = UIFont.systemFont(ofSize: 14)
        self.choosedSchoolInfoLabel?.isHidden = true
        self.choosedSchoolInfoLabel?.text = nil
        self.choosedSchoolInfoLabel?.textAlignment = .center
        self.view.addSubview(self.choosedSchoolInfoLabel!)
        
        self.requestUpgradeInfo()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.isHidden = true
        if self.subControllerContainView.subviews.last == self.scanVideosController.view{
            NotificationCenter.default.post(name: INTO_PLAY_PAGE_NOTIFICATION, object: nil)
        }
        
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: LEAVE_PLAY_PAGE_NOTIFICATION, object: nil)
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
            Defaults[.userCertificationState] = personCenterModel?.user_info?.is_access
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
    
    func showChoosedSchoolInfoLabel(){
        UIView.animate(withDuration: 0.5) {
            self.choosedSchoolInfoLabel?.isHidden = false
        }
        if #available(iOS 10.0, *) {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
                UIView.animate(withDuration: 0.5) {
                    self.choosedSchoolInfoLabel?.isHidden = true
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }
}

extension HomeContainViewController:HomeTopViewDelegate{
    func homeTopViewSegmentButtonClicked(button: UIButton, index: Int)->Bool  {
        self.choosedSchoolInfoLabel?.isHidden = true
        if index == 0{
            self.navigationController?.navigationBar.isHidden = true
            self.statusBarHidden = true
            self.subControllerContainView.bringSubview(toFront: self.scanVideosController.view)
            NotificationCenter.default.post(name: INTO_PLAY_PAGE_NOTIFICATION, object: nil)
        }
        if index == 1{
            if !AppManager.shared.checkUserStatus(){return false}
            self.statusBarHidden = false
            self.subControllerContainView.bringSubview(toFront: self.myFollowsVideosController.view)
            NotificationCenter.default.post(name: LEAVE_PLAY_PAGE_NOTIFICATION, object: nil)

        }
        if index == 2{
            if !AppManager.shared.checkUserStatus(){return false}
            if currentSelectedControllerIndex == 2{
                let schoolListController = SchoolListController()
                schoolListController.delegate = self
                self.present(schoolListController, animated: true, completion: nil)
            }else{
                self.statusBarHidden = false
                self.subControllerContainView.bringSubview(toFront: self.schoolsVideosController.view)
                NotificationCenter.default.post(name: LEAVE_PLAY_PAGE_NOTIFICATION, object: nil)

            }
        }
        currentSelectedControllerIndex = index
        self.setNeedsStatusBarAppearanceUpdate()
        return true
    }
    
    func homeTopViewMsgButtonClicked() {
        let systemmsgContainController = SystemmsgContainController()
        self.navigationController?.pushViewController(systemmsgContainController, animated: true)
    }
}

extension HomeContainViewController:SchoolListControllerDelegate{
    func schoolListControllerChoosedSchoolWith(model: CollegeModel) {
        self.choosedSchoolInfoLabel?.text = "当前选择为“\(model.name!)”"
        self.showChoosedSchoolInfoLabel()
        self.schoolsVideosController.collegeModel = model
        self.schoolsVideosController.collectionView.mj_header.beginRefreshing()
        self.dismiss(animated: true, completion: nil)
    }
    
    func schoolListControllerCancelButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension HomeContainViewController:ScanVideosControllerDelegate{
    var pageIndex: Int {
        get {
            return _pageIndex
        }
        set {
            _pageIndex = newValue
        }
    }
    
    var dataArray: [VideoTrendModel] {
        get {
            return _dataArray
        }
        set {
            _dataArray = newValue
        }
    }
    
    var time: Int? {
        get {
            return _time
        }
        set {
            _time = newValue
        }
    }
    
    var currentVideoTrendIndex: Int {
        get {
            return _currentVideoTrendIndex
        }
        set {
            _currentVideoTrendIndex = newValue
        }
    }

    
    /*函数*/
    func scanVideosControllerRequestDataWith(scanVideosController: ScanVideosController) {
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let getVideoList = GetVideoList.init(page: pageIndex, time:time)
        _ = moyaProvider.rx.request(.targetWith(target: getVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let videoTrendListModel = Mapper<VideoTrendListModel>().map(jsonData: response.data)
            self._time = videoTrendListModel?.time
            if let trends = videoTrendListModel?.data{
                if self.pageIndex == 1{
                    self._dataArray.removeAll()
                }
                var isAdd = true
                let firstTrend = trends.first
                for trend in self.dataArray{
                    if trend.id == firstTrend?.id{
                        isAdd = false
                        break
                    }
                }
                if isAdd{
                    for trend in trends{
                        self.dataArray.append(trend)
                    }
                }
                scanVideosController.reloadCollectionData()
            }
            scanVideosController.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: videoTrendListModel)
            }, onError: { (error) in
                scanVideosController.tableView.mj_header.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}
