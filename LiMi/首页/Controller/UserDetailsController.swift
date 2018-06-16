//
//  UserDetailsController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import MJRefresh
import Moya
import SVProgressHUD
import ObjectMapper

class UserDetailsController: ViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var toolsContainView: UIView!
    @IBOutlet weak var liaoBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var toolContainViewBottomConstraint: NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool{
        return false
    }

    @IBOutlet weak var collectionViewTopConstriant: NSLayoutConstraint!
    @IBOutlet weak var customNavigationBar: UIView!
    @IBOutlet weak var customNavigationBarTopConstraint: NSLayoutConstraint!
        @IBOutlet weak var customMoreOperationButton: UIButton!
    
    var userDetailHeadView:UserDetailHeadView?
    var userDetailSelectTrendsTypeCell:UserDetailSelectTrendsTypeCell?
    var userInfoModel:UserInfoModel?
    var type :MyCenterVideoListType = .myVideo
    var myVideoPageIndex = 1
    var myLikedVideoPageIndex = 1
    var refreshTimeInterval:Int? = Int(Date().timeIntervalSince1970)
    var myVideoDataArray = [VideoTrendModel]()
    var myLikedVideoDataArray = [VideoTrendModel]()
    @objc var userId:Int = 0
    var emptyInfo = "太低调了，还没有发动态"
    var isSpread:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.customNavigationBar.backgroundColor = UIColor.red
        if (self.navigationController?.navigationBar.isHidden)!{
            if SYSTEM_VERSION <= 11.0{
                self.collectionViewTopConstriant.constant = 0
                self.customNavigationBarTopConstraint.constant = STATUS_BAR_HEIGHT
                self.collectionView.contentInset = UIEdgeInsets.init(top: -STATUS_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
            }
            if SYSTEM_VERSION > 11.0{
                self.collectionViewTopConstriant.constant = -STATUS_BAR_HEIGHT
                self.customNavigationBarTopConstraint.constant = 0
                self.collectionView.contentInset = UIEdgeInsets.init(top: -STATUS_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
            }
        }else{
            self.customNavigationBar.isHidden = true
            if SYSTEM_VERSION <= 11.0{
                self.collectionView.contentInset = UIEdgeInsets.init(top: -STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
            }
            if SYSTEM_VERSION > 11.0{
                self.collectionViewTopConstriant.constant = -STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT
                self.collectionView.contentInset = UIEdgeInsets.init(top: -STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
            }
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(SingleInfoCollectionViewCell.self, forCellWithReuseIdentifier: "SingleInfoCollectionViewCell")
        self.collectionView.register(UserDetailSingleInfoWithQuestionCell.self, forCellWithReuseIdentifier: "UserDetailSingleInfoWithQuestionCell")

        self.collectionView.register(UINib.init(nibName: "VideoListInPersonCenterCell", bundle: nil), forCellWithReuseIdentifier: "VideoListInPersonCenterCell")
        self.collectionView.register(UINib.init(nibName: "UserDetailHeadView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserDetailHeadView")
        self.collectionView.register(UserDetailChooseHiddenOrNotView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserDetailChooseHiddenOrNotView")
        self.collectionView.register(UserDetailSelectTrendsTypeView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserDetailSelectTrendsTypeView")

        
//        registerTrendsCellFor(tableView: self.tableView)
//        self.tableView.register(UINib.init(nibName: "EmptyTrendsCell", bundle: nil), forCellReuseIdentifier: "EmptyTrendsCell")

        self.collectionView.mj_footer = mjGifFooterWith {[unowned self] in
            
            if self.type == .myVideo{self.myVideoPageIndex += 1}
            if self.type == .iLikedVideo{self.myLikedVideoPageIndex += 1}
            self.loadData()
        }
        
        if self.userId != Defaults[.userId]{
            self.customMoreOperationButton.isHidden = false
            
            let moreBtn = UIButton.init(type: .custom)
            moreBtn.setImage(UIImage.init(named: "xq_nav_more"), for: .normal)
            moreBtn.sizeToFit()
            moreBtn.addTarget(self, action: #selector(dealMoreOperation(_:)), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: moreBtn)
        }else{
            self.customMoreOperationButton.isHidden = true
        }
        
        loadData()
        //添加IM登录代理
        NIMSDK.shared().loginManager.add(self)
    }

    deinit {
        NIMSDK.shared().loginManager.remove(self)
        print("详情界面销毁")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //替换ViewController的导航栏返回按钮
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "xq_nav_back"), for: .normal)
        }
        if self.userId == Defaults[.userId]{self.toolContainViewBottomConstraint.constant = 50}
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    func refreshToolContainViewWith(model:UserInfoModel?){
        if model?.is_attention == 0{
            self.followBtn.setTitle("关注", for: .normal)
            self.followBtn.setImage(UIImage.init(named: "xq_ic_guanzhu"), for: .normal)
        }
        if model?.is_attention == 1{
            self.followBtn.setTitle("已关注", for: .normal)
            self.followBtn.setImage(UIImage.init(named: "xq_ic_ygz"), for: .normal)
        }
        if model?.is_attention == 2{
            self.followBtn.setTitle("互相关注", for: .normal)
            self.followBtn.setImage(UIImage.init(named: "xq_ic_hxgz"), for: .normal)
        }
    }
    
    //改变关注关系
    @IBAction func dealChangeRelationship(_ sender: Any) {
        if !AppManager.shared.checkUserStatus(){return}
        if self.userInfoModel?.is_attention == 0{
            self.changeRelationship()
        }else{
            let popViewForChooseToUnFollow = PopViewForChooseToUnFollow.init(frame: SCREEN_RECT)
            popViewForChooseToUnFollow.tapRightBlock = {[unowned self] () in
                self.changeRelationship()
            }
            popViewForChooseToUnFollow.show()
        }
    }
    
    func changeRelationship(){
        Toast.showStatusWith(text: nil)
        if let userId = self.userInfoModel?.user_id{
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            let addAttention = AddAttention.init(attention_id: userId)
            _ = moyaProvider.rx.request(.targetWith(target: addAttention)).subscribe(onSuccess: {[unowned self] (response) in
                let personCenterModel = Mapper<PersonCenterModel>().map(jsonData: response.data)
                self.userInfoModel?.is_attention = personCenterModel?.user_info?.is_attention
                if personCenterModel?.commonInfoModel?.status == successState{
                    self.refreshToolContainViewWith(model: personCenterModel?.user_info)
                }
                Toast.showErrorWith(model: personCenterModel)
                }, onError: { (error) in
                    Toast.showErrorWith(msg: error.localizedDescription)
            })
        }
    }
    /// 更多操作
    ///
    /// - Parameters:
    ///   - operationType: 操作类型如：拉黑、删除、举报、发消息
    ///   - trendModel: 动态模型
    func dealMoreOperationWith(operationType:OperationType){
        if !AppManager.shared.checkUserStatus(){return}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        var type:String? = nil
        if operationType == .defriend{type = "black"}
        if operationType == .delete{type = "delete"}
        if operationType == .report{type = "report"}
        if operationType == .sendMsg{
            ChatWith(toUserId: self.userId, navigationController: self.navigationController)
            return
        }
        let moreOperation = MoreOperation(type: type, action_id: nil, user_id: self.userId)
        _ = moyaProvider.rx.request(.targetWith(target: moreOperation)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            Toast.showResultWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @objc func dealMoreOperation(_ sender: Any) {
        let actionReport = SuspensionMenuAction.init(title: "举报", action: {
            self.dealMoreOperationWith(operationType: .report)
        })
        
        let actionDefriend = SuspensionMenuAction(title: "拉黑", action: {
            self.dealMoreOperationWith(operationType: .defriend)
        })
        
        let actionSendMsg = SuspensionMenuAction(title: "发消息", action: {
            self.dealMoreOperationWith(operationType: .sendMsg)
        })

        let actions = [actionReport,actionDefriend,actionSendMsg]
        let suspensionExpandMenu = SuspensionExpandMenu.init(actions: actions)
        suspensionExpandMenu.showAround(view: self.navigationItem.rightBarButtonItem?.customView)
    }
    
    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let pageIndex = self.type == .myVideo ? self.myVideoPageIndex : self.myLikedVideoPageIndex
        let videoPersonalDetails = VideoPersonalDetails.init(user_id: self.userId, time: self.refreshTimeInterval, page: pageIndex, type: self.type.hashValue)
        _ = moyaProvider.rx.request(.targetWith(target: videoPersonalDetails)).subscribe(onSuccess: {[unowned self] (response) in
            let videoUserDetailModel = Mapper<VideoUserDetailModel>().map(jsonData: response.data)
            self.refreshTimeInterval = videoUserDetailModel?.timestamp == nil ? self.refreshTimeInterval : videoUserDetailModel?.timestamp
            self.userInfoModel = videoUserDetailModel?.user
            self.userDetailHeadView?.configWith(model: self.userInfoModel)
            self.refreshToolContainViewWith(model: videoUserDetailModel?.user)
            Toast.showErrorWith(model: videoUserDetailModel)
            self.collectionView.mj_footer.endRefreshing()
            print(videoUserDetailModel?.video_list)
            if let videoTrends = videoUserDetailModel?.video_list{
                if self.type == .myVideo{
                    if self.myVideoPageIndex == 1{self.myVideoDataArray.removeAll()}
                    for videoTrend in videoTrends{
                        self.myVideoDataArray.append(videoTrend)
                    }
                }
                if self.type == .iLikedVideo{
                    if self.myLikedVideoPageIndex == 1{self.myVideoDataArray.removeAll()}
                    for videoTrend in videoTrends{
                        self.myLikedVideoDataArray.append(videoTrend)
                    }
                }
            }
            self.collectionView.reloadData()
        }, onError: { (error) in
            self.collectionView.mj_footer.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @IBAction func customMoreOperationButtonClicked(_ sender: Any) {
        self.dealMoreOperation(self.customMoreOperationButton)
    }
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func dealLiao(_ sender: Any) {
        if !AppManager.shared.checkUserStatus(){return}
        //判断登录状态
        let appState = AppManager.shared.appState()
        if appState == .imOnlineBusinessOnline || appState == .imOfflineBusinessOnline{
            ChatWith(toUserId: self.userId, navigationController: self.navigationController)
        }
        if appState == .imOnlineBusinessOffline{
            NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil, userInfo: [LOG_OUT_MESSAGE_KEY:"请先登录APP"])
        }
        if appState == .imOffLineBusinessOffline{
            NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: nil, userInfo: [LOG_OUT_MESSAGE_KEY:"请先登录APP"])
        }
    }
    
}


extension UserDetailsController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.userInfoModel == nil{return 0}
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{return 0}
        if section == 1{
            if self.isSpread{return 4}
            if !self.isSpread{return 2}
        }
        if section == 2{
            let dataArray = self.type == .myVideo ? self.myVideoDataArray :self.myLikedVideoDataArray
            //if dataArray.count == 0{return 1}
            return dataArray.count
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        if section == 0{
            let userDetailHeadView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserDetailHeadView", for: indexPath) as! UserDetailHeadView
            self.userDetailHeadView?.backImageView?.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 230)
            userDetailHeadView.configWith(model: self.userInfoModel)
            return userDetailHeadView
        }
        if section == 1{
            let userDetailChooseHiddenOrNotView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserDetailChooseHiddenOrNotView", for: indexPath) as! UserDetailChooseHiddenOrNotView
            userDetailChooseHiddenOrNotView.rightBtn.isSelected = self.isSpread
            print(self.isSpread)
            userDetailChooseHiddenOrNotView.tapBtnBlock = {[unowned self] (button) in
                self.isSpread = button.isSelected
                print(self.isSpread)
                print(button.isSelected)
                self.collectionView.reloadData()
            }
            return userDetailChooseHiddenOrNotView
        }
        if section == 2{
            let  userDetailSelectTrendsTypeView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserDetailSelectTrendsTypeView", for: indexPath) as! UserDetailSelectTrendsTypeView
            var initialIndex = 0
            if self.type == .myVideo{
                initialIndex = 0
            }else{
                initialIndex = 1
            }
            userDetailSelectTrendsTypeView.initialIndex = initialIndex
            userDetailSelectTrendsTypeView.refreshUIWith(selectedIndex: initialIndex)
            userDetailSelectTrendsTypeView.tapBlock = {[unowned self] (index) in
                if self.type == .myVideo && index == 0{return}
                if self.type == .iLikedVideo && index == 1{return}
                self.type = index == 0 ? .myVideo : .iLikedVideo
                self.emptyInfo = index == 0 ?  "太低调了，还没发动态" : "太低调了，还没发需求"
                self.loadData()
                self.collectionView.reloadData()
            }
            return userDetailSelectTrendsTypeView
        }
        return UICollectionReusableView.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{return CGSize.init(width: SCREEN_WIDTH, height: 280)}
        if section == 1{return CGSize.init(width: SCREEN_WIDTH, height: 50)}
        if section == 2{return CGSize.init(width: SCREEN_WIDTH, height: 50)}
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                if indexPath.section == 0{return UICollectionViewCell()}
                if indexPath.section == 1{
                    let infoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleInfoCollectionViewCell", for: indexPath) as! SingleInfoCollectionViewCell
                    if indexPath.row == 0{
                        var info = "学校  "
                        if let _college = self.userInfoModel?.college{
                            info.append(_college)
                        }
                        infoCell.infoLabel.text = info
                    }
                    if indexPath.row == 1{
                        var info = "学院  "
                        if let academy = self.userInfoModel?.school{
                            info.append(academy)
                        }
                        infoCell.infoLabel.text = info
                    }
                    if indexPath.row == 2{
                        var info = "年级  "
                        if let grade = self.userInfoModel?.grade{
                            info.append(grade)
                        }
                        infoCell.infoLabel.text = info
                    }
                    if indexPath.row == 3{
                        let userDetailSingleInfoWithQuestionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserDetailSingleInfoWithQuestionCell", for: indexPath) as! UserDetailSingleInfoWithQuestionCell
                        var info = "姓名  "
                        if let name = self.userInfoModel?.true_name{
                            info.append(name)
                            userDetailSingleInfoWithQuestionCell.questionBtn.isHidden = true
                        }else{
                            info.append("无法透露")
                            userDetailSingleInfoWithQuestionCell.questionBtn.isHidden = false
                        }
                        userDetailSingleInfoWithQuestionCell.infoLabel.text = info
                        return userDetailSingleInfoWithQuestionCell
                    }
                    return infoCell
                }
                if indexPath.section == 2{
                    let videoListInPersonCenterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoListInPersonCenterCell", for: indexPath) as! VideoListInPersonCenterCell
                    let dataArray = self.type == .myVideo ? self.myVideoDataArray : self.myLikedVideoDataArray
                    let videoTrendModel = dataArray[indexPath.row]
                    videoListInPersonCenterCell.configWith(model: videoTrendModel)
                    return videoListInPersonCenterCell
                }
                return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1{return CGSize.init(width: SCREEN_WIDTH, height: 30)}
//        layOut.minimumLineSpacing = 1
//        layOut.minimumInteritemSpacing = 1
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
        let dataArray = self.type == .myVideo ? self.myVideoDataArray : self.myLikedVideoDataArray
        let otherUserDetailVideoAndLikedVideosController = OtherUserDetailVideoAndLikedVideosController.init(type: self.type.hashValue, currentVideoTrendIndex: indexPath.row, dataArray: dataArray, userId: self.userId)
        self.navigationController?.pushViewController(otherUserDetailVideoAndLikedVideosController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        if scrollView.contentOffset.y > 230{
        //            //导航栏颜色
        //            self.navigationController?.navigationBar.backgroundColor = UIColor.white
        //            //返回按钮颜色
        //            let backBtn = self.navigationItem.leftBarButtonItem?.customView as! UIButton
        //            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        //            //title
        //            self.title = "个人中心"
        //            //更多
        //            let moreBtn = self.navigationItem.rightBarButtonItem?.customView as! UIButton
        //            moreBtn.setImage(UIImage.init(named: "btn_jubao"), for: .normal)
        //        }else{
        //            //导航栏颜色
        //            self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        //            //返回按钮颜色
        //            let backBtn = self.navigationItem.leftBarButtonItem?.customView as! UIButton
        //            backBtn.setImage(UIImage.init(named: "nav_back"), for: .normal)
        //            //title
        //            self.title = nil
        //            //更多
        //
        //            if let moreBtn = self.navigationItem.rightBarButtonItem?.customView as? UIButton{
        //                moreBtn.setImage(UIImage.init(named: "nav_btn_jubao"), for: .normal)
        //            }
        //        }
        return
        let offsetY = -scrollView.contentOffset.y
        if offsetY > 0{
            let tmpX = -(SCREEN_WIDTH/230)*(offsetY*0.5)
            let tmpY = -offsetY
            let tmpW = SCREEN_WIDTH+(SCREEN_WIDTH/230)*offsetY
            let tmpH = 230 + offsetY
            self.userDetailHeadView?.backImageView?.frame = CGRect.init(x: tmpX, y: tmpY, width: tmpW, height: tmpH)
        }else{
            let frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 230)
            self.userDetailHeadView?.backImageView?.frame = frame
        }
    }
}


extension UserDetailsController:NIMLoginManagerDelegate{
    func onLogin(_ step: NIMLoginStep) {
        print(step)
    }
    
    func onAutoLoginFailed(_ error: Error) {
        Toast.showErrorWith(msg: error.localizedDescription)
    }
}
