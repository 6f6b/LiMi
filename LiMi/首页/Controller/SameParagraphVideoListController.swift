//
//  SameParagraphVideoListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/9.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import MJRefresh
import Moya
import ObjectMapper

class SameParagraphVideoListController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var collectionView: UICollectionView!
    var pageIndex:Int = 1
    var time:Int? = Int(Date().timeIntervalSince1970)
    var musicId:Int?
    var musicType:Int?
    var collectButton:UIButton!
    var dataArray = [VideoTrendModel]()
    var player:AVPlayer!
    var playerCurrentStatus:PlayerStatus = .idle

    var sameParagraphVideoListModel:SameParagraphVideoListModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = APP_THEME_COLOR_1
        self.collectionView.contentInset = UIEdgeInsets.init(top: -64, left: 0, bottom: 0, right: 0)
        
        self.collectButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
        self.collectButton.setImage(UIImage.init(named: "pstk_ic_likenor"), for: .normal)
        self.collectButton.setImage(UIImage.init(named: "pstk_ic_likelight"), for: .selected)
        self.collectButton.addTarget(self, action: #selector(collectButtonClicked), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.collectButton)
        
        self.collectionView.register(UINib.init(nibName: "VideoListInPersonCenterCell", bundle: nil), forCellWithReuseIdentifier: "VideoListInPersonCenterCell")
        self.collectionView.register(UINib.init(nibName: "MusicInfoInCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MusicInfoInCollectionViewCell")
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
        self.player = AVPlayer.init()
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

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
    
    //MARK: - player相关
    @objc func playerItemDidReachEnd(){
        if let model = self.sameParagraphVideoListModel?.music{
            self.playWith(model: model)
        }
    }
    
    func playWith(model:MusicModel){
        let composition = self.generateWith(path: model.music, start: 0, duration: 30);
        self.player.replaceCurrentItem(with: AVPlayerItem.init(asset: composition!))
        self.player.play()
        self.playerCurrentStatus = .playing
    }
    
    func generateWith(path:String?,start:Float,duration:Float)->AVMutableComposition?{
        if let _path = path{
            let url = URL.init(string: _path)
            let asset = AVURLAsset.init(url: url!)
            let mutableComposition = AVMutableComposition()
            let mutableCompositionAudioTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first
            let startTime = CMTime.init(value: CMTimeValue(1000*start), timescale: 1000)
            let stopTime = CMTime.init(value: CMTimeValue(1000*(start+duration)), timescale: 1000)
            let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            do{
                if let _audioTrack = audioTrack{
                    try mutableCompositionAudioTrack?.insertTimeRange(exportTimeRange, of: _audioTrack, at: kCMTimeZero)
                }
            }catch{
                Toast.showErrorWith(msg: error.localizedDescription)
            }
            return mutableComposition
        }else{
            return nil
        }
    }
    
    func switchCurrentItemPlayStatus()->Void{
        self.playerCurrentStatus = self.playerCurrentStatus == .playing ? .pause : .playing
        if self.playerCurrentStatus == .pause{
            self.player.pause();
        }else{
            self.player.play();
        }
    }
    
    @objc func collectButtonClicked(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let musicCollect = MusicCollect.init(music_id: self.sameParagraphVideoListModel?.music?.music_id, music_type: self.sameParagraphVideoListModel?.music?.music_type)
        
        _ = moyaProvider.rx.request(.targetWith(target: musicCollect)).subscribe(onSuccess: {[unowned self] (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                if let _is_collect = self.sameParagraphVideoListModel?.music?.is_collect{
                    self.sameParagraphVideoListModel?.music?.is_collect = !_is_collect
                }
                self.collectButton.isSelected = self.sameParagraphVideoListModel?.music?.is_collect ?? false
            }
            Toast.showErrorWith(model: baseModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func requestData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let _time = self.time ?? Int(Date().timeIntervalSince1970)
        let getSameVideoList = GetSameVideoList.init(music_id: self.musicId, music_type: self.musicType, page: pageIndex, time: _time)
        _ = moyaProvider.rx.request(.targetWith(target: getSameVideoList)).subscribe(onSuccess: {[unowned self] (response) in
            let sameParagraphVideoListModel = Mapper<SameParagraphVideoListModel>().map(jsonData: response.data)
            if let _ = sameParagraphVideoListModel?.music{
                self.sameParagraphVideoListModel = sameParagraphVideoListModel
            }
            if let _time = sameParagraphVideoListModel?.time{
                self.time = _time
            }
            if self.pageIndex == 1{
                self.dataArray.removeAll()
                if let videoTrend = sameParagraphVideoListModel?.original_video?.first{
                    self.dataArray.append(videoTrend)
                }
            }
            if let _videos = sameParagraphVideoListModel?.video{
                for videoTrend in _videos{
                    self.dataArray.append(videoTrend)
                }
            }
            self.refreshUI()
            Toast.showErrorWith(model: sameParagraphVideoListModel)
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
        if let _isCollect = self.sameParagraphVideoListModel?.music?.is_collect{
            self.collectButton.isSelected = _isCollect
        }
    }
    
    @IBAction func clickTakeSameVideo(_ sender: Any) {
            let model = self.sameParagraphVideoListModel?.music
            if let path = model?.music,let musicId = model?.music_id,let musicType = model?.music_type{
                Toast.showStatusWith(text: "正在下载..")
                self.download(filePath: path) {[unowned self] (outputPath) in
                    Toast.dismiss()
                    let mediaContainController = MediaContainController()
                    mediaContainController.musicId = musicId
                    mediaContainController.musicPath = outputPath
                    mediaContainController.musicType = musicType
                    let mediaContainControllerNav = CustomNavigationController.init(rootViewController: mediaContainController)
                    self.present(mediaContainControllerNav, animated: true, completion: nil)
                }
                self.player.pause()
            }
    }
    
    func download(filePath:String,successBlock:@escaping ((String)->Void)){
        let fileManager = FileManager.default;
        let fileName = NSString.init(string: filePath).lastPathComponent
        let musicDownloadDir = NSString.init(string: AliyunPathManager.creatMusicDownloadDir())
        let musicOutputPath = musicDownloadDir.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: musicOutputPath){
            successBlock(musicOutputPath)
            return;
        }
        if !fileManager.fileExists(atPath: AliyunPathManager.creatMusicDownloadDir()){
            do{
                try fileManager.createDirectory(atPath: AliyunPathManager.creatMusicDownloadDir(), withIntermediateDirectories: true, attributes: nil);
            }catch{
                
            }
        }
        
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let dowloader = Downloader.init(filePath: filePath)
        _ = moyaProvider.rx.request(.targetWith(target: dowloader)).subscribe(onSuccess: { (response) in
            let audioData = response.data;
            do{
                try audioData.write(to: URL.init(fileURLWithPath: musicOutputPath))
                successBlock(musicOutputPath)
            }catch{
                Toast.showErrorWith(msg: error.localizedDescription)
            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}

extension SameParagraphVideoListController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.sameParagraphVideoListModel == nil {return 0}
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{return 1}
        return self.dataArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let musicInfoInCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicInfoInCollectionViewCell", for: indexPath) as! MusicInfoInCollectionViewCell
            musicInfoInCollectionViewCell.configWith(model: self.sameParagraphVideoListModel?.music,playStatus: self.playerCurrentStatus)
            musicInfoInCollectionViewCell.delegate = self
            return musicInfoInCollectionViewCell
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
        let sameParagraphScanVideoListController = SameParagraphScanVideoListController.init(musicModel: self.sameParagraphVideoListModel?.music, currentVideoTrendIndex: indexPath.row, dataArray: dataArray)
        self.navigationController?.pushViewController(sameParagraphScanVideoListController, animated: true)
    }
}

extension SameParagraphVideoListController: MusicInfoInCollectionViewCellDelegate{
    func musicInfoInCollectionViewCell(palyerButtonClicked playerButton: UIButton) {
        if let musicModel = self.sameParagraphVideoListModel?.music{
            if self.playerCurrentStatus == .idle{self.playWith(model: musicModel)}else{
                self.switchCurrentItemPlayStatus()
            }
            self.collectionView.reloadData()
        }
    }
}
