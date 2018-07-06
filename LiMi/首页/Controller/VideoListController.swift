//
//  VideoListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/4.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

class VideoListController: UIViewController {
    var topBackGroundView:UIView!
    var collectionView:UICollectionView!
    var bottomBackGroundView:UIView!
    var dataArray = [VideoTrendModel]()
    var pageIndex:Int = 1
    var time:Int? = Int(Date().timeIntervalSince1970)
    var type:Int?{
        get{
            return nil
        }
    }
    var collegeId:Int?{
        get{
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topBackGroundView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT))
        self.topBackGroundView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.view.addSubview(self.topBackGroundView)
        
        let collectionFrame = CGRect.init(x: 0, y: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-TAB_BAR_HEIGHT)
        let layOut = UICollectionViewFlowLayout.init()
        layOut.minimumLineSpacing = 1
        layOut.minimumInteritemSpacing = 1
        let width = (SCREEN_WIDTH-2)/2
        let height = width/0.75
        layOut.itemSize = CGSize.init(width: width, height: height)
        
        self.collectionView = UICollectionView.init(frame: collectionFrame, collectionViewLayout: layOut)
        self.collectionView.register(UINib.init(nibName: "VideoListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoListCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.collectionView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        self.collectionView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.view.addSubview(self.collectionView)
        
        self.bottomBackGroundView = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-TAB_BAR_HEIGHT, width: SCREEN_WIDTH, height: TAB_BAR_HEIGHT))
        self.bottomBackGroundView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.view.addSubview(self.bottomBackGroundView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didVideoTrendMoreOperation(notification:)), name: DID_VIDEO_TREND_MORE_OPERATION, object: nil)
    }
    
    @objc func didVideoTrendMoreOperation(notification:Notification){
        //删除并切换video
        if let moreOprationModel = notification.userInfo![MORE_OPERATION_KEY] as? MoreOperationModel{
            if moreOprationModel.operationType == .delete{
                for i in 0 ..< self.dataArray.count{
                    if self.dataArray[i].id == moreOprationModel.action_id{
                        self.dataArray.remove(at: i)
                        self.collectionView.reloadData()
                        return
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Defaults[.userId] != nil && self.dataArray.count == 0{
            self.loadData()
        }
    }

    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let _time = self.time ?? Int(Date().timeIntervalSince1970)
        let indexVideoList = IndexVideoList.init(page: pageIndex, time: _time, type: type, college_id: collegeId)
        _ = moyaProvider.rx.request(.targetWith(target: indexVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let videoTrendListModel = Mapper<VideoTrendListModel>().map(jsonData: response.data)
            if let _time = videoTrendListModel?.time{
                self.time = _time
            }
            if let trends = videoTrendListModel?.data{
                if self.pageIndex == 1{
                    self.dataArray.removeAll()
                }
                for trend in trends{
                    self.dataArray.append(trend)
                }
                self.collectionView.reloadData()
            }
            self.collectionView.mj_header.endRefreshing()
            self.collectionView.mj_footer.endRefreshing()
            Toast.showErrorWith(model: videoTrendListModel)
            }, onError: { (error) in
                self.collectionView.mj_header.endRefreshing()
                self.collectionView.mj_footer.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension VideoListController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let videoListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoListCollectionViewCell", for: indexPath) as! VideoListCollectionViewCell
        videoListCollectionViewCell.configWith(model: self.dataArray[indexPath.row])
        return videoListCollectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let followAndSchoolVideoContainController = FollowAndSchoolVideoContainController.init(type: type, currentVideoTrendIndex: indexPath.row, dataArray: self.dataArray, collegeId: nil)
//        self.navigationController?.pushViewController(followAndSchoolVideoContainController, animated: true)
    }
}
