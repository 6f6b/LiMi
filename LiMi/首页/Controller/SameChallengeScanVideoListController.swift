//
//  SameChallengeScanVideoListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/1.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

class SameChallengeScanVideoListController: ScanVideosContainController {
    var challengeId:Int?
    
    init(challengeId:Int,currentVideoTrendIndex:Int,dataArray:[VideoTrendModel]){
        super.init(nibName: nil, bundle: nil)
        self.pageIndex = currentVideoTrendIndex
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*函数*/
    override func scanVideosControllerRequestDataWith(scanVideosController: ScanVideosController) {
        
        let _time = self.time ?? Int(Date().timeIntervalSince1970)
        let getChallengeVideoList = GetChallengeVideoList.init(challenge_id: self.challengeId, page: self.pageIndex)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: getChallengeVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let sameParagraphVideoListModel = Mapper<SameParagraphVideoListModel>().map(jsonData: response.data)
            if let _time = sameParagraphVideoListModel?.time{
                self.time = _time
            }
            
            if self.pageIndex == 1{
                self.dataArray.removeAll()
                if let videoTrend = sameParagraphVideoListModel?.original_video?.first{
                    self.dataArray.append(videoTrend)
                }
            }
            if let _videos = sameParagraphVideoListModel?.video{
                for videoTrend in _videos{
                    self.dataArray.append(videoTrend)
                }
            }
            scanVideosController.reloadTableViewData()
            
            scanVideosController.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: sameParagraphVideoListModel)
            }, onError: { (error) in
                scanVideosController.tableView.mj_header.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}
