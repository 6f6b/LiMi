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
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    
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
        
        
        if let _ = self.challengeName{
            let titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
            titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            titleLabel.textColor = UIColor.white
            titleLabel.textAlignment = .center
            let attrTitle = NSMutableAttributedString.init()
            let imageAttachment = NSTextAttachment.init()
            imageAttachment.bounds = CGRect.init(x: 0, y: 0, width: 19, height: 19)
            imageAttachment.image = UIImage.init(named: "ic_topic")
            let imageAttachmentStr = NSAttributedString.init(attachment: imageAttachment)
            let titleStr = NSMutableAttributedString.init(string: self.challengeName!)
            let nsTitleStr = NSString.init(string: self.challengeName!)
            titleStr.addAttributes([NSAttributedStringKey.font:UIFont.systemFont(ofSize: 15, weight: .medium),NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.baselineOffset:3], range: nsTitleStr.range(of: self.challengeName!))
            attrTitle.append(imageAttachmentStr)
            attrTitle.append(titleStr)
            titleLabel.attributedText = attrTitle
            titleLabel.sizeToFit()
            self.navigationItem.titleView = titleLabel
        }
        
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
    
    
    @IBAction func clickJoinChallengeButton(_ sender: Any) {
        let mediaContainController = MediaContainController()
        mediaContainController.challengeName = self.challengeName
        mediaContainController.challengeId = self.challengeId
        let mediaContainControllerNav = CustomNavigationController.init(rootViewController: mediaContainController)
        self.present(mediaContainControllerNav, animated: true, completion: nil)
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
            challengeInfoInCollectionViewCell.delegate = self
            challengeInfoInCollectionViewCell.configWith(model: self.challengeModel)
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
            return CGSize.init(width: SCREEN_WIDTH, height: 280)
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
        let sameChallengeScanVideoListController = SameChallengeScanVideoListController.init(challengeId: self.challengeId!, currentVideoTrendIndex: indexPath.row, dataArray: self.dataArray,pageIndex:self.pageIndex)
        self.navigationController?.pushViewController(sameChallengeScanVideoListController, animated: true)
    }
}

extension SameChallengeVideoListController : ChallengeInfoInCollectionViewCellDelegate{
    ///点击了头像
    func challengeInfoInCollectionViewCell(cell:ChallengeInfoInCollectionViewCell,clickHeadImageWith model:ChallengeModel?){}
    ///点击了关注
    func challengeInfoInCollectionViewCell(cell:ChallengeInfoInCollectionViewCell,clickFollowButtonWith model:ChallengeModel?,followButton:UIButton){
        if !AppManager.shared.checkUserStatus(){return}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let addAttention = AddAttention.init(attention_id: model?.creator?.user_id)
        _ = moyaProvider.rx.request(.targetWith(target: addAttention)).subscribe(onSuccess: {[unowned self] (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                followButton.isHidden = true
//                if let _isAttention = videoModel?.is_attention{
//                    let nowAttention = !_isAttention
//                    videoModel?.is_attention = nowAttention
//                    for _videoAttention in self.delegate.dataArray{
//                        if _videoAttention.user?.user_id == videoModel?.user?.user_id{
//                            _videoAttention.is_attention = nowAttention
//                        }
//                    }
//                }
//                NotificationCenter.default.post(name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:videoModel])
            }
            Toast.showErrorWith(model: baseModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    ///点击了人名
    func challengeInfoInCollectionViewCell(cell:ChallengeInfoInCollectionViewCell,clickUserNameWith model:ChallengeModel?){
        if let _userId = model?.creator?.user_id{
          
            let userDetailsController = UserDetailsController()
            userDetailsController.userId = _userId
            self.navigationController?.pushViewController(userDetailsController, animated: true)
        }
    }
}

