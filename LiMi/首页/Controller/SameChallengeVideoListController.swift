//
//  SameChallengeVideoListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/1.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import MJRefresh
import Moya
import ObjectMapper

class SameChallengeVideoListController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var challengeId:Int?
    var challengeName:String?
    var challengeModel:ChallengeModel?
    
    var pageIndex:Int = 1
    var time:Int? = Int(Date().timeIntervalSince1970)
    var musicId:Int?
    var musicType:Int?
    var collectButton:UIButton!
    var dataArray = [VideoTrendModel]()
    var player:AVPlayer!
    var playerCurrentStatus:PlayerStatus = .idle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = APP_THEME_COLOR_1
        self.collectionView.contentInset = UIEdgeInsets.init(top: -64, left: 0, bottom: 0, right: 0)
        
//        self.collectButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
//        self.collectButton.setImage(UIImage.init(named: "pstk_ic_likenor"), for: .normal)
//        self.collectButton.setImage(UIImage.init(named: "pstk_ic_likelight"), for: .selected)
//        self.collectButton.addTarget(self, action: #selector(collectButtonClicked), for: .touchUpInside)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.collectButton)
        
        self.collectionView.register(UINib.init(nibName: "VideoListInPersonCenterCell", bundle: nil), forCellWithReuseIdentifier: "VideoListInPersonCenterCell")
        self.collectionView.register(UINib.init(nibName: "ChallengeInfoInCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChallengeInfoInCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.requestData()
        }
        self.collectionView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.requestData()
        }
        requestData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.playerCurrentStatus == .playing{
            self.player.pause()
            self.playerCurrentStatus = .pause
            self.collectionView.reloadData()
        }
    }
    
    func requestData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let getChallengeVideoList = GetChallengeVideoList.init(challenge_id: self.challengeId, page: self.pageIndex)
        _ = moyaProvider.rx.request(.targetWith(target: getChallengeVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let sameChallengeVideoListModel = Mapper<SameChallengeVideoListModel>().map(jsonData: response.data)
            if self.pageIndex == 1{self.dataArray.removeAll()}
            if let videos = sameChallengeVideoListModel?.video{
                for video in videos{
                    self.dataArray.append(video)
                }
            }
            if let challengeModel = sameChallengeVideoListModel?.challenge{
                self.challengeModel = challengeModel
            }
            self.refreshUI()
            Toast.showErrorWith(model: sameChallengeVideoListModel)
            self.collectionView.mj_header.endRefreshing()
            self.collectionView.mj_footer.endRefreshing()
            }, onError: { (error) in
                self.collectionView.mj_header.endRefreshing()
                self.collectionView.mj_footer.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func refreshUI(){
        self.collectionView.reloadData()
    }
    
}

extension SameChallengeVideoListController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.challengeModel == nil {return 0}
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{return 1}
        return self.dataArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let challengeInfoInCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeInfoInCollectionViewCell", for: indexPath) as! ChallengeInfoInCollectionViewCell
//            challengeInfoInCollectionViewCell.configWith(model: self.sameParagraphVideoListModel?.music,playStatus: self.playerCurrentStatus)
//            challengeInfoInCollectionViewCell.delegate = self
            return challengeInfoInCollectionViewCell
        }
        if indexPath.section == 1{
            let videoListInPersonCenterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoListInPersonCenterCell", for: indexPath) as! VideoListInPersonCenterCell
            let videoTrendModel = self.dataArray[indexPath.row]
            videoListInPersonCenterCell.configWith(model: videoTrendModel, indexPath: indexPath)
            return videoListInPersonCenterCell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            return CGSize.init(width: SCREEN_WIDTH, height: 273)
        }
        let width = (SCREEN_WIDTH-2.5)/3
        let height = width/0.75
        return CGSize.init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 1{return 0}
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 1{return 0}
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0{return}
        let dataArray = self.dataArray
//        let sameParagraphScanVideoListController = SameParagraphScanVideoListController.init(musicModel: self.sameParagraphVideoListModel?.music, currentVideoTrendIndex: indexPath.row, dataArray: dataArray)
//        self.navigationController?.pushViewController(sameParagraphScanVideoListController, animated: true)
    }
}

