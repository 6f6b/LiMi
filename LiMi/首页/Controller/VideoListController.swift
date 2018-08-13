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
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    var topBackGroundView:UIView!
    var collectionView:UICollectionView!
    var bottomBackGroundView:UIView!
    var dataArray = [VideoTrendModel]()
    var newCollegeModel:CollegeModel?
    
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
//        self.topBackGroundView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT))
//        self.topBackGroundView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
//        self.view.addSubview(self.topBackGroundView)
        
//        let collectionFrame = CGRect.init(x: 0, y: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-TAB_BAR_HEIGHT)
        let collectionFrame = self.view.bounds
        let layOut = UICollectionViewFlowLayout.init()
        layOut.minimumLineSpacing = 1
        layOut.minimumInteritemSpacing = 1
        let width = (SCREEN_WIDTH-2)/2
        let height = width/0.75
        layOut.itemSize = CGSize.init(width: width, height: height)
        
        self.collectionView = UICollectionView.init(frame: collectionFrame, collectionViewLayout: layOut)
        
        self.collectionView.register(UINib.init(nibName: "ShoolHeatValueCell", bundle: nil), forCellWithReuseIdentifier: "ShoolHeatValueCell")
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
                        if self.dataArray.count <= 0{
                            self.collectionView.emptyDataSetDelegate = self
                            self.collectionView.emptyDataSetSource = self
                        }
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
            if videoTrendListModel?.college != nil{
                self.newCollegeModel = videoTrendListModel?.college
            }
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
            }
            if self.dataArray.count <= 0{
                self.collectionView.emptyDataSetDelegate = self
                self.collectionView.emptyDataSetSource = self
            }
            self.collectionView.reloadData()
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

extension VideoListController : DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "qsy")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "空空如也~"
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16),NSAttributedStringKey.foregroundColor:RGBA(r: 255, g: 255, b: 255, a: 1)]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
}

extension VideoListController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            if self.newCollegeModel != nil && self.type == 1{return 1}
            return 0
        }
        return self.dataArray.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let shoolHeatValueCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShoolHeatValueCell", for: indexPath) as! ShoolHeatValueCell
            shoolHeatValueCell.configWith(model: self.newCollegeModel)
            shoolHeatValueCell.delegate = self
            return shoolHeatValueCell
        }
        let videoListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoListCollectionViewCell", for: indexPath) as! VideoListCollectionViewCell
        videoListCollectionViewCell.configWith(model: self.dataArray[indexPath.row])
        return videoListCollectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let followAndSchoolVideoContainController = FollowAndSchoolVideoContainController.init(type: type, currentVideoTrendIndex: indexPath.row, dataArray: self.dataArray, collegeId: nil)
//        self.navigationController?.pushViewController(followAndSchoolVideoContainController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{return CGSize.init(width: SCREEN_WIDTH, height: 120)}
        let width = (SCREEN_WIDTH-2)/2
        let height = width/0.75
        return CGSize.init(width: width, height: height)
    }
}

extension VideoListController : ShoolHeatValueCellDelegate{
    func shoolHeatValueCell(cell: ShoolHeatValueCell, clickedThumbUpButtonWith model: CollegeModel?) {
        //点赞、发通知
        if let _isClick = model?.is_click,let _collegeId = model?.id{
            let moyaProvider = MoyaProvider<LiMiAPI>()
            let clickCollege = ClickCollege.init(college_id: _collegeId)
            _ = moyaProvider.rx.request(.targetWith(target: clickCollege)).subscribe(onSuccess: { (response) in
                let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
                if baseModel?.commonInfoModel?.status == successState{
                    model?.is_click = !_isClick
                    var nowClickNum = 0
                    if let preClickNum = model?.click_num{
                        nowClickNum = !_isClick ? (preClickNum+1) : (preClickNum-1)
                        model?.click_num = nowClickNum
                    }
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "CLICK_COLLEGE_NOTIFICATION"), object: nil, userInfo: ["collegeId":_collegeId,"isClick":!_isClick,"clickNum":nowClickNum])
                }
                Toast.showErrorWith(model: baseModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }
    }
}
