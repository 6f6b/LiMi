//
//  MediaContainController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/22.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class MediaContainController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var bottomLineLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomToolsContainView: UIView!
    
    //音乐
    var musicPath:String?
    var musicId:Int?
    var musicType:Int?

    //挑战
    var challengeName:String?
    var challengeId:Int?
    
    //位置
    
    var recordViewController:AliyunRecordViewController!
    var photoViewController:PhotoViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.setupSDKUI()
        self.scrollView.frame = SCREEN_RECT
        self.scrollView.contentSize = CGSize.init(width: SCREEN_WIDTH*2, height: SCREEN_HEIGHT)
        self.scrollView.isScrollEnabled = false
        
        self.recordViewController = AliyunMediator.shared().recordViewController() as? AliyunRecordViewController
        if let _musicId = self.musicId,let musicPath = self.musicPath,let musicType = self.musicType{
            self.recordViewController.musicId = _musicId
            self.recordViewController.musicPath = musicPath
            self.recordViewController.musicType = musicType
        }
        
        if let _challengeId = self.challengeId,let _challengeName = self.challengeName{
            self.recordViewController.challengeId = _challengeId
            self.recordViewController.challengeName = _challengeName
        }

        
        let quVideo = AliyunMediaConfig.init()
        
        //2、获得scale：
        let screenScale = UIScreen.main.scale

        var height = 0
        var width  = 0
//        if SCREEN_HEIGHT >= 800{
//            height = Int(SCREEN_HEIGHT)/2*2*3
//            width  = Int(SCREEN_WIDTH)/2*2*3
//        }else{
            height = Int(1920)/2*2
            width = Int(1080)/2*2
//        }
        
        
        quVideo.outputSize = CGSize.init(width: width, height: height)
        quVideo.minDuration = 2
        quVideo.maxDuration = CGFloat(FIRST_LEVEL_RECORD_TIME)
        quVideo.cutMode = .scaleAspectCut;
        quVideo.fps = 30;
        quVideo.bitrate = Int32(3.87*screenScale*CGFloat(width*height))
        recordViewController?.delegate = self
        recordViewController?.quVideo = quVideo

        self.photoViewController = PhotoViewController()
        if let _challengeId = self.challengeId,let _challengeName = self.challengeName{
            self.photoViewController.challengeName = _challengeName
            self.photoViewController.challengeId = _challengeId
        }
        self.photoViewController.minDuration = 2;
        self.photoViewController.maxDuration = 0;
        self.photoViewController.delegate = self

        self.addChildViewController(self.recordViewController)
        self.addChildViewController(self.photoViewController)
        
        self.scrollView.addSubview(self.recordViewController.view)
        var albumFrame = SCREEN_RECT
        albumFrame.origin.x = SCREEN_WIDTH
        self.photoViewController.view.frame = albumFrame
        self.scrollView.addSubview(self.photoViewController.view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(recordingStatusChangedWith(notification:)), name: Notification.Name.init("RecordingStatusChaged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recordDurationChanged(notification:)), name: Notification.Name.init("RecordingDurationChaged"), object: nil)

    }
    
    @objc func recordingStatusChangedWith(notification:Notification) -> Void {
        if let isRecording = notification.userInfo!["isRecording"] as? Bool{
            self.bottomToolsContainView.isHidden = isRecording;
        }
    }
    
    @objc func recordDurationChanged(notification:Notification)->Void{
        if let duration = notification.userInfo!["duration"] as? Float{
            self.bottomToolsContainView.isHidden = duration > 0 ? true : false
        }
    }

    deinit {
        print("录制容器界面销毁")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: LEAVE_PLAY_PAGE_NOTIFICATION, object: nil, userInfo: [ControllerTypeKey:VideoPlayerControllerType.all])

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    func setupSDKUI(){
        let config = AliyunIConfig.init()
        config.backgroundColor = UIColor.clear
        config.timelineBackgroundCollor = RGBA(r: 255, g: 255, b: 255, a: 0.2);
        config.timelineDeleteColor = UIColor.orange
        config.timelineTintColor = RGBA(r: 127, g: 110, b: 241, a: 1);
        config.durationLabelTextColor = UIColor.red
        config.hiddenDurationLabel = false
        config.hiddenFlashButton = false
        config.hiddenBeautyButton = false
        config.hiddenCameraButton = false
        config.hiddenImportButton = false
        config.hiddenDeleteButton = false
        config.hiddenFinishButton = true
        config.recordOnePart = false
        config.filterArray = ["filter/炽黄","filter/粉桃","filter/海蓝","filter/红润","filter/灰白","filter/经典","filter/麦茶","filter/浓烈","filter/柔柔","filter/闪耀","filter/鲜果","filter/雪梨","filter/阳光","filter/优雅","filter/朝阳","filter/波普","filter/光圈","filter/海盐","filter/黑白","filter/胶片","filter/焦黄","filter/蓝调","filter/迷糊","filter/思念","filter/素描","filter/鱼眼","filter/马赛克","filter/模糊"]
        config.imageBundleName = "QPSDK";
        config.recordType = .combination;
        config.filterBundleName = "FilterResource";
        config.showCameraButton = true;
        AliyunIConfig.setConfig(config)
    }
    
    //
    @IBAction func dealToRecord(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {[unowned self] () in
            self.bottomLineLeftConstraint.constant = CGFloat(0)
            self.scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
        }
    }
    
    //
    @IBAction func dealToAlbum(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {[unowned self] () in
            self.bottomLineLeftConstraint.constant = SCREEN_WIDTH/2.0
            self.scrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH, y: 0)
        }
    }
    
    
}

