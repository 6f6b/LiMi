//
//  ScanVideosController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/4.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

class ScanVideosController: ViewController {
    var collectionView:UICollectionView!
    var dataArray = [VideoTrendModel]()
    var pageIndex:Int = 1
    var oldTime:String?
    var newTime:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let layOut = UICollectionViewFlowLayout.init()
        layOut.itemSize = SCREEN_RECT.size
        self.collectionView = UICollectionView.init(frame: SCREEN_RECT, collectionViewLayout: layOut)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(UINib.init(nibName: "VideoPlayCell", bundle: nil), forCellWithReuseIdentifier: "VideoPlayCell")
        self.collectionView.isPagingEnabled = true
        self.view.addSubview(self.collectionView)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.requestData()
        }
        
        self.requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func requestData(){
        //GetVideoList
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let getVideoList = GetVideoList.init(page: pageIndex, time_old: oldTime, time_new: newTime)
        _ = moyaProvider.rx.request(.targetWith(target: getVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let videoTrendListModel = Mapper<VideoTrendListModel>().map(jsonData: response.data)
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
            Toast.showErrorWith(model: videoTrendListModel)
            }, onError: { (error) in
                self.collectionView.mj_header.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

extension ScanVideosController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let videoPlayCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayCell", for: indexPath) as! VideoPlayCell
        return videoPlayCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SCREEN_RECT.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
