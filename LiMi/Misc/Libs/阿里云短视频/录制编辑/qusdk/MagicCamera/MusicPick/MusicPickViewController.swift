//
//  MusicPickViewController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/28.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import MJRefresh

enum MusicType:NSInteger {
    case online
    case soundTrack
    case none
}

let NoneSelectedIndex = 1000000;

enum PlayerStatus {
    case playing
    case pause
    case idle
}

@objc protocol MusicPickViewControllerDelegate {
    func musicPickViewControllerSelectedNone();
    func musicPickViewControllerSelected(musicId:Int,musicPath:String,musicType:Int,startTime:Float,duration:Float);
}

class MusicPickViewController: UIViewController {
    @IBOutlet weak var searchContainView: UIView!
    @IBOutlet weak var searchTextFeild: UITextField!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchPlaceholder: UILabel!
    @IBOutlet weak var musicListContainView: UIView!

    
    @IBOutlet weak var topCoverView: UIView!
    @IBOutlet weak var topCoverVIewTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var musicProgressContainView: UIView!
    @IBOutlet weak var musicProgressContainViewBottomConstraint: NSLayoutConstraint!
    override var prefersStatusBarHidden: Bool{return true}
    
    var selectedIndex:Int = NoneSelectedIndex
    var player:AVPlayer!
    var playerCurrentStatus:PlayerStatus = .pause
    
    @objc var delegate:MusicPickViewControllerDelegate!
    var startTime:Float = 0;
    @objc var duration:Float{
        get{
            return AppManager.shared.videoRecordTime()
        }
    }
    
    var musicPickView:AliyunMusicPickView!
    var recorder:AliyunIRecorder!

    var musicTypes = [MusicTypeModel]()
    var musicListControllers = [MusicListController]()
    
    var visiableControllerIndex:Int = 0
    
    var selectedControllerIndex:Int?
    var selectedRowIndex:Int?
    var selectedMusicModel:MusicModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clearButton = self.searchTextFeild.value(forKey: "_clearButton") as! UIButton
        clearButton.setImage(UIImage.init(named: "shanchu"), for: .normal)
        
