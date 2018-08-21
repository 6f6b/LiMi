//
//  SingleVideoPlayController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/30.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

class SingleVideoPlayController: UIViewController {
    override var prefersStatusBarHidden: Bool{return true}
    var videoTrendId:Int?
    
    var tableViewContainView:UIView!
    var tableView:UITableView!
    var player:AliyunVodPlayer!
    var currentVideoPlayCell:VideoPlayCell?
    var dataArray = [VideoTrendModel]()
    var isVisiable = true
    var isFirstIn = true
    var isClickToPause = false
    var videoCommentListNavController:CustomNavigationController?
    var navigationBarView:UIView!
    var backButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = AliyunVodPlayer.init()
        self.player.displayMode = .fitWithCropping
        self.player.circlePlay = true
        self.player.isAutoPlay = false
        self.player.delegate = self
        self.player.quality = .videoHD
        self.player.playerView.backgroundColor = UIColor.clear
        self.player.playerView.frame = SCREEN_RECT
        
        self.edgesForExtendedLayout = UIRectEdge.left;
        self.extendedLayoutIncludesOpaqueBars = false;
        self.modalPresentationCapturesStatusBarAppearance = false;
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.view.backgroundColor = APP_THEME_COLOR_1
        
        self.tableViewContainView = UIView.init(frame: SCREEN_RECT)
        self.tableViewContainView.backgroundColor = APP_THEME_COLOR_1
        self.view.addSubview(self.tableViewContainView)
        
        self.tableView = UITableView.init(frame: SCREEN_RECT, style: .plain)
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.backgroundColor = APP_THEME_COLOR_1
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.register(UINib.init(nibName: "VideoPlayCell", bundle: nil), forCellReuseIdentifier: "VideoPlayCell")
        self.tableView.register(UINib.init(nibName: "NoMoreDataViewCell", bundle: nil), forCellReuseIdentifier: "NoMoreDataViewCell")
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.isPagingEnabled = true
        self.tableViewContainView.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.navigationBarView = UIView.init(frame: CGRect.init(x: 0, y: STATUS_BAR_HEIGHT, width: SCREEN_WIDTH, height: NAVIGATION_BAR_HEIGHT))
        //self.navigationBarView.backgroundColor = UIColor.yellow
        self.view.addSubview(self.navigationBarView)
        
        self.backButton = UIButton.init(frame: CGRect.init(x: 15, y: 0, width: 24, height: 14))
        self.backButton.setImage(UIImage.init(named: "short_video_back"), for: .normal)
        self.backButton.sizeToFit()
        var center = self.backButton.center
        center.y = NAVIGATION_BAR_HEIGHT * 0.5
        self.backButton.center = center
        self.backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        self.navigationBarView.addSubview(self.backButton)
        
