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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if self.subControllerContainView.subviews.last == self.scanVideosController.view{
            NotificationCenter.default.post(name: INTO_PLAY_PAGE_NOTIFICATION, object: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
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
    func homeTopViewSegmentButtonClicked(button: UIButton, index: Int)  {
        self.choosedSchoolInfoLabel?.isHidden = true
        if index == 0{
            self.navigationController?.navigationBar.isHidden = true
            self.statusBarHidden = true
            self.subControllerContainView.bringSubview(toFront: self.scanVideosController.view)
            NotificationCenter.default.post(name: INTO_PLAY_PAGE_NOTIFICATION, object: nil)
        }
        if index == 1{
            self.statusBarHidden = false
            self.subControllerContainView.bringSubview(toFront: self.myFollowsVideosController.view)
            NotificationCenter.default.post(name: LEAVE_PLAY_PAGE_NOTIFICATION, object: nil)

        }
        if index == 2{
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
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func homeTopViewMsgButtonClicked() {
        let systemmsgContainController = SystemmsgContainController()
        self.navigationController?.pushViewController(systemmsgContainController, animated: true)
    }
}

extension HomeContainViewController:SchoolListControllerDelegate{
    func schoolListControllerChoosedSchoolWith(model: CollegeModel) {
        self.choosedSchoolInfoLabel?.text = model.name
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
                for trend in trends{
                    self._dataArray.append(trend)
                }
                scanVideosController.reloadCollectionData()
            }
            scanVideosController.collectionView.mj_header.endRefreshing()
            Toast.showErrorWith(model: videoTrendListModel)
            }, onError: { (error) in
                scanVideosController.collectionView.mj_header.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}