        let tapTopCoverView = UITapGestureRecognizer.init(target: self, action: #selector(cancelToCutMusic))
        self.topCoverView.addGestureRecognizer(tapTopCoverView)
        
        self.topCoverVIewTopConstraints.constant = SCREEN_HEIGHT
        self.musicProgressContainViewBottomConstraint.constant = -SCREEN_HEIGHT
        
        self.setupSubviews()
        self.addNotification()
        self.player = AVPlayer.init()

        
        self.searchTextFeild.addTarget(self, action: #selector(textFeildEditingChanged(textFeild:)), for: .editingChanged)
        
        //请求音乐种类数据
        self.requestMusicTypes()
        self.navigationController?.navigationBar.isHidden = true
    }

    func loadSubControllersWith(musicTypes:[MusicTypeModel]){
        if musicTypes.count <= 0{return}
        var titles = [String]()
        var views = [UIView]()
        for i in 0..<musicTypes.count{
            let musicTypeModel = musicTypes[i]
            let vc = MusicListController()
            vc.index = i
            vc.delegate = self
            vc.musicTypeModel = musicTypeModel
            if i == 0{vc.autoLoadData = true}
            let title = musicTypeModel.name ?? "种类"
            let subV = vc.view
            
            titles.append(title)
            views.append(subV!)
            self.musicListControllers.append(vc)
        }
        let topSlideMenu = TopSlideMenu.init(frame: self.musicListContainView.bounds, titles: titles, childViews: views, delegate: self)
        self.musicListContainView.addSubview(topSlideMenu)
    }
    
    func requestMusicTypes(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let musicTypeList = MusicTypeList.init()
        
        _ = moyaProvider.rx.request(.targetWith(target: musicTypeList)).subscribe(onSuccess: {[unowned self] (response) in
            let musicTypeListModel = Mapper<MusicTypeListModel>().map(jsonData: response.data)
            if let data = musicTypeListModel?.data{
                for musicTypeModel in data{
                    self.musicTypes.append(musicTypeModel)
                }
            }
            self.loadSubControllersWith(musicTypes: self.musicTypes)
            Toast.showErrorWith(model: musicTypeListModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @objc func cancelToCutMusic(){
        self.clearCurrentItem()
        self.hiddenMusicProgressView()
    }
    
    deinit {
        print("MusicPickViewController销毁")
        self.removeNotification()
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func setupSubviews(){
        self.musicPickView = AliyunMusicPickView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 160));
        self.musicPickView.delegate = self
        self.musicProgressContainView.addSubview(self.musicPickView)
    }
    
    @objc func playerItemDidReachEnd(){
        if let model = self.selectedMusicModel{
            self.playWith(model: model)
        }
    }
    
    func playWith(model:MusicModel){
        let composition = self.generateWith(path: model.music, start: self.startTime, duration: self.duration);
        self.player.replaceCurrentItem(with: AVPlayerItem.init(asset: composition!))
        self.player.play()
        self.playerCurrentStatus = .playing
    }
    
    func generateWith(path:String?,start:Float,duration:Float)->AVMutableComposition?{
        if let _path = path{
            let percentURL = NSString.init(string: _path).addingPercentEscapes(using: String.Encoding.utf8.rawValue)
            let url = URL.init(string: percentURL!)
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
    
    func clearCurrentItem() -> Void {
        self.player.pause();
        self.playerCurrentStatus = .pause;
        self.resetMusicParameters()
    }
    
    func resetMusicParameters(){
        self.startTime = 0.0
        self.selectedControllerIndex = nil
        self.selectedRowIndex = nil
        self.selectedMusicModel = nil
        self.refreshAllMusicListControllers()
    }
    
    func refreshAllMusicListControllers(){
        for controller in self.musicListControllers{
            controller.tableView.reloadData()
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
    
    func hiddenMusicProgressView(){
        UIView.animate(withDuration: 0.5) {
            self.topCoverVIewTopConstraints.constant = SCREEN_HEIGHT
            self.musicProgressContainViewBottomConstraint.constant = -SCREEN_HEIGHT;
            self.musicProgressContainView.layoutIfNeeded()
            self.topCoverView.layoutIfNeeded()
        }
    }

    func showMusicProgressView(){
        UIView.animate(withDuration: 0.5) {
            self.topCoverVIewTopConstraints.constant = 0
            self.musicProgressContainViewBottomConstraint.constant = 0;
            self.musicProgressContainView.layoutIfNeeded()
            self.topCoverView.layoutIfNeeded()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func refreshMusicList()-> Void {
        //self.fetchRemoteMusic()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.clearCurrentItem();
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func noMusicButtonClicked(_ sender: Any) {
        self.clearCurrentItem();
        self.delegate?.musicPickViewControllerSelectedNone();
        self.navigationController?.popViewController(animated: true)
    }

}

extension MusicPickViewController: MusicListControllerDelegate{
    func musicKeyWord() -> String? {
        return self.searchTextFeild.text
    }
    
    func musicListController(_ musicListController: MusicListController, didSelectModel musicModel: MusicModel, rowIndex: Int?, controllerIndex: Int?) {
        var isClickBeforeRow = false
        if rowIndex == self.selectedRowIndex && controllerIndex == self.selectedControllerIndex{
            isClickBeforeRow = true
        }
        self.selectedControllerIndex = controllerIndex
        self.selectedRowIndex = rowIndex
        self.selectedMusicModel = musicModel
        
        if isClickBeforeRow{
            self.switchCurrentItemPlayStatus()
        }else{
            self.playWith(model: musicModel)
        }
        self.refreshAllMusicListControllers()

    }
    
    func musicListController(_ musicListController: MusicListController, didClickPickMusic musicModel: MusicModel, rowIndex: Int?,controllerIndex:Int?){
        let model = self.selectedMusicModel
        if let path = model?.music,let musicId = model?.music_id,let musicType = model?.music_type{
            Toast.showStatusWith(text: "正在下载..")
            self.download(filePath: path) {[unowned self] (outputPath) in
                Toast.dismiss()
                if let _time = model?.time{
                    self.delegate.musicPickViewControllerSelected(musicId:musicId,musicPath: outputPath,musicType:musicType, startTime: 0, duration: Float(_time))
                }
                self.navigationController?.popViewController(animated: true)
            }
            self.player.pause()
        }
    }
    
    func musicListController(_ musicListController: MusicListController, didClickCutMusic musicModel: MusicModel, rowIndex: Int?,controllerIndex:Int?){
        //清空信息
        self.clearCurrentItem()
        self.selectedMusicModel = musicModel
        
        let _duration = Float(musicModel.time ?? 0)
        self.musicPickView.configureMusicDuration(_duration, pageDuration: AppManager.shared.videoRecordTime())
        self.showMusicProgressView()
    }
    
    func currentSelectedMusicListControllerIndex() -> Int? {
        return self.selectedControllerIndex
    }
    
    func currentSelectedRowIndex() -> Int? {
        return self.selectedRowIndex
    }

    
    func selectedMusicStatus() -> PlayerStatus? {
        return self.playerCurrentStatus
    }
}

extension MusicPickViewController : TopSlideMenuDelegate{
    func topSlideMenuSelectedWith(index: Int) {
        self.searchTextFeild.text = nil
        self.searchPlaceholder.isHidden = false
        self.visiableControllerIndex = index
        let musicListController = self.musicListControllers[index]
        if musicListController.dataArray.count <= 0{
            musicListController.loadInitialDataWith(keyWord: self.searchTextFeild.text)
        }
    }
}


extension MusicPickViewController{
    @objc func textFeildEditingChanged(textFeild:UITextField){
        if self.selectedMusicModel != nil{
            self.clearCurrentItem();
        }
        print(textFeild.text)
        self.searchPlaceholder.isHidden = false;
        if let _text = textFeild.text{
            if _text.lengthOfBytes(using: String.Encoding.utf8) > 0{
                self.searchPlaceholder.isHidden = true;
            }
        }
        let musicListController = self.musicListControllers[self.visiableControllerIndex]
        musicListController.loadInitialDataWith(keyWord: self.searchTextFeild.text)
    }

}

extension MusicPickViewController:AliyunMusicPickViewDelegate{
    func didSelectStartTime(_ startTime: CGFloat) {
        let model = selectedMusicModel;
        self.startTime = Float(startTime);
        self.playWith(model: model!)
    }
    
    func useButtonClicked(){
        let model = self.selectedMusicModel
        if let path = model?.music,let musicId = model?.music_id,let musicType = model?.music_type{
            Toast.showStatusWith(text: "正在下载..")
            self.download(filePath: path) {[unowned self] (outputPath) in
                Toast.dismiss()
                if let _time = model?.time{
                    let duration = Float(_time)-self.startTime
                    self.delegate.musicPickViewControllerSelected(musicId:musicId,musicPath: outputPath,musicType:musicType, startTime: self.startTime, duration: duration)
                }
                self.navigationController?.popViewController(animated: true)
            }
            self.player.pause()
//            let format = path.components(separatedBy: ".").last
////            let parser = AliyunNativeParser.init(path: path);
////            let format = parser?.getValueForKey(Int(ALIYUN_AUDIO_CODEC));
//            if format == "mp3"{
//                let musicCrop = AliyunCrop.init(delegate: self)
//                let recordDir = NSString.init(string: AliyunPathManager.createRecrodDir())
//                let musicInputPath = NSString.init(string: path);
//                let musicOutputPath = recordDir.appendingPathComponent(musicInputPath.lastPathComponent);
//                musicCrop?.inputPath = path;
//                musicCrop?.outputPath = musicOutputPath;
//                musicCrop?.startTime = startTime;
//                musicCrop?.endTime = startTime + duration;
//                musicCrop?.start();
//                Toast.showStatusWith(text: "正在处理..")
//                self.delegate?.musicPickViewControllerSelected(musicPath: musicOutputPath, startTime: startTime, duration: duration)
//            }else{
//                self.delegate?.musicPickViewControllerSelected(musicPath: path, startTime: startTime, duration: duration)
//                self.navigationController?.popViewController(animated: true)
//            }
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

extension MusicPickViewController : AliyunCropDelegate{
    /**
     裁剪失败时错误回调
     
     @param error 错误码
     */
    func crop(onError error: Int32) {
        
        Toast.showErrorWith(msg: "裁剪失败")
    }
    
    /**
     裁剪进度回调
     
     @param progress 当前进度
     */
    func cropTask(onProgress progress: Float) {
        print("裁剪进度：\(progress)");
    }
    
    /**
     退出回调
     裁剪完成时回调
     */
    func cropTaskOnComplete() {
        Toast.dismiss()
        self.navigationController?.popViewController(animated: true)
    }
    /**
     取消回调
     主动取消或退后台时回调
     */
    func cropTaskOnCancel() {
        
    }
}
