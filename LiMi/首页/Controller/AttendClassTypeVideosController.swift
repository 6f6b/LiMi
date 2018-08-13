//
//  AttendClassTypeVideosController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/9.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class AttendClassTypeVideosController: UIViewController {
    var topBackGroundView:UIView!
    var tableView:UITableView!
    var bottomBackGroundView:UIView!
    var pageIndex = 1
    var time:Int?
    var dataArray = [VideoTrendModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topBackGroundView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT))
        self.topBackGroundView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.view.addSubview(self.topBackGroundView)
        
        let tableViewFrame = CGRect.init(x: 0, y: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-TAB_BAR_HEIGHT)
        
        self.tableView = UITableView.init(frame: tableViewFrame)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        self.tableView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.tableView.register(UINib.init(nibName: "AttendClassTypeVideoCell", bundle: nil), forCellReuseIdentifier: "AttendClassTypeVideoCell")
        self.view.addSubview(self.tableView)
        
        self.bottomBackGroundView = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-TAB_BAR_HEIGHT, width: SCREEN_WIDTH, height: TAB_BAR_HEIGHT))
        self.bottomBackGroundView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.view.addSubview(self.bottomBackGroundView)
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadData(){
        //GetStudyVideoList
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let getStudyVideoList = GetStudyVideoList.init(page: pageIndex, time: time)
        _ = moyaProvider.rx.request(.targetWith(target: getStudyVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let videoTrendListModel = Mapper<VideoTrendListModel>().map(jsonData: response.data)
            self.time = videoTrendListModel?.time
            if let trends = videoTrendListModel?.data{
                if self.pageIndex == 1{
                    self.dataArray.removeAll()
                }
                for trend in trends{
                    self.dataArray.append(trend)
                }
            }
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(model: videoTrendListModel)
            }, onError: { (error) in
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}

extension AttendClassTypeVideosController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attendClassTypeVideoCell = tableView.dequeueReusableCell(withIdentifier: "AttendClassTypeVideoCell", for: indexPath) as! AttendClassTypeVideoCell
        let model = self.dataArray[indexPath.row]
        attendClassTypeVideoCell.configWith(model: model)
        return attendClassTypeVideoCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewRowHeightWith(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension AttendClassTypeVideosController{
    func tableViewRowHeightWith(indexPath:IndexPath)->CGFloat{
        return 400
    }
}




