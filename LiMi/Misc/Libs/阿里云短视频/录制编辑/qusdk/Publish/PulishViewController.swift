//
//  PulishViewController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/30.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

@objc class PulishViewController: ViewController {
    @objc var backgroundImage:UIImage!
    @objc var taskPath:String!;
    @objc var config:AliyunMediaConfig!
    @objc var outputSize:CGSize = CGSize.zero
    
    var containerView:UIView!;
    var topView:AliyunPublishTopView!;
    var backgroundView:UIImageView!;
    var coverImageView:UIImageView!;
    var pickButton:UIButton!;
    var progressView:UIProgressView!;
    var publishProgressView:AliyunPublishProgressView!;
    var aliyunAuthorityChooseView:AliyunAuthorityChooseView!
    var publishContentEditView:AliyunPublishContentEditView!;
    var pulishButton:UIButton!;
    var saveToLocalButton:UIButton!;
    
    var finished:Bool = false;
    var failed:Bool = false;
    var image:UIImage?;
    
    var outputPath:String!;
    
    override var prefersStatusBarHidden: Bool{return true}
    /*可见权限*/
    var visiableType:VisibleChooseType = .all
    /*音乐信息*/
    var music_id:String?
    var music_start:String?
    var music_end:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotifications()
        self.setupSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupSubviews(){
        self.containerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.view.addSubview(self.containerView)

        // top
        self.topView = AliyunPublishTopView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: STATUS_BAR_HEIGHT+44))
        self.topView.nameLabel.isHidden = false;
        self.topView.nameLabel.text = "发布"
        self.topView.cancelButton.setImage(UIImage.init(named: "back"), for: UIControlState.normal)
        self.topView.cancelButton.setTitle(nil, for: .normal)
        self.topView.finishButton.setTitle("发布", for: .normal)
        self.topView.finishButton.isEnabled = false;
        self.topView.finishButton.isHidden = true;
        self.topView.delegate = self
        self.containerView.addSubview(self.topView)


        // middle
        let middleHeight = SCREEN_HEIGHT * (240.0/667);
        self.backgroundView = UIImageView.init(frame: CGRect.init(x: 0, y: STATUS_BAR_HEIGHT+44, width: SCREEN_WIDTH, height: middleHeight))
        self.backgroundView.image = self.backgroundImage;
        self.backgroundView.isUserInteractionEnabled = true;
        self.containerView.addSubview(self.backgroundView);
        
        let effect = UIBlurEffect.init(style: .light)
        let effectView = UIVisualEffectView.init(effect: effect)
        self.backgroundView.addSubview(effectView);
        effectView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: middleHeight);

        
        // pick
        let length = SCREEN_WIDTH*3/4.0;
        let ratio = self.outputSize.width/self.outputSize.height;
        var coverWidth:CGFloat = 0,coverHeight:CGFloat = 0;
        coverHeight = middleHeight;
        coverWidth = middleHeight*(SCREEN_WIDTH/SCREEN_HEIGHT)
