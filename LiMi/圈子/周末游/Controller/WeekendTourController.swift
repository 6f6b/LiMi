//
//  WeekendTourController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import SVProgressHUD
import MJRefresh

class WeekendTourController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var scrollArray = [String]()
    var dataArray = [WeekendTourModel]()
    var pageIndex = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "周末游"
        
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 1000
        self.tableView.register(UINib.init(nibName: "WeekendBannerCell", bundle: nil), forCellReuseIdentifier: "WeekendBannerCell")
        self.tableView.register(UINib.init(nibName: "WeekendTourSeparateCell", bundle: nil), forCellReuseIdentifier: "WeekendTourSeparateCell")
        self.tableView.register(UINib.init(nibName: "WeekendTourSubjectCell", bundle: nil), forCellReuseIdentifier: "WeekendTourSubjectCell")
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        print("周末游界面销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func loadData(){
//        WeekendIndex
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let weekendIndex = WeekendIndex(page: self.pageIndex)
        _ = moyaProvider.rx.request(.targetWith(target: weekendIndex)).subscribe(onSuccess: { (response) in
            let weekendTourListContainModel = Mapper<WeekendTourListContainModel>().map(jsonData: response.data)
            if let weekendTours = weekendTourListContainModel?.data{
                for weekendTour in weekendTours{
                    self.dataArray.append(weekendTour)
                }
                if weekendTours.count > 0 {self.tableView.reloadData()}
            }
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: weekendTourListContainModel)
        }, onError: { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

extension WeekendTourController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0 == section{return 1}
        if 1 == section{return 1}
        if 2 == section{return self.dataArray.count}
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0{
//            if self.scrollArray.count == 0{return 0.001}
//        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if 0 == indexPath.section{
            let weekendBannerCell = tableView.dequeueReusableCell(withIdentifier: "WeekendBannerCell", for: indexPath)
            return weekendBannerCell
        }
        if 1 == indexPath.section{
            let weekendTourSeparateCell = tableView.dequeueReusableCell(withIdentifier: "WeekendTourSeparateCell", for: indexPath)
            return weekendTourSeparateCell
        }
        if 2 == indexPath.section{
            let weekendTourSubjectCell = tableView.dequeueReusableCell(withIdentifier: "WeekendTourSubjectCell", for: indexPath) as! WeekendTourSubjectCell
            weekendTourSubjectCell.configWith(model: self.dataArray[indexPath.row])
            return weekendTourSubjectCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if 2 == indexPath.section{
            let weekendTourDetailController = WeekendTourDetailController()
            weekendTourDetailController.weekendId = self.dataArray[indexPath.row].id
            self.navigationController?.pushViewController(weekendTourDetailController, animated: true)
        }
    }
}
