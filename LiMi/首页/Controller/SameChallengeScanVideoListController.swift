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
    
    init(challengeId:Int,currentVideoTrendIndex:Int,dataArray:[VideoTrendModel],pageIndex:Int){
        super.init(nibName: nil, bundle: nil)
        self.challengeId = challengeId
        self.pageIndex = currentVideoTrendIndex
        self.currentVideoTrendIndex = currentVideoTrendIndex
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
        let getChallengeVideoList = GetChallengeVideoList.init(challenge_id: self.challengeId, page: self.pageIndex)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: getChallengeVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let sameChallengeVideoListModel = Mapper<SameChallengeVideoListModel>().map(jsonData: response.data)
            if self.pageIndex == 1{self.dataArray.removeAll()}
            if let videos = sameChallengeVideoListModel?.video{
                for video in videos{
                    self.dataArray.append(video)
                }
            }
            scanVideosController.reloadTableViewData()
            
            scanVideosController.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: sameChallengeVideoListModel)
            }, onError: { (error) in
                scanVideosController.tableView.mj_header.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
//    let sameChallengeVideoListModel = Mapper<SameChallengeVideoListModel>().map(jsonData: response.data)
//    if self.pageIndex == 1{self.dataArray.removeAll()}
//    if let videos = sameChallengeVideoListModel?.video{
//        for video in videos{
//            self.dataArray.append(video)
//        }
//    }
//    if let challengeModel = sameChallengeVideoListModel?.challenge{
//        self.challengeModel = challengeModel
//    }
//    self.refreshUI()
//    Toast.showErrorWith(model: sameChallengeVideoListModel)
//    self.collectionView.mj_header.endRefreshing()
//    self.collectionView.mj_footer.endRefreshing()
//}, onError: { (error) in
//    self.collectionView.mj_header.endRefreshing()
//    self.collectionView.mj_footer.endRefreshing()
//    Toast.showErrorWith(msg: error.localizedDescription)
//})
    
}
