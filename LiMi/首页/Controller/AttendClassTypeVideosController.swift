//
//  AttendClassTypeVideosController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/9.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class AttendClassTypeVideosController: UIViewController {
    var topBackGroundView:UIView!
    var tableView:UITableView!
    var bottomBackGroundView:UIView!
    var pageIndex = 1
    var time:Int?
    var dataArray = [VideoTrendModel]()
    var player:AliyunVodPlayer!
    var currentVideoPlayCell: AttendClassTypeVideoCell?
    var isVisiable  = true
    var isClickToPause = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topBackGroundView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT))
        self.topBackGroundView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.view.addSubview(self.topBackGroundView)
        
        let tableViewFrame = CGRect.init(x: 0, y: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-TAB_BAR_HEIGHT)
        
        self.tableView = UITableView.init(frame: tableViewFrame)
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
            self.resetCurrentCell()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        self.tableView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.tableView.register(UINib.init(nibName: "AttendClassTypeVideoCell", bundle: nil), forCellReuseIdentifier: "AttendClassTypeVideoCell")
        self.view.addSubview(self.tableView)
        
        self.bottomBackGroundView = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-TAB_BAR_HEIGHT, width: SCREEN_WIDTH, height: TAB_BAR_HEIGHT))
        self.bottomBackGroundView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.view.addSubview(self.bottomBackGroundView)
        
        self.player = AliyunVodPlayer.init()
        self.player.displayMode = .fitWithCropping
        self.player.circlePlay = true
        self.player.isAutoPlay = false
        self.player.delegate = self
        self.player.quality = .videoHD
        self.player.playerView.backgroundColor = UIColor.clear
        self.player.playerView.frame = SCREEN_RECT
        
        self.loadData()
        
        //离开播放页
        NotificationCenter.default.addObserver(self, selector: #selector(leave(notification:)), name: LEAVE_PLAY_PAGE_NOTIFICATION, object: nil)
        //进入播放页
        NotificationCenter.default.addObserver(self, selector: #selector(into(notification:)), name: INTO_PLAY_PAGE_NOTIFICATION, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didVideoTrendMoreOperation(notification:)), name: DID_VIDEO_TREND_MORE_OPERATION, object: nil)

    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if self.currentVideoPlayCell != nil && !isClickToPause{
//            self.player.resume()
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.currentVideoPlayCell != nil{
            self.player.pause()
        }
    }
    
    func loadData(){
        //GetStudyVideoList
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let getStudyVideoList = GetStudyVideoList.init(page: pageIndex, time: time)
        _ = moyaProvider.rx.request(.targetWith(target: getStudyVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let videoTrendListModel = Mapper<VideoTrendListModel>().map(jsonData: response.data)
            self.time = videoTrendListModel?.time
            if let trends = videoTrendListModel?.data{
                if self.pageIndex == 1{
                    self.dataArray.removeAll()
                }
                for trend in trends{
                    self.dataArray.append(trend)
                }
            }
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(model: videoTrendListModel)
            }, onError: { (error) in
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func playWith(cell:AttendClassTypeVideoCell,model:VideoTrendModel?){
        self.currentVideoPlayCell = cell
        let playerView = self.player.playerView
        currentVideoPlayCell?.installPlayerViewWith(playerView: playerView!)
        let vid = model?.video?.video ?? ""
        let keyId = VideoCertificateManager.shared.playCertificateModel?.AccessKeyId ?? ""
        let keySecret = VideoCertificateManager.shared.playCertificateModel?.AccessKeySecret ?? ""
        let securityToken = VideoCertificateManager.shared.playCertificateModel?.SecurityToken ?? ""
        self.player.prepare(withVid: vid, accessKeyId: keyId, accessKeySecret: keySecret, securityToken: securityToken)
    }
    
    func resetCurrentCell(){
        self.player.reset()
        self.player.playerView.removeFromSuperview()
        self.currentVideoPlayCell?.resetCell()
        self.currentVideoPlayCell = nil
    }
    
    @objc func didVideoTrendMoreOperation(notification:Notification){
        //删除并切换video
        if let moreOprationModel = notification.userInfo![MORE_OPERATION_KEY] as? MoreOperationModel{
            if moreOprationModel.operationType == .delete{
                for i in 0 ..< self.dataArray.count{
                    if self.dataArray[i].id == moreOprationModel.action_id{
                        self.dataArray.remove(at: i)
                        self.tableView.reloadData()
                        break
                    }
                }
            }
        }
    }
}

//mark: - 离开停止，进入播放
extension AttendClassTypeVideosController{
    @objc func leave(notification:Notification){
        if let info = notification.userInfo{
            if info[ControllerTypeKey] as? VideoPlayerControllerType == VideoPlayerControllerType.outClass{return}
        }
        print("离开停止")
        self.isVisiable = false
        self.player.pause()
    }
    
    @objc func into(notification:Notification){
        if let info = notification.userInfo{
            if info[ControllerTypeKey] as? VideoPlayerControllerType == VideoPlayerControllerType.outClass{return}
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

extension AttendClassTypeVideosController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attendClassTypeVideoCell = tableView.dequeueReusableCell(withIdentifier: "AttendClassTypeVideoCell", for: indexPath) as! AttendClassTypeVideoCell
        let model = self.dataArray[indexPath.row]
        attendClassTypeVideoCell.delegate = self
        attendClassTypeVideoCell.configWith(model: model)
        return attendClassTypeVideoCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewRowHeightWith(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //滚出既定位置则停止
        if let _currentVideoPlayCell = self.currentVideoPlayCell{
            //超出停止的参数
            let stopParameter = CGFloat(0.5)
            let window = UIApplication.shared.keyWindow
            let rect = _currentVideoPlayCell.convert(_currentVideoPlayCell.bounds, to: window)
            if (rect.origin.y + rect.size.height*stopParameter) < 0 || (rect.origin.y+rect.size.height*stopParameter) > SCREEN_HEIGHT{
                print("cell停止")
                self.resetCurrentCell()
            }
        }
        //滚动到既定位置暂不自动播放
        for visiableCell in self.tableView.visibleCells{
            //播放条件--》cell中心位于window中间高度为40的区域
            let videoContainViewConstWidth = SCREEN_WIDTH-15*2
            let videoContainViewConstHeight = videoContainViewConstWidth*(9.0/16.0)
    
            //文字高度
            let textContentHeight = CGFloat(0)
            let playHeight = 44 + 15 + videoContainViewConstHeight + 12 + textContentHeight + 12 + 44 + 20
            
            let window = UIApplication.shared.keyWindow
            let rect = visiableCell.convert(visiableCell.bounds, to: window)
            let centerY = rect.size.height*0.5+rect.origin.y
            if centerY > (SCREEN_WIDTH - playHeight)*0.5 && centerY < (SCREEN_WIDTH+playHeight)*0.5{
                if currentVideoPlayCell != visiableCell{
                    if let attendClassTypeVideoCell = visiableCell as? AttendClassTypeVideoCell,let indexPath = tableView.indexPath(for: visiableCell){
                        self.playWith(cell: attendClassTypeVideoCell, model: dataArray[indexPath.row])
                    }
                }
                break
            }
        }
    }
}

extension AttendClassTypeVideosController{
    func tableViewRowHeightWith(indexPath:IndexPath)->CGFloat{
        let model = self.dataArray[indexPath.row]
        
        var videoContainViewConstHeight = (SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT-TAB_BAR_HEIGHT)*0.8
        var videoContainViewConstWidth = videoContainViewConstHeight*(9.0/16.0)
        if let videoWidth = model.video?.width,let videoHeight = model.video?.height{
            if videoWidth > videoHeight{
                videoContainViewConstWidth = SCREEN_WIDTH-15*2
                videoContainViewConstHeight = videoContainViewConstWidth*(9.0/16.0)
            }
        }
        //文字高度
        var textContentHeight = CGFloat(0)
        if let _text = model.title{
            textContentHeight = NSString.init(string: _text).boundingRect(with: CGSize.init(width: SCREEN_WIDTH-30, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14)], context: nil).size.height
        }
        return 44 + 15 + videoContainViewConstHeight + 12 + textContentHeight + 12 + 44 + 20 + 25
    }
}

extension AttendClassTypeVideosController : AttendClassTypeVideoCellDelegate{
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickHeadImageWith model:VideoTrendModel?){
        if let userId = model?.user?.user_id{
            let userDetailsController = UserDetailsController()
            userDetailsController.userId = userId
            self.navigationController?.pushViewController(userDetailsController, animated: true)
        }
    }
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickFollowButtonWith model:VideoTrendModel?){
        if !AppManager.shared.checkUserStatus(){return}
        let videoModel = model
        
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let addAttention = AddAttention.init(attention_id: videoModel?.user?.user_id)
        _ = moyaProvider.rx.request(.targetWith(target: addAttention)).subscribe(onSuccess: {[unowned self] (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                if let _isAttention = videoModel?.is_attention{
                    let nowAttention = !_isAttention
                    videoModel?.is_attention = nowAttention
                    for _videoAttention in self.dataArray{
                        if _videoAttention.user?.user_id == videoModel?.user?.user_id{
                            _videoAttention.is_attention = nowAttention
                        }
                    }
                }
                NotificationCenter.default.post(name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:videoModel])
            }
            Toast.showErrorWith(model: baseModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
        })

    }
    //点赞
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickThumbUpWith model:VideoTrendModel?){
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
    //评论
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickHeadCommentButtonWith model:VideoTrendModel?){
        if !AppManager.shared.checkUserStatus(){return}
        let videoCommentListController = VideoCommentListController()
        videoCommentListController.view.frame = SCREEN_RECT
        videoCommentListController.videoTrendModel = model
        videoCommentListController.loadData()
        let videoCommentListNavController = CustomNavigationController.init(rootViewController: videoCommentListController)
        videoCommentListNavController.view.backgroundColor = UIColor.clear
        self.definesPresentationContext = true
        videoCommentListNavController.modalPresentationStyle = .overFullScreen
        self.present(videoCommentListNavController, animated: true, completion: nil)
    }
    //更多操作
    func attendClassTypeVideoCell(cell:AttendClassTypeVideoCell,clickMoreOperationWith model:VideoTrendModel?){
        let moreOperationController = MoreOperationController()
        moreOperationController.statusBarHidden = true
        moreOperationController.videoTrendModel = model
        moreOperationController.modalPresentationStyle = .overFullScreen
        moreOperationController.delegate = self
        self.definesPresentationContext = true
        self.present(moreOperationController, animated: true, completion: nil)
    }
    
    func attendClassTypeVideoCell(cell: AttendClassTypeVideoCell, clickPlayButtonWith model: VideoTrendModel?) {
        //点击了当下播放的cell
        if cell == self.currentVideoPlayCell{
            let playerState = self.player.playerState()
            if playerState == .play{
                self.player.pause()
                self.isClickToPause = true
            }
            if playerState == .pause{
                self.player.resume()
                self.isClickToPause = false
            }
        }else{
            //点击了其他播放cell
            self.resetCurrentCell()
            self.playWith(cell: cell,model:model)
            self.isClickToPause = false
        }
    }
}

extension AttendClassTypeVideosController : AliyunVodPlayerDelegate{
    /**
     * 功能：播放事件协议方法,主要内容 AliyunVodPlayerEventPrepareDone状态下，此时获取到播放视频数据（时长、当前播放数据、视频宽高等）
     * 参数：event 视频事件
     */
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, onEventCallback event: AliyunVodPlayerEvent) {
        if vodPlayer.isPlaying{
            self.currentVideoPlayCell?.videoPlayerContainView?.playButton.isSelected = true
        }
        
        if event == .prepareDone{
            print("播放器状态变更--->准备完毕")
            if isVisiable{
                self.player.start()
            }
        }
        if event == .play{
            self.currentVideoPlayCell?.videoPlayerContainView?.refreshPlayButtonWith(isPlay: true)
            print("播放器状态变更--->播放中")
        }
        if event == .firstFrame{
            print("播放器状态变更--->第一帧")
            self.currentVideoPlayCell?.videoPlayerContainView?.refreshPlayButtonWith(isPlay: true)
            vodPlayer.playerView.isHidden = false
            self.isClickToPause = false
        }
        if event == .pause{
            print("播放器状态变更--->暂停")
            
            self.currentVideoPlayCell?.videoPlayerContainView?.refreshPlayButtonWith(isPlay: false)

        }
        if event == .stop{
            print("播放器状态变更--->停止")
        }
        if event == .finish{
            print("播放器状态变更--->finish")
        }
        if event == .beginLoading{
            print("播放器状态变更--->开始加载")
            self.currentVideoPlayCell?.videoPlayerContainView?.refreshPlayButtonWith(isPlay: false, isLoading: true)
        }
        if event == .endLoading{
            print("播放器状态变更--->加载完毕")
            self.currentVideoPlayCell?.videoPlayerContainView?.refreshPlayButtonWith(isPlay: false, isLoading: true)
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

extension AttendClassTypeVideosController:MoreOperationControllerDelegate{
    func moreOperationReportClicked(model: VideoTrendModel?) {
        self.doMoreOperationWith(type: "report", model: model)
    }
    
    func moreOperationBlackClicked(model: VideoTrendModel?) {
        self.doMoreOperationWith(type: "black", model: model)
    }
    
    func moreOperationDeleteClicked(model: VideoTrendModel?) {
        self.doMoreOperationWith(type: "delete", model: model)
    }
    
    func doMoreOperationWith(type:String,model:VideoTrendModel?){
        if !AppManager.shared.checkUserStatus(){return}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        var body:TargetType!
        //report black delete
        let videoTrendModel = model
        var operationType:OperationType = .none
        if type == "report"{
            body = VideoMultiFunction(type: type, video_id: videoTrendModel?.id, user_id: videoTrendModel?.user?.user_id)
            operationType = .report
        }
        if type == "black"{
            body = VideoMultiFunction(type: type, video_id: videoTrendModel?.id, user_id: videoTrendModel?.user?.user_id)
            operationType = .defriend
        }
        if type == "delete"{
            body = VideoMultiFunction(type: type, video_id: videoTrendModel?.id, user_id: videoTrendModel?.user?.user_id)
            operationType = .delete
        }
        _ = moyaProvider.rx.request(.targetWith(target: body)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                var moreOperationModel = MoreOperationModel()
                moreOperationModel.operationType = operationType
                moreOperationModel.action_id = videoTrendModel?.id
                moreOperationModel.user_id = videoTrendModel?.user?.user_id
                NotificationCenter.default.post(name: DID_VIDEO_TREND_MORE_OPERATION, object: nil, userInfo: [MORE_OPERATION_KEY:moreOperationModel])
            }
            Toast.showResultWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}





