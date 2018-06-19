//
//  CircleController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import MJRefresh
import Moya
import ObjectMapper
import SVProgressHUD

class CircleController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var dataArray = [WeekendTourModel]()
    var circleHomeBannerCell:CircleHomeBannerCell!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.tableViewTopConstraint.constant = -STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT
        self.tableView.separatorStyle = .none
        if SYSTEM_VERSION <= 11.0{
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }else{
            self.tableView.contentInset = UIEdgeInsets.init(top: -STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
        }

        self.tableView.estimatedRowHeight = 1000
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "WeekendTourSeparateCell", bundle: nil), forCellReuseIdentifier: "WeekendTourSeparateCell")
        self.tableView.register(UINib.init(nibName: "WeekendTourSubjectInCircleHomePageCell", bundle: nil), forCellReuseIdentifier: "WeekendTourSubjectInCircleHomePageCell")
        self.circleHomeBannerCell = GET_XIB_VIEW(nibName: "CircleHomeBannerCell") as! CircleHomeBannerCell
        self.circleHomeBannerCell.tapMenuBlock = {[unowned self] (circleMenuType) in
            if circleMenuType == .peopleNearby{
                if !AppManager.shared.checkUserStatus(){
                    return
                }
                let peopleNearbyController = PeopleNearbyController()
                self.navigationController?.pushViewController(peopleNearbyController, animated: true)
            }
            if circleMenuType == .weekendTour{
                let weekendTourController = WeekendTourController()
                self.navigationController?.pushViewController(weekendTourController, animated: true)
            }
            if circleMenuType == .topicCircle{
                let topicCircleController = TopicCircleController()
                self.navigationController?.pushViewController(topicCircleController, animated: true)
            }
        }
        
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.loadData()
        }
        self.tableView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = nil
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Mark: - misc
    func loadData(){
//        CircleList
        self.dataArray.removeAll()
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let circleList = CircleList()
        _ = moyaProvider.rx.request(.targetWith(target: circleList)).subscribe(onSuccess: { (response) in
            let weekendTourListContainModel = Mapper<WeekendTourListContainModel>().map(jsonData: response.data)
            if let weekendTours = weekendTourListContainModel?.data{
                for weekendTour in weekendTours{
                    self.dataArray.append(weekendTour)
                }
            }
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: weekendTourListContainModel)
        }, onError: { (error) in
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
        })
        
    }
}

extension CircleController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        if section == 1{return 1}
        if section == 2{return self.dataArray.count}
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == 0{return 7}
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            self.circleHomeBannerCell.selectionStyle = .none
            return self.circleHomeBannerCell
        }
        if indexPath.section == 1{
            let weekendTourSeparateCell = tableView.dequeueReusableCell(withIdentifier: "WeekendTourSeparateCell", for: indexPath) as! WeekendTourSeparateCell
            weekendTourSeparateCell.setType(type: .circleHome)
            return weekendTourSeparateCell
        }
        if indexPath.section == 2{
            let weekendTourSubjectInCircleHomePageCell = tableView.dequeueReusableCell(withIdentifier: "WeekendTourSubjectInCircleHomePageCell", for: indexPath) as! WeekendTourSubjectInCircleHomePageCell
            weekendTourSubjectInCircleHomePageCell.configWith(model: self.dataArray[indexPath.row])
            return weekendTourSubjectInCircleHomePageCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if 2 == indexPath.section{
            let weekendTourDetailController = WeekendTourDetailController()
            weekendTourDetailController._weekendId = self.dataArray[indexPath.row].id
            self.navigationController?.pushViewController(weekendTourDetailController, animated: true)
        }
    }
}