//        if ratio > 1{
//            coverWidth = length;
//            coverHeight = coverWidth/ratio
//        }else{
//            coverHeight = length;
//            coverWidth = length * ratio;
//        }
        self.coverImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: coverWidth, height: coverHeight))
        self.coverImageView.center = CGPoint.init(x: SCREEN_WIDTH/2, y: middleHeight/2)
        self.coverImageView.isUserInteractionEnabled = true;
        effectView.contentView.addSubview(self.coverImageView);
        
        self.pickButton = UIButton.init(frame: CGRect.init(x: 0, y: coverHeight-36, width: coverWidth, height: 36))
        self.pickButton.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.5)
        self.pickButton.setTitleColor(UIColor.white, for: .normal);
        self.pickButton.setTitle("选择封面", for: .normal);
        self.pickButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.pickButton.addTarget(self, action: #selector(pickButtonClicked), for: .touchUpInside)
        self.coverImageView.addSubview(self.pickButton)
        self.coverImageView.isHidden = true;

        // progress
        self.publishProgressView = AliyunPublishProgressView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH))
        effectView.contentView.addSubview(self.publishProgressView);
        self.progressView = UIProgressView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 4))
        self.progressView.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.6)
        self.progressView.progressTintColor = RGBA(r: 127, g: 110, b: 241, a: 1)
        effectView.isUserInteractionEnabled = true;
        effectView.contentView.addSubview(self.progressView)
        
        

        // bottom
        self.publishContentEditView = AliyunPublishContentEditView.init(frame: CGRect.init(x: 0, y: STATUS_BAR_HEIGHT+44+middleHeight, width: SCREEN_WIDTH, height: 100))
        self.publishContentEditView.placeholder = "说点什么"
        self.publishContentEditView.maxCharacterNum = 30;
        self.containerView.addSubview(self.publishContentEditView)

        self.aliyunAuthorityChooseView = AliyunAuthorityChooseView.init(frame: CGRect.init(x: 0, y: self.publishContentEditView.frame.maxY+8, width: SCREEN_WIDTH, height: 56))
        self.aliyunAuthorityChooseView.rightInfoLabel.text = "所有人可见";
        self.containerView.addSubview(self.aliyunAuthorityChooseView);
        self.aliyunAuthorityChooseView.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAliyunAuthorityChooseView))
        self.aliyunAuthorityChooseView.addGestureRecognizer(tap)

        let pulishButtonWidth = SCREEN_WIDTH*(200.0/375);
        self.pulishButton = UIButton.init(frame: CGRect.init(x: SCREEN_WIDTH-pulishButtonWidth-15, y: SCREEN_HEIGHT-50-44, width: pulishButtonWidth, height: 44));
        self.pulishButton.backgroundColor = RGBA(r: 127, g: 110, b: 241, a: 1)
        self.pulishButton.layer.cornerRadius = 22;
        self.pulishButton.clipsToBounds = true;
        self.pulishButton.setTitle("发布", for: .normal)
        self.pulishButton.addTarget(self, action: #selector(pulishButtonClicked), for: .touchUpInside)
        self.pulishButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.containerView.addSubview(self.pulishButton)
        
        self.saveToLocalButton = UIButton.init(frame: CGRect.init(x: 84, y: SCREEN_HEIGHT-69-28, width: 28, height: 28))
        self.saveToLocalButton.setImage(UIImage.init(named: "btn_cbd"), for: .normal)
        self.saveToLocalButton.setTitle("存本地", for: .normal)
        self.saveToLocalButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.saveToLocalButton.titleLabel?.textColor = RGBA(r: 114, g: 114, b: 114, a: 1)
        self.saveToLocalButton.sizeToFitTitleBelowImageWith(distance: 8)
        self.saveToLocalButton.addTarget(self, action: #selector(saveToLocalButtonClicked), for: .touchUpInside)
        self.containerView.addSubview(self.saveToLocalButton)

        self.view.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
    }
    
    @objc func saveToLocalButtonClicked(){
        if !self.finished && !failed{
            Toast.showErrorWith(msg: "合成还未结束")
            return
        }

        Toast.showStatusWith(text: nil)
        PHPhotoLibrary.shared().performChanges({
            let fileURL = NSURL.fileURL(withPath: self.outputPath)
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }) { (isSuccess, error) in
            DispatchQueue.main.async {
                if isSuccess{
                    Toast.showSuccessWith(msg: "保存成功")
                }else{
                    Toast.showErrorWith(msg: "保存失败：\(error?.localizedDescription)")
                }
            }
        }
    }
    
    @objc func pickButtonClicked(){
        let vc = AliyunCoverPickViewController.init();
        vc.outputSize = self.outputSize;
        vc.videoPath = self.outputPath;
        vc.finishHandler = {(_image) in
            self.image = _image;
            self.coverImageView.image = _image;
            self.backgroundView.image = _image;
        }
        self.navigationController?.pushViewController(vc, animated: true);
    }

    
    @objc func tapAliyunAuthorityChooseView(){
        let visibleChooseController = AliyunVisibleChooseController.init()
        visibleChooseController.visibleType = .all;
        visibleChooseController.chooseTypeBlock = {type in
            self.visiableType = type
            if self.visiableType == .all{
                self.aliyunAuthorityChooseView.rightInfoLabel.text = "所有人可见";
            }
            if self.visiableType == .followers{
                self.aliyunAuthorityChooseView.rightInfoLabel.text = "粉丝可见";
            }
            if self.visiableType == .onlySelf{
                self.aliyunAuthorityChooseView.rightInfoLabel.text = "自己可见";
            }
        }
        self.navigationController?.pushViewController(visibleChooseController, animated: true)
    }
    
    @objc func pulishButtonClicked(){
        if !self.finished && !failed{
            Toast.showErrorWith(msg: "合成还未结束")
            return
        }
        self.requestCertificationWith { (uploadVideoCertificateModel) in
            let coverPath = NSString.init(string: self.taskPath).appendingPathComponent("cover.png");
            let data = UIImagePNGRepresentation(self.image!);
            do{
                try data?.write(to: URL.init(fileURLWithPath: coverPath))
            }catch{
                Toast.showErrorWith(msg: error.localizedDescription)
                return
            }
            let info = AliyunUploadSVideoInfo.init()
            info.title = "\(NSTimeIntervalSince1970).mp4"
            if let accessKeyId = uploadVideoCertificateModel.AccessKeyId,let accessKeySecret = uploadVideoCertificateModel.AccessKeySecret,let accessKeyToken = uploadVideoCertificateModel.SecurityToken{
                    AliyunPublishService.share().upload(withImagePath: coverPath, svideoInfo: info, accessKeyId: accessKeyId, accessKeySecret: accessKeySecret, accessToken: accessKeyToken)
            }
        }
    }

    //请求上传凭证
    func requestCertificationWith(completeBlock:@escaping ((UploadVideoCertificateModel)->Void)){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let shortVideoCreateUploadCertificate = ShortVideoCreateUploadCertificate()
        _ = moyaProvider.rx.request(.targetWith(target: shortVideoCreateUploadCertificate)).subscribe(onSuccess: { (response) in
            let uploadVideoCertificateModel = Mapper<UploadVideoCertificateModel>().map(jsonData: response.data)
            if uploadVideoCertificateModel?.commonInfoModel?.status == successState{
                completeBlock(uploadVideoCertificateModel!)
            }else{
                Toast.showErrorWith(model: uploadVideoCertificateModel)
            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    //发布到服务器
    func pulishToServerWith(title:String?,videoId:String,viewAuth:Int,videoCover:String?){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let publishVideo = PublishVideo.init(title: title, video_addr: videoId, view_auth: viewAuth, video_cover: videoCover, music_id: self.music_id, music_start: self.music_start, music_end: self.music_end)
       // let publishVideo = PublishVideo.init(title: title, video_addr: videoId, view_auth: viewAuth, video_cover: videoCover)
        _ = moyaProvider.rx.request(.targetWith(target: publishVideo)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                Toast.showSuccessWith(msg: "发布成功!")
                //延时1秒返回主界面
                let delayTime : TimeInterval = 1.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                    Toast.dismiss()
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }else{
                Toast.showErrorWith(model: baseModel)
            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.finished{
            do{
                if FileManager.default.fileExists(atPath: AliyunPathManager.createExportDir()){
                    try FileManager.default.removeItem(atPath: AliyunPathManager.createExportDir())
                }
                try FileManager.default.createDirectory(atPath: AliyunPathManager.createExportDir(), withIntermediateDirectories: true, attributes: nil)
                let outputTaskPath = NSString.init(string: AliyunPathManager.createExportDir())
                let outputPath = outputTaskPath.appendingPathComponent(NSString.init(string: AliyunPathManager.uuidString()).appendingPathExtension("mp4")!)
                self.outputPath = outputPath
                AliyunPublishService.share().exportCallback = self;
                AliyunPublishService.share().uploadCallback = self;
                AliyunPublishService.share().export(withTaskPath: self.taskPath, outputPath: self.outputPath)
            }catch{
                Toast.showErrorWith(msg: error.localizedDescription)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    deinit {
        self.removeNotifications()
    }
    
    func removeNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //pragma mark - notification
    func addNotifications(){
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(notification:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    @objc func keyboardWillShow(notification:Notification){
        let end = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Float
        let containerHeight = STATUS_BAR_HEIGHT+44+SCREEN_WIDTH+52+22
        let offset = SCREEN_HEIGHT -  end.size.height - containerHeight
        if offset < 0{
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.containerView.frame = CGRect.init(x: 0, y: offset, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            }
        }
    }
    @objc func keyboardWillHidden(notification:Notification){
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Float
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.containerView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT);
        }
    }

    @objc func applicationDidBecomeActive(){
        if !self.finished && !self.failed {
            AliyunPublishService().export(withTaskPath: self.taskPath, outputPath: self.outputPath)
        }
    }
    
    //pragma mark - util
    func thumbnailWithVideoPath(videoPath:String,outputSize:CGSize)->UIImage{
        let asset = AVURLAsset.init(url: URL.init(fileURLWithPath: videoPath));
        let generator = AVAssetImageGenerator.init(asset: asset);
        generator.maximumSize = outputSize;
        generator.appliesPreferredTrackTransform = true;
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        let time = CMTime.init(value: 0*1000, timescale: 1000);
        var image:CGImage!
        do{
            image = try generator.copyCGImage(at: time, actualTime: nil);
        }catch{
            Toast.showErrorWith(msg: error.localizedDescription)
        }
        let picture = UIImage.init(cgImage: image)
        return picture;
    }

}

extension PulishViewController:AliyunIExporterCallback{
    func exportProgress(_ progress: Float) {
        self.progressView.setProgress(progress, animated: true)
        self.publishProgressView.setProgress(CGFloat(progress))
    }

    func exporterDidCancel() {
        print("export cancel")
        self.navigationController?.popViewController(animated: true)
    }
    
    func exporterDidStart() {
        
    }
    
    func exportError(_ errorCode: Int32) {
        self.publishProgressView.markAsFailed()
        Toast.showErrorWith(msg: "合成失败:\(errorCode)")
    }

    func exporterDidEnd(_ outputPath: String!) {
        self.finished = true;
        self.progressView.isHidden = true;
        self.topView.finishButton.isEnabled = true;
        self.image = self.thumbnailWithVideoPath(videoPath: self.outputPath, outputSize: self.outputSize)
        self.publishProgressView.markAsFinihed()
        self.coverImageView.image = self.image;
        self.backgroundView.image = self.image;
        self.coverImageView.isHidden = false;
        self.publishProgressView.isHidden = true;
    }

    
}

extension PulishViewController:AliyunPublishTopViewDelegate{
    func cancelButtonClicked() {
        if !self.finished && !failed{
            let alertController = UIAlertController.init(title: "返回编辑后将不再合成", message: nil, preferredStyle: .alert);
            let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            let actionCofirm = UIAlertAction.init(title: "确定", style: .default) { (_) in
                AliyunPublishService.share().cancelExport()
                //self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(actionCancel)
            alertController.addAction(actionCofirm)
            self.present(alertController, animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func finishButtonClicked() {

    }
    
}

extension PulishViewController:AliyunIUploadCallback{
    func uploadProgress(withUploadedSize uploadedSize: Int64, totalSize: Int64) {
        let progress = Float(uploadedSize)/Float(totalSize)*100
        print("上传进度：\(progress)%")
        DispatchQueue.main.async {
            Toast.showStatusWith(text: "上传进度:\(Int(progress))%")
        }

    }
    
    func uploadTokenExpired() {
        
        self.requestCertificationWith { (uploadVideoCertificateModel) in
            if let accessKeyId = uploadVideoCertificateModel.AccessKeyId,let accessKeySecret = uploadVideoCertificateModel.AccessKeySecret,let accessKeyToken = uploadVideoCertificateModel.SecurityToken,let expireTime = uploadVideoCertificateModel.Expiration{
//                AliyunPublishService.share().cancelUpload()
                AliyunPublishService.share().refresh(withAccessKeyId: accessKeyId, accessKeySecret: accessKeySecret, accessToken: accessKeyToken, expireTime: expireTime)
                //AliyunPublishService.share().upload(withImagePath: coverPath, svideoInfo: info, accessKeyId: accessKeyId, accessKeySecret: accessKeySecret, accessToken: accessKeyToken)
            }
        }
    }
    
    func uploadFailed(withCode code: String!, message: String!) {
        DispatchQueue.main.async {
            Toast.showErrorWith(msg: "上传失败：\ncode:\(code)\nmessage:\(message)")
        }
    }
    
    func uploadSuccess(withVid vid: String!, imageUrl: String!) {
        print("上传成功")
        
        self.pulishToServerWith(title: self.publishContentEditView.content, videoId: vid, viewAuth: self.visiableType.rawValue, videoCover: imageUrl)
    }
    
    func uploadRetry() {
        
    }
    
    func uploadRetryResume() {
        
    }
}



