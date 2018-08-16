//
//  MoreSettingController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/28.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class MoreSettingController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var tableView: UITableView!
    var userInfoModel:UserInfoModel?
    
    var dataArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "更多设置"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(MenuCell.self, forCellReuseIdentifier: "MenuCell")
        self.dataArray = ["我的现金","我的订单","黑名单","申请认证","隐私设置","用户反馈","关于"]
        self.tableView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - action
    @IBAction func logoutButtonClicked(_ sender: Any) {
        let alertVC = UIAlertController.init(title: "确认退出登录？", message: nil, preferredStyle: .alert)
        let actionOK = UIAlertAction.init(title: "确定", style: .default) {_ in
            NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: self, userInfo: nil)
            if let _tabController = UIApplication.shared.keyWindow?.rootViewController as? TabBarController{
                _tabController.selectedIndex = 0
                _tabController.tabBar.backgroundColor = UIColor.clear
            }
        }
        let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(actionOK)
        alertVC.addAction(actionCancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
}

extension MoreSettingController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        menuCell.configWith(title: self.dataArray[indexPath.row])
        return menuCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = self.dataArray[indexPath.row]
        print(title)
        //我的现金
        if indexPath.row == 0{
            if !AppManager.shared.checkUserStatus(){return}
            let myCashController = MyCashController()
            myCashController.userInfoModel = self.userInfoModel
            self.navigationController?.pushViewController(myCashController, animated: true)
        }
        //我的订单
        if indexPath.row == 1{
            if !AppManager.shared.checkUserStatus(){return}
            let myOrderListController = MyOrderListController()
            self.navigationController?.pushViewController(myOrderListController, animated: true)
        }
        //黑名单
        if indexPath.row == 2{
            if !AppManager.shared.checkUserStatus(){return}
            let myBlackListController = MyBlackListController()
            self.navigationController?.pushViewController(myBlackListController, animated: true)
        }
        if indexPath.row == 3{
            let studentCertificationController = GetViewControllerFrom(sbName: .personalCenter, sbID: "StudentCertificationController") as! StudentCertificationController
            self.navigationController?.pushViewController(studentCertificationController, animated: true)
        }
        //隐私设置
        if indexPath.row == 4{
            let privacySettingController = PrivacySettingController()
            privacySettingController.userInfoModel = self.userInfoModel
            self.navigationController?.pushViewController(privacySettingController, animated: true)
        }
        //用户反馈
        if indexPath.row == 5{
            if !AppManager.shared.checkUserStatus(){return}
            let feedBackController = FeedBackController()
            self.navigationController?.pushViewController(feedBackController, animated: true)
        }
        //关于粒米
        if indexPath.row == 6{
            let aboutUsController = AboutUsController()
            self.navigationController?.pushViewController(aboutUsController, animated: true)
        }
    }
}
