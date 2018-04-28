//
//  WeekendTourDetailController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.

import UIKit
import Moya
import ObjectMapper
import SVProgressHUD
import MJRefresh

class WeekendTourDetailController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var _weekendId:Int?
    @objc var weekendId:Int{
        get{
            if _weekendId != nil{return _weekendId!}
            return 0
        }
        set{
            _weekendId = newValue
        }
    }
    var weekendTourDetailModel:WeekendTourDetailModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SYSTEM_VERSION <= 11.0{
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }else{
            self.tableView.contentInset = UIEdgeInsets.init(top: -64, left: 0, bottom: 0, right: 0)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 1000
        self.tableView.estimatedSectionHeaderHeight = 100
        self.tableView.register(UINib.init(nibName: "WeekendTourDetailCell", bundle: nil), forCellReuseIdentifier: "WeekendTourDetailCell")
        self.tableView.register(UINib.init(nibName: "WeekendTourServiceMerchantCell", bundle: nil), forCellReuseIdentifier: "WeekendTourServiceMerchantCell")
        self.tableView.register(UINib.init(nibName: "WeekendTourBookingInfoCell", bundle: nil), forCellReuseIdentifier: "WeekendTourBookingInfoCell")

        self.loadData()
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
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
//        self.navigationController?.navigationBar.barStyle = .default
//    }
    
    deinit {
        print("周末游详情销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Mark: - misc
    //跳转到订单生成页面
    @IBAction func dealToPreOrderController(_ sender: Any) {
        if !AppManager.shared.checkUserStatus(){return}

        let weekendTourOrderDetailController = WeekendTourOrderDetailController()
        weekendTourOrderDetailController.weekendTourId = self.weekendId
        self.navigationController?.pushViewController(weekendTourOrderDetailController, animated: true)
    }
    
    
    func loadData(){
//        WeekendTourDetailModel
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let weekendInfo = WeekendInfo(weekend_id: self.weekendId)
        _ = moyaProvider.rx.request(.targetWith(target: weekendInfo)).subscribe(onSuccess: { (response) in
            let weekendTourDetailModel = Mapper<WeekendTourDetailModel>().map(jsonData: response.data)
            self.weekendTourDetailModel = weekendTourDetailModel
            self.tableView.reloadData()
            Toast.showErrorWith(model: weekendTourDetailModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

extension WeekendTourDetailController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if nil != self.weekendTourDetailModel{return 3}
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{return UITableViewAutomaticDimension}
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if 0 == section{
            let weekendTourSubjectHeaderView = GET_XIB_VIEW(nibName: "WeekendTourSubjectHeaderView") as! WeekendTourSubjectHeaderView
            weekendTourSubjectHeaderView.configWith(model: self.weekendTourDetailModel)
            return weekendTourSubjectHeaderView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if 0 == indexPath.section{
            let weekendTourDetailCell = tableView.dequeueReusableCell(withIdentifier: "WeekendTourDetailCell", for: indexPath) as! WeekendTourDetailCell
            weekendTourDetailCell.configWith(model: self.weekendTourDetailModel)
            return weekendTourDetailCell
        }
        if 1 == indexPath.section{
            let weekendTourServiceMerchantCell = tableView.dequeueReusableCell(withIdentifier: "WeekendTourServiceMerchantCell", for: indexPath) as! WeekendTourServiceMerchantCell
            weekendTourServiceMerchantCell.configWith(model: self.weekendTourDetailModel)
            return weekendTourServiceMerchantCell
        }
        if 2 == indexPath.section{
            let weekendTourBookingInfoCell = tableView.dequeueReusableCell(withIdentifier: "WeekendTourBookingInfoCell", for: indexPath) as! WeekendTourBookingInfoCell
            return weekendTourBookingInfoCell
        }
        return UITableViewCell()
    }
}