        //离开播放页
        NotificationCenter.default.addObserver(self, selector: #selector(leave(notification:)), name: LEAVE_PLAY_PAGE_NOTIFICATION, object: nil)
        //进入播放页
        NotificationCenter.default.addObserver(self, selector: #selector(into(notification:)), name: INTO_PLAY_PAGE_NOTIFICATION, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didVideoTrendMoreOperation(notification:)), name: DID_VIDEO_TREND_MORE_OPERATION, object: nil)
        self.loadData()
    }
    
    func loadData(){
        //VideoDetail
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let videoDetail = VideoDetail.init(video_id: self.videoTrendId)
        _ = moyaProvider.rx.request(.targetWith(target: videoDetail)).subscribe(onSuccess: {[unowned self] (response) in
            let videoTrendDetailModel = Mapper<VideoTrendDetailModel>().map(jsonData: response.data)
            self.dataArray.removeAll()
            if let videoTrendModel = videoTrendDetailModel?.data{
                self.dataArray.append(videoTrendModel)
            }
            self.tableView.reloadData()
            if self.dataArray.count >= 0{
                self.playWith(currentIndex: 0)
            }
            Toast.showErrorWith(model: videoTrendDetailModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @objc func backButtonClicked(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func appDidBecomeActive(){
        print("appDidBecomeActive")
        if self.isVisiable{
            if !isClickToPause{
                self.player.resume()
            }
        }
    }
    
    @objc func appWillResignActive(){
        print("appWillResignActive")
        if self.player.playerState() != .pause{
            self.player.pause()
        }
    }
    
    @objc func appDidEnterBackground(){
        print("appDidEnterBackground")
        if self.player.playerState() != .pause{
            self.player.pause()
        }
    }
    
    @objc func appWillEnterForeground(){
        print("appWillEnterForeground")
        
        if self.isVisiable{
            if !isClickToPause{
                self.player.resume()
            }
        }
    }
    
    @objc func didVideoTrendMoreOperation(notification:Notification){
        //删除并切换video
        self.navigationController?.popViewController(animated: true)
//        if let moreOprationModel = notification.userInfo![MORE_OPERATION_KEY] as? MoreOperationModel{
//            if moreOprationModel.operationType == .delete{
//                for i in 0 ..< self.delegate.dataArray.count{
//                    if self.delegate.dataArray[i].id == moreOprationModel.action_id{
//                        self.delegate.dataArray.remove(at: i)
//                        if self.delegate.dataArray.count != 0 && i >= self.delegate.dataArray.count
//                            self.delegate.currentVideoTrendIndex = i - 1
//                        }
//                        self.reloadTableViewData()
//                        break
//                    }
//                }
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.player.release()
        print("单个视频播放界面销毁")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isVisiable = true
        self.setNeedsStatusBarAppearanceUpdate()
        self.tableView.layoutIfNeeded()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isVisiable = false
        NotificationCenter.default.post(name: LEAVE_PLAY_PAGE_NOTIFICATION, object: nil, userInfo: [ControllerTypeKey:VideoPlayerControllerType.all])        
    }
    
    
    func playWith(currentIndex:Int){
        if let currentVideoPlayCell = self.tableView.cellForRow(at: IndexPath.init(row: currentIndex, section: 0)) as? VideoPlayCell{
            self.currentVideoPlayCell = currentVideoPlayCell
            self.player.stop()
            self.player.reset()
            print("Reset:\(currentIndex)")
            let playerView = self.player.playerView
            playerView?.frame = SCREEN_RECT
            currentVideoPlayCell.addPlayerView(playerView: playerView!)
            let videoTrendModel = self.dataArray[currentIndex]
            let vid = videoTrendModel.video?.video ?? ""
            let keyId = VideoCertificateManager.shared.playCertificateModel?.AccessKeyId ?? ""
            let keySecret = VideoCertificateManager.shared.playCertificateModel?.AccessKeySecret ?? ""
            let securityToken = VideoCertificateManager.shared.playCertificateModel?.SecurityToken ?? ""
            self.player.prepare(withVid: vid, accessKeyId: keyId, accessKeySecret: keySecret, securityToken: securityToken)
        }
    }
}

extension SingleVideoPlayController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{return 50}
        return SCREEN_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let videoPlayCell = tableView.dequeueReusableCell(withIdentifier: "VideoPlayCell", for: indexPath) as! VideoPlayCell
        videoPlayCell.delegate = self
        let videoModel = self.dataArray[indexPath.row]
        videoPlayCell.configWith(videoTrendModel: videoModel)
        return videoPlayCell
    }
    
    //    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //        return 50
    //    }
    //
    //    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    //        let footerView = NoMoreDataFooterView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 50))
    //        return footerView
    //    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.player.isPlaying{
            print("滚动时----播放器处于播放状态")
            //self.player.reset()
        }
    }
    
}

extension SingleVideoPlayController:VideoPlayCellDelegate{
    func videoPlayCell(cell:VideoPlayCell,clickRemindUserWith userId:Int?){
        if let _userId = userId{
            let userDetailController = UserDetailsController()
            userDetailController.userId = _userId
            self.navigationController?.pushViewController(userDetailController, animated: true)
        }
    }
    
    ///点击头像回调
    func videoPlayCell(cell:VideoPlayCell,clickedUserHeadButton button:UIButton,withModel model:VideoTrendModel?){
        if let userId = model?.user?.user_id{
            let userDetailsController = UserDetailsController()
            userDetailsController.userId = userId
            self.navigationController?.pushViewController(userDetailsController, animated: true)
        }
    }
    ///点击用户名回调
    func videoPlayCell(cell:VideoPlayCell,clickedUserName label:UILabel,withModel model:VideoTrendModel?){
        if let userId = model?.user?.user_id{
            let userDetailsController = UserDetailsController()
            userDetailsController.userId = userId
            self.navigationController?.pushViewController(userDetailsController, animated: true)
        }
    }
    
    ///点击添加关注回调
    func videoPlayCell(cell:VideoPlayCell,clickedAddFollowButton button:UIButton,withModel model:VideoTrendModel?){
        if !AppManager.shared.checkUserStatus(){return}
        let videoModel = model
        
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let addAttention = AddAttention.init(attention_id: videoModel?.user?.user_id)
        _ = moyaProvider.rx.request(.targetWith(target: addAttention)).subscribe(onSuccess: {[unowned self] (response) in
            let attentionResultModel = Mapper<AttentionResultModel>().map(jsonData: response.data)
            if attentionResultModel?.commonInfoModel?.status == successState{
                if let _isAttention = attentionResultModel?.is_attention{
                    let nowAttention = _isAttention
                    videoModel?.is_attention = nowAttention
                    for _videoAttention in self.dataArray{
                        if _videoAttention.user?.user_id == videoModel?.user?.user_id{
                            _videoAttention.is_attention = nowAttention
                        }
                    }
                }
                NotificationCenter.default.post(name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:videoModel])
            }
            Toast.showErrorWith(model: attentionResultModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    ///点击点赞回调
    func videoPlayCell(cell:VideoPlayCell,clickedThumbsUpButton button:UIButton,withModel model:VideoTrendModel?){
        if !AppManager.shared.checkUserStatus(){return}
        let videoModel = model
        if let isClick = videoModel?.is_click{
            videoModel?.is_click = !isClick
            if !isClick{
                videoModel?.click_num = (videoModel?.click_num)! + 1
            }else{
                videoModel?.click_num = (videoModel?.click_num)! - 1
            }
            NotificationCenter.default.post(name: THUMBS_UP_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:videoModel])
        }else if  videoModel?.is_click == nil{
            videoModel?.is_click = true
            videoModel?.click_num = (videoModel?.click_num)! + 1
            NotificationCenter.default.post(name: THUMBS_UP_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:videoModel])
        }
        
        let videoClickAciton = VideoClickAction.init(video_id: videoModel?.id)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: videoClickAciton)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                
                //                if let isClick = videoModel?.is_click{
                //                    videoModel?.is_click = !isClick
                //                    if !isClick{
                //                        videoModel?.click_num = (videoModel?.click_num)! + 1
                //                    }else{
                //                        videoModel?.click_num = (videoModel?.click_num)! - 1
                //                    }
                //                    NotificationCenter.default.post(name: THUMBS_UP_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:videoModel])
                //                }else{
                //                    Toast.showErrorWith(msg: "点赞字段为空")
                //                }
            }
            Toast.showErrorWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    ///点击评论按钮回调
    func videoPlayCell(cell:VideoPlayCell,clickedCommentButton button:UIButton,withModel model:VideoTrendModel?){
        if !AppManager.shared.checkUserStatus(){return}
        let videoCommentListController = VideoCommentListController()
        videoCommentListController.view.frame = SCREEN_RECT
        videoCommentListController.videoTrendModel = model
        videoCommentListController.loadData()
        self.videoCommentListNavController = CustomNavigationController.init(rootViewController: videoCommentListController)
        self.videoCommentListNavController?.view.backgroundColor = UIColor.clear
        self.definesPresentationContext = true
        self.videoCommentListNavController?.modalPresentationStyle = .overFullScreen
        self.present(self.videoCommentListNavController!, animated: true, completion: nil)
    }
    
    ///点击更多操作
    func videoPlayCell(cell:VideoPlayCell,clickedMoreOperationButton button:UIButton,withModel model:VideoTrendModel?){
        
        let moreOperationController = MoreOperationController()
        moreOperationController.statusBarHidden = true
        moreOperationController.videoTrendModel = model
        moreOperationController.modalPresentationStyle = .overFullScreen
        moreOperationController.delegate = self
        self.definesPresentationContext = true
        self.present(moreOperationController, animated: true, completion: nil)
    }
    
    ///单击了播放cell
    func videoPlayCell(cell:VideoPlayCell,singleClickWithModel model:VideoTrendModel?){
        if self.player.playerState() == .pause{
            self.isClickToPause = false
            self.player.resume()
        }else{
            self.isClickToPause = true
            self.player.pause()
        }
    }
    
    ///双击了播放cell
    func videoPlayCell(cell:VideoPlayCell,doubleClickWithModel model:VideoTrendModel?){
        self.videoPlayCell(cell: cell, clickedThumbsUpButton: cell.thumbsUpButton, withModel: model)
    }
    
    ///左滑播放cell
    func videoPlayCell(cell:VideoPlayCell,swipeLeftWithModel model:VideoTrendModel?){
        self.videoPlayCell(cell: cell, clickedUserHeadButton: cell.userHeadButton, withModel: model)
    }
    
    ///点击音乐封面图
    func videoPlayCell(cell:VideoPlayCell,tapedMusicCoverView coverImageView:UIImageView,withModel model:VideoTrendModel?){
        //如果是旧的视频都不跳转并作出提示
        if model?.music?.music_id == 0 || model?.music?.music_id == nil{
            let alertController = UIAlertController.init(title: "通过旧版上传的原创视频暂不支持拍同款", message: nil, preferredStyle: .alert)
            let actionOK = UIAlertAction.init(title: "确定", style: .cancel, handler: nil)
            alertController.addAction(actionOK)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let sameParagraphVideoListController = SameParagraphVideoListController()
        let musicModel = model?.music
        sameParagraphVideoListController.musicId = musicModel?.music_id
        sameParagraphVideoListController.musicType = musicModel?.music_type
        
        self.navigationController?.pushViewController(sameParagraphVideoListController, animated: true)
    }
    
    
    ///点击了地理位置
    func videoPlayCell(cell:VideoPlayCell,tapedCreatedAddressWithModel model:VideoTrendModel?){
        
    }
    ///点击了挑战名称
    func videoPlayCell(cell:VideoPlayCell,tapedChallengeNameWithModel model:VideoTrendModel?){
        
    }
    ///点击了学校
    func videoPlayCell(cell:VideoPlayCell,tapedSchoolNameWithModel model:VideoTrendModel?){
        
    }
}

//mark: - 离开停止，进入播放
//mark: - 离开停止，进入播放
extension SingleVideoPlayController{
    @objc func leave(notification:Notification){
        if let info = notification.userInfo{
            if info[ControllerTypeKey] as? VideoPlayerControllerType == VideoPlayerControllerType.inClass{return}
        }
        print("离开停止")
        self.isVisiable = false
        self.player.pause()
    }
    
    @objc func into(notification:Notification){
        if let info = notification.userInfo{
            if info[ControllerTypeKey] as? VideoPlayerControllerType == VideoPlayerControllerType.inClass{return}
        }
        print("进入播放")
        self.isVisiable = true
        if self.player.playerState() == .prepared{
            self.player.start()
        }else{
            if !isClickToPause{
                self.player.resume()
            }
        }
    }
}

extension SingleVideoPlayController:MoreOperationControllerDelegate{
    func moreOperationReportClicked(model: VideoTrendModel?) {
        self.doMoreOperationWith(type: "report")
    }
    
    func moreOperationBlackClicked(model: VideoTrendModel?) {
        self.doMoreOperationWith(type: "black")
    }
    
    func moreOperationDeleteClicked(model: VideoTrendModel?) {
        self.doMoreOperationWith(type: "delete")
    }
    
    func doMoreOperationWith(type:String){
        if !AppManager.shared.checkUserStatus(){return}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        var body:TargetType!
        //report black delete
        let videoTrendModel = self.dataArray.first!
        var operationType:OperationType = .none
        if type == "report"{
            body = VideoMultiFunction(type: type, video_id: videoTrendModel.id, user_id: videoTrendModel.user?.user_id)
            operationType = .report
        }
        if type == "black"{
            body = VideoMultiFunction(type: type, video_id: videoTrendModel.id, user_id: videoTrendModel.user?.user_id)
            operationType = .defriend
        }
        if type == "delete"{
            body = VideoMultiFunction(type: type, video_id: videoTrendModel.id, user_id: videoTrendModel.user?.user_id)
            operationType = .delete
        }
        _ = moyaProvider.rx.request(.targetWith(target: body)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                var moreOperationModel = MoreOperationModel()
                moreOperationModel.operationType = operationType
                moreOperationModel.action_id = videoTrendModel.id
                moreOperationModel.user_id = videoTrendModel.user?.user_id
                NotificationCenter.default.post(name: DID_VIDEO_TREND_MORE_OPERATION, object: nil, userInfo: [MORE_OPERATION_KEY:moreOperationModel])
            }
            Toast.showResultWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}

extension SingleVideoPlayController : DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
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

extension SingleVideoPlayController:AliyunVodPlayerDelegate{
    /**
     * 功能：播放事件协议方法,主要内容 AliyunVodPlayerEventPrepareDone状态下，此时获取到播放视频数据（时长、当前播放数据、视频宽高等）
     * 参数：event 视频事件
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, onEventCallback event: AliyunVodPlayerEvent) {
        if vodPlayer.isPlaying{self.currentVideoPlayCell?.playButton.isHidden = true}
        
        if event == .prepareDone{
            print("播放器状态变更--->准备完毕")
            if isVisiable{
                self.player.start()
            }
        }
        if event == .play{
            self.currentVideoPlayCell?.playButton.isHidden = true
            print("播放器状态变更--->播放中")
        }
        if event == .firstFrame{
            print("播放器状态变更--->第一帧")
            self.currentVideoPlayCell?.videoCoverImageView.isHidden = true
            self.isClickToPause = false
        }
        if event == .pause{
            print("播放器状态变更--->暂停")
            self.currentVideoPlayCell?.playButton.isHidden = !isClickToPause
        }
        if event == .stop{
            print("播放器状态变更--->停止")
        }
        if event == .finish{
            print("播放器状态变更--->finish")
        }
        if event == .beginLoading{
            print("播放器状态变更--->开始加载")
            self.currentVideoPlayCell?.bottomBufferView.startAnimation()
        }
        if event == .endLoading{
            print("播放器状态变更--->加载完毕")
            self.currentVideoPlayCell?.bottomBufferView.stopAnimation()
        }
        if event == .seekDone{
            print("播放器状态变更--->seekdone")
        }
        
    }
    
    /**
     * 功能：播放器播放时发生错误时，回调信息
     * 参数：errorModel 播放器报错时提供的错误信息对象
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, playBack errorModel: AliyunPlayerVideoErrorModel!) {
        if errorModel.errorCode == 4105{
            VideoCertificateManager.shared.requestPlayCertificationWith {[unowned self] (_) in
                //self.playWith(currentIndex: self.delegate.currentVideoTrendIndex)
            }
        }
    }
    
    //@optional
    
    /**
     * 功能：播放器播放即将切换清晰度时
     * 参数：quality ： vid+playauth播放方式、vid+sts播放方式时的清晰度
     videoDefinition ： 媒体转码播放方式的清晰度
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, willSwitchTo quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
    /**
     * 功能：播放器播放切换清晰度完成
     * 参数：quality ： vid+playauth播放方式、vid+sts播放方式时的清晰度
     videoDefinition ： 媒体转码播放方式的清晰度
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, didSwitchTo quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
    /**
     * 功能：播放器播放切换清晰度失败
     * 参数：quality ： vid+playauth播放方式、vid+sts播放方式时的清晰度
     videoDefinition ： 媒体转码播放方式的清晰度
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, failSwitchTo quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
    /**
     * 功能：1.播放器设置了循环播放，此代理方法才会有效。2.播放器播放完成后，开始循环播放后，此协议被调用
     */
    func onCircleStart(with vodPlayer: AliyunVodPlayer!) {
        
    }
    /*
     *功能：播放器请求时，通知用户传入的参数鉴权过期。
     */
    func onTimeExpiredError(with vodPlayer: AliyunVodPlayer!) {
        VideoCertificateManager.shared.requestPlayCertificationWith {[unowned self] (_) in
            //self.playWith(currentIndex: self.delegate.currentVideoTrendIndex)
        }
    }
    /*
     *功能：播放地址将要过期时，提示用户当前播放地址过期。 （策略：当前播放器地址过期时间2小时，我们在播放地址差1分钟过期时提供回调；（7200-60）秒时发送）
     *参数：videoid：将过期时播放的videoId
     *参数：quality：将过期时播放的清晰度，playauth播放方式和STS播放方式有效。
     *参数：videoDefinition：将过期时播放的清晰度，MPS播放方式时有效。
     */
    func vodPlayerPlaybackAddressExpired(withVideoId videoId: String!, quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        VideoCertificateManager.shared.requestPlayCertificationWith {[unowned self] (_) in
            //self.playWith(currentIndex: self.delegate.currentVideoTrendIndex)
        }
    }
}