extension MediaContainController:PhotoViewControllerDelegate{
    func cancelButtonClicked() {
        self.dealToRecord(self.recordButton)
    }
    func recodBtnClick() {
        self.dealToRecord(self.recordButton)
    }
}

extension MediaContainController:AliyunRecordViewControllerDelegate{
    func exitRecord() {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        print("退出录制")
    }
    func recoderFinish(_ vc: UIViewController!, videopath videoPath: String!) {
//        PHPhotoLibrary.shared().performChanges({
//            let fileUrl = NSURL .fileURL(withPath: videoPath);
//            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl);
//        }) { (isSuccess, error) in
//            if isSuccess {
//                Toast.showSuccessWith(msg: "保存成功！")
//            }else{
//                Toast.showErrorWith(msg: "保存失败:\(error?.localizedDescription)")
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
        
        let recordVc = vc as! AliyunRecordViewController

        
        let taskPath = AliyunPathManager.createEditDir()
        AliyunPathManager.clearDir(taskPath)
        let importor = AliyunImporter.init(path: taskPath, outputSize: recordVc.quVideo.outputSize)
        importor?.addVideo(withPath: videoPath, animDuration: 0)
        let param = AliyunVideoParam.init()
        param.fps = recordVc.quVideo.fps
        param.gop = recordVc.quVideo.gop
        param.bitrate = recordVc.quVideo.bitrate
        param.videoQuality = AliyunVideoQuality.init(rawValue: recordVc.quVideo.videoQuality.rawValue)!
        param.scaleMode = AliyunScaleMode.init(rawValue: recordVc.quVideo.cutMode.rawValue)!
        importor?.setVideoParam(param)
        importor?.generateProjectConfigure()
        
//        NSString *taskPath = [AliyunPathManager createCutDir];
//        AliyunImporter *importor = [[AliyunImporter alloc] initWithPath:taskPath outputSize:_cutInfo.outputSize];
//        [importor addVideoWithPath:videoPath animDuration:0];
//        AliyunVideoParam *param = [[AliyunVideoParam alloc] init];
//        param.fps = _cutInfo.fps;
//        param.gop = _cutInfo.gop;
//        param.bitrate = _cutInfo.bitrate;
//        param.videoQuality = (AliyunVideoQuality)_cutInfo.videoQuality;
//        param.scaleMode = (AliyunScaleMode)_cutInfo.cutMode;
//        [importor setVideoParam:param];
//        [importor generateProjectConfigure];
//
//        AliyunEditViewController *editVC = (AliyunEditViewController *)AliyunMediator.shared.editViewController;
//        editVC.taskPath = taskPath;
//        editVC.config = self.cutInfo;
        
        let editVC = AliyunMediator.shared().editViewController() as! AliyunEditViewController
        editVC.taskPath = taskPath
        editVC.config = recordVc.quVideo
        editVC.musicId = recordVc.musicId
        editVC.startTime = recordVc.startTime
        editVC.duration = recordVc.duration
        editVC.musicType = recordVc.musicType
        editVC.challengeId = recordVc.challengeId
        editVC.challengeName = recordVc.challengeName
        
        self.navigationController?.pushViewController(editVC, animated: true)
        print("结束录制")
    }
    func recordViewShowLibrary(_ vc: UIViewController!) {
        print("show library")
    }
}
