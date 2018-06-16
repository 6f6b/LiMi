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

enum MusicType {
    case hot
    case new
}

let NoneSelectedIndex = 1000000;

enum PlayerStatus {
    case playing
    case pause
}

@objc protocol MusicPickViewControllerDelegate {
    func musicPickViewControllerSelectedNone();
    func musicPickViewControllerSelected(musicId:Int,musicPath:String,startTime:Float,duration:Float);
}

class MusicPickViewController: ViewController {
    @IBOutlet weak var searchContainView: UIView!
    @IBOutlet weak var searchTextFeild: UITextField!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchPlaceholder: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var hotMusicButton: UIButton!
    @IBOutlet weak var newMusicButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var musicProgressContainView: UIView!
    @IBOutlet weak var musicProgressContainViewBottomConstraint: NSLayoutConstraint!
    override var prefersStatusBarHidden: Bool{return true}
    var musics = [MusicModel]()
    var pageIndex = 1
    
    var selectedIndex:Int = NoneSelectedIndex
    var player:AVPlayer!
    var playerCurrentStatus:PlayerStatus = .pause
    var startTime:Float = 0;
    @objc var delegate:MusicPickViewControllerDelegate!
    @objc var duration:Float = 30

    //@property (nonatomic, strong) AVURLAsset *asset;
    //@property (nonatomic, strong) AliyunCrop *musicCrop;
    var musicPickView:AliyunMusicPickView!
    
