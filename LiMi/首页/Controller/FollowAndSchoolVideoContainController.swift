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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func scanVideosControllerRequestDataWith(scanVideosController: ScanVideosController) {
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let indexVideoList = IndexVideoList.init(page: pageIndex, time: time, type: type, college_id: collegeId)
        _ = moyaProvider.rx.request(.targetWith(target: indexVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let videoTrendListModel = Mapper<VideoTrendListModel>().map(jsonData: response.data)
            self.time = videoTrendListModel?.time ?? self.time
            if let trends = videoTrendListModel?.data{
                if self.pageIndex == 1{
                    self._dataArray.removeAll()
                }
                for trend in trends{
                    self._dataArray.append(trend)
                }
                scanVideosController.reloadCollectionData()
                if trends.count <= 0{
//                    scanVideosController.collectionView.mj_footer.resetNoMoreData()
                    //scanVideosController.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }
            }else{
//                scanVideosController.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }
            scanVideosController.collectionView.mj_footer.endRefreshing()
//            scanVideosController.collectionView.mj_header.endRefreshing()
            Toast.showErrorWith(model: videoTrendListModel)
            }, onError: { (error) in
                scanVideosController.collectionView.mj_footer.endRefreshing()
                scanVideosController.collectionView.mj_header.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

