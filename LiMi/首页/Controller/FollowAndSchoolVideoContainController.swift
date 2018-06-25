//
//  FollowAndSchoolVideoContainController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

class FollowAndSchoolVideoContainController: ScanVideosContainController {
    var type:Int?
    var collegeId:Int?

    
    init(type:Int?,currentVideoTrendIndex:Int,dataArray:[VideoTrendModel],collegeId:Int? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        self.currentVideoTrendIndex = currentVideoTrendIndex
        self.collegeId = collegeId
        for videoTrendModel in dataArray{
            self.dataArray.append(videoTrendModel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    deinit {
        print("关注和学校容器界面销毁")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func scanVideosControllerRequestDataWith(scanVideosController: ScanVideosController) {

        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let _time = self.time ?? Int(Date().timeIntervalSince1970)
        let indexVideoList = IndexVideoList.init(page: pageIndex, time: _time, type: type, college_id: collegeId)
        _ = moyaProvider.rx.request(.targetWith(target: indexVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let videoTrendListModel = Mapper<VideoTrendListModel>().map(jsonData: response.data)
            if let _time = videoTrendListModel?.time{
                self.time = _time
            }
            if let trends = videoTrendListModel?.data{
                if self.pageIndex == 1{self.dataArray.removeAll()}
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
                scanVideosController.reloadTableViewData()
                scanVideosController.tableView.mj_header.endRefreshing()
            }
            Toast.showErrorWith(model: videoTrendListModel)
            }, onError: { (error) in
                scanVideosController.tableView.mj_header.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