    var recorder:AliyunIRecorder!
    var musicType:MusicType = .hot

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1);
        self.musicProgressContainViewBottomConstraint.constant = -160
        self.setupSubviews()
        self.addNotification()
        self.player = AVPlayer.init()
        self.collectionView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1;
            self.fetchRemoteMusic()
        }
        
        self.collectionView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1;
            self.fetchRemoteMusic()
        }
        self.setupData()
        
        self.searchTextFeild.addTarget(self, action: #selector(textFeildValueChanged(textFeild:)), for: .editingChanged)
        self.searchTextFeild.delegate = self;
    }

    
    deinit {
        self.removeNotification()
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func setupSubviews(){
        self.collectionView.register(UINib.init(nibName: "MusicPickCell", bundle: nil), forCellWithReuseIdentifier: "MusicPickCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.musicPickView = AliyunMusicPickView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 160));
        self.musicPickView.delegate = self;
        self.musicProgressContainView.addSubview(self.musicPickView);
    }
    
    @objc func playerItemDidReachEnd(){
        self.playCurrentItem()
    }
    
    func playCurrentItem(){
        if self.selectedIndex == NoneSelectedIndex{return}
        let model = self.musics[self.selectedIndex];
        let composition = self.generateWith(path: model.music, start: self.startTime, duration: self.duration);
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
                try mutableCompositionAudioTrack?.insertTimeRange(exportTimeRange, of: audioTrack!, at: kCMTimeZero)
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
        self.selectedIndex = NoneSelectedIndex;
        self.hiddenMusicProgressView()
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
            self.musicProgressContainViewBottomConstraint.constant = -160;
            self.musicProgressContainView.layoutIfNeeded()
        }
    }
    
    func showMusicProgressView(){
        UIView.animate(withDuration: 0.5) {
            self.musicProgressContainViewBottomConstraint.constant = 0;
            self.musicProgressContainView.layoutIfNeeded()
        }
    }
    
    func setupData(){
        self.fetchRemoteMusic()
    }
    
    //加载远程音乐数据
    func fetchRemoteMusic(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let type = self.musicType == .hot ? "hot" : "new"
        let target = MusicList.init(type: type, name: self.searchTextFeild.text, page: self.pageIndex)
        
        _ = moyaProvider.rx.request(.targetWith(target: target)).subscribe(onSuccess: { (response) in
            let musicListModel = Mapper<MusicListModel>().map(jsonData: response.data)
            if self.pageIndex == 1{self.musics.removeAll()}
            if let datas = musicListModel?.data{
                for data in datas{
//                    let asset = AVURLAsset.init(url: URL.init(string: data.music!)!)
//                    data.duration = Float(asset.avAssetVideoTrackDuration())
//                    let asset = [AVURLAsset assetwiurl]
//                    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
//                    AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
//                    model.name = content;
//                    model.path = path;
//                    model.duration = [asset avAssetVideoTrackDuration];
//                    model.artist = [asset artist];
//                    [self.musics addObject:model];
                    self.musics.append(data)
                }
               // if datas.count > 0{self.collectionView.reloadData()}
            }
            self.collectionView.reloadData()
            self.collectionView.mj_footer.endRefreshing()
            self.collectionView.mj_header.endRefreshing()
            Toast.showErrorWith(model: musicListModel)
//            if self.tableView.emptyDataSetDelegate == nil{
//                self.tableView.emptyDataSetDelegate = self
//                self.tableView.emptyDataSetSource = self
//                if self.dataArray.count == 0{self.tableView.reloadData()}
//            }
        }, onError: { (error) in
//            self.tableView.mj_footer.endRefreshing()
//            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
//            if self.tableView.emptyDataSetDelegate == nil{
//                self.tableView.emptyDataSetDelegate = self
//                self.tableView.emptyDataSetSource = self
//                if self.dataArray.count == 0{self.tableView.reloadData()}
//            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func refreshMusicList()-> Void {
        self.fetchRemoteMusic()
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
    
    @IBAction func hotMusicButtonClicked(_ sender: Any) {
        self.clearCurrentItem()
        self.hotMusicButton.isSelected = true
        self.newMusicButton.isSelected = false
        self.musicType = .hot
        self.refreshMusicList()
    }
    @IBAction func newMusicButtonClicked(_ sender: Any) {
        self.clearCurrentItem()
        self.hotMusicButton.isSelected = false
        self.newMusicButton.isSelected = true
        self.musicType = .new
        self.refreshMusicList()
    }
    @IBAction func clearButtonClicked(_ sender: Any) {
        self.searchTextFeild.text = ""
    }
}

extension MusicPickViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.musics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let musicModel = self.musics[indexPath.row];
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicPickCell", for: indexPath) as! MusicPickCell
        if selectedIndex == indexPath.row{
            if self.playerCurrentStatus == .playing{
                cell.configWith(musicModel: musicModel, state: .playing)
            }
            if self.playerCurrentStatus == .pause{
                cell.configWith(musicModel: musicModel, state: .pause)
            }
        }else{
            cell.configWith(musicModel: musicModel)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.selectedIndex{
            self.switchCurrentItemPlayStatus()
            collectionView.reloadData();
            return;
        }
        self.showMusicProgressView()
        self.selectedIndex = indexPath.row;
        let model = self.musics[indexPath.row];
        if let duration = model.duration{
            self.musicPickView.configureMusicDuration(duration, pageDuration: 30)
        }
        collectionView.reloadData();
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(SCREEN_WIDTH - 9*4 - 1)/3.0
        let height = width + 35
        return CGSize.init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0001
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.clearCurrentItem()
    }
}

extension MusicPickViewController:UITextFieldDelegate{
    @objc func textFeildValueChanged(textFeild:UITextField){
        self.clearCurrentItem();
        
        self.searchImage.isHidden = false;
        self.searchPlaceholder.isHidden = false;
        self.clearButton.isHidden = true;
        if let _text = textFeild.text{
            if _text.lengthOfBytes(using: String.Encoding.utf8) > 0{
                self.searchImage.isHidden = true;
                self.searchPlaceholder.isHidden = true;
                self.clearButton.isHidden = false;
            }
        }

        self.pageIndex = 1;
        self.fetchRemoteMusic();
    }
    
}

extension MusicPickViewController:AliyunMusicPickViewDelegate{
    func didSelectStartTime(_ startTime: CGFloat) {
        if self.selectedIndex == NoneSelectedIndex{return}
        let model = self.musics[self.selectedIndex];
        self.startTime = Float(startTime);
        model.startTime = Float(startTime);
        self.playCurrentItem();
    }
    func useButtonClicked(){
        let model = self.musics[self.selectedIndex];
        model.duration = self.duration;
        
        if let path = model.music,let startTime = model.startTime,let duration = model.duration,let musicId = model.id{
            Toast.showStatusWith(text: "正在下载..")
            self.download(filePath: path) { (outputPath) in
                Toast.dismiss()
                self.delegate.musicPickViewControllerSelected(musicId:musicId,musicPath: outputPath, startTime: startTime, duration: duration)
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
