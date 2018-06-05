//
//  HomeContainViewController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/4.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class HomeContainViewController: ViewController {
    var statusBarHidden:Bool = true
    override var prefersStatusBarHidden: Bool{return statusBarHidden}
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    private var subControllerContainView:UIView!
    private var homeTopView:HomeTopView!
    private var scanVideosController:ScanVideosController!
    private var myFollowsVideosController:MyFollowsVideosController!
    private var schoolsVideosController:SchoolsVideosController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subControllerContainView = UIView.init(frame: SCREEN_RECT)
        self.view.addSubview(self.subControllerContainView)
        
        self.homeTopView = HomeTopView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT), initialIndex: 0, delegate: self)
        self.view.addSubview(self.homeTopView)
        
        self.scanVideosController = ScanVideosController()
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
}

extension HomeContainViewController:HomeTopViewDelegate{
    func homeTopViewSegmentButtonClicked(index: Int) {
        if index == 0{
            self.navigationController?.navigationBar.isHidden = true
            self.statusBarHidden = true
            self.subControllerContainView.bringSubview(toFront: self.scanVideosController.view)
        }
        if index == 1{
            self.statusBarHidden = false
            self.subControllerContainView.bringSubview(toFront: self.myFollowsVideosController.view)
        }
        if index == 2{
            self.statusBarHidden = false
            self.subControllerContainView.bringSubview(toFront: self.schoolsVideosController.view)
        }
        self.setNeedsStatusBarAppearanceUpdate()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func homeTopViewMsgButtonClicked() {
        
    }
}
