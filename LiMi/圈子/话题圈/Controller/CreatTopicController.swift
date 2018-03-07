//
//  CreatTopicController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import TZImagePickerController
import SVProgressHUD
import QiniuUpload
import Qiniu
import Moya
import ObjectMapper

class CreatTopicController: ViewController {
    var releaseBtn:UIButton!
    var releaseContentTextInputCell:ReleaseContentTextInputCell!
    var releaseContentImgInputCell:ReleaseContentImgInputCell!
    var imgArr = [LocalMediaModel]()
    var videoArr = [LocalMediaModel]()
    var imagePickerVc:TZImagePickerController?
    var qnUploadManager:QNUploadManager!
    var phAsset:PHAsset?
    var topicCircleModel:TopicCircleModel?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加话题"
        let navigationBarTitleAttributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = navigationBarTitleAttributes
        
        self.tableView.estimatedRowHeight = 100
        
        let cancelBtn = UIButton.init(type: .custom)
        let cancelAttributeTitle = NSAttributedString.init(string: "取消", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)])
        cancelBtn.setAttributedTitle(cancelAttributeTitle, for: .normal)
        cancelBtn.sizeToFit()
        cancelBtn.addTarget(self, action: #selector(dealCancel), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: cancelBtn)
        
        
        let releaseBtn = UIButton.init(type: .custom)
        releaseBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 25)
        self.releaseBtn = releaseBtn
        self.releaseBtn.layer.cornerRadius = 3
        self.releaseBtn.clipsToBounds = true
        self.makeReleaseBtn(isEnable: false)
        releaseBtn.addTarget(self, action: #selector(dealRelease), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: releaseBtn)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.releaseContentTextInputCell = GET_XIB_VIEW(nibName: "ReleaseContentTextInputCell") as! ReleaseContentTextInputCell
        self.releaseContentTextInputCell.selectionStyle = .none
        self.releaseContentTextInputCell.textChangeBlock = {_ in
            self.RefreshReleasBtnEnable()
        }
        self.releaseContentImgInputCell = ReleaseContentImgInputCell()
        self.releaseContentImgInputCell.selectionStyle = .none
        self.releaseContentImgInputCell.addImgBlock = {
            if self.videoArr.count >= 1{
                SVProgressHUD.showInfo(withStatus: "最多选择一个视频")
                return
            }
            self.imagePickerVc = TZImagePickerController.init(maxImagesCount: 1-self.imgArr.count, delegate: self)
            self.imagePickerVc?.autoDismiss = false
            self.imagePickerVc?.allowPickingVideo = false
            self.imagePickerVc?.imagePickerControllerDidCancelHandle = {
                self.imagePickerVc?.dismiss(animated: true, completion: nil)
            }
            if self.imgArr.count > 0{self.imagePickerVc?.allowPickingVideo = false}
            self.imagePickerVc?.didFinishPickingPhotosHandle = {(photos,assets,isOriginal) in
                self.videoArr.removeAll()
                self.uploadImgsWith(imgs: photos)
                self.tableView.reloadData()
                self.RefreshReleasBtnEnable()
            }
            self.imagePickerVc?.didFinishPickingVideoHandle = {(img,other) in
                self.imgArr.removeAll()
                self.uploadVideoWith(phAsset: other as? PHAsset, preImg: img)
                self.tableView.reloadData()
                self.RefreshReleasBtnEnable()
            }
            self.present(self.imagePickerVc!, animated: true, completion: nil)
        }
        self.releaseContentImgInputCell.deleteImgBlock = {(index) in
            if self.imgArr.count != 0{
                self.imgArr.remove(at: index)
            }else{
                self.videoArr.remove(at: index)
            }
            self.tableView.reloadData()
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    @objc func dealCancel(){
        self.dismiss(animated: true, completion: nil)
    }

    @objc func dealRelease(){
//        pic    只能上传保存一张图片    是    [string]
//        topic_id    话题id    是    [int]
//        content
        self.releaseContentTextInputCell.contentText.resignFirstResponder()
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let pic = self.generateMediaParameterWith(medias: self.imgArr)
        let addTopicAction = AddTopicAction(pic: pic, topic_id: self.topicCircleModel?.id, content: self.releaseContentTextInputCell.contentText.text)
        _ = moyaProvider.rx.request(.targetWith(target: addTopicAction)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                NotificationCenter.default.post(name: POST_TOPIC_SUCCESS_NOTIFICATION, object: nil, userInfo: nil)
                //延时1秒执行
                let delayTime : TimeInterval = 1.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                    self.dismiss(animated: true, completion: {
                        SVProgressHUD.dismiss()
                    })
                }
            }
            SVProgressHUD.showResultWith(model: resultModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }

    func RefreshReleasBtnEnable(){
        if !IsEmpty(textView: self.releaseContentTextInputCell.contentText) || self.imgArr.count != 0 || self.videoArr.count != 0{
            self.makeReleaseBtn(isEnable: true)
        }else{
            self.makeReleaseBtn(isEnable: false)
        }
    }
    
    func makeReleaseBtn(isEnable:Bool){
        if isEnable{
            releaseBtn.backgroundColor = UIColor.white
            let releaseBtnAttributeTitle = NSAttributedString.init(string: "发送", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)])
            releaseBtn.setAttributedTitle(releaseBtnAttributeTitle, for: .normal)
        }
        if !isEnable{
            releaseBtn.backgroundColor = RGBA(r: 240, g: 240, b: 240, a: 1)
            let releaseBtnAttributeTitle = NSAttributedString.init(string: "发送", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 184, g: 184, b: 184, a: 1)])
            releaseBtn.setAttributedTitle(releaseBtnAttributeTitle, for: .normal)
        }
        releaseBtn.isUserInteractionEnabled = isEnable
    }
    
    func uploadImgsWith(imgs:[UIImage?]?){
        GetQiNiuUploadToken(type: .picture, onSuccess: { (tokenModel) in
            if let _token = tokenModel?.token{
                var files = [QiniuFile]()
                if let  _imgs = imgs{
                    for img in _imgs{
                        let filePath = GenerateImgPathlWith(img: img)
                        let file = QiniuFile.init(path: filePath!)
                        file?.key = uploadFileName(type: .picture)
                        files.append(file!)
                    }
                    let uploader = QiniuUploader.sharedUploader() as! QiniuUploader
                    uploader.maxConcurrentNumber = 3
                    uploader.files = files
                    SVProgressHUD.show(withStatus: "处理中")
                    uploader.startUpload(_token, uploadOneFileSucceededHandler: { (index, dic) in
                        let imgName = dic["key"] as? String
                        var localMediaModel = LocalMediaModel.init()
                        localMediaModel.imgName = imgName
                        localMediaModel.img = imgs![index]
                        self.imgArr.append(localMediaModel)
                        print("successIndex\(index)")
                        print("successDic\(dic)")
                    }, uploadOneFileFailedHandler: { (index, error) in
                        print("failedIndex\(index)")
                        print("error:\(error?.localizedDescription)")
                    }, uploadOneFileProgressHandler: { (index, bytesSent, totalBytesSent, totalBytesExpectedToSend) in
                        print("index:\(index),percent:\(Float(totalBytesSent/totalBytesExpectedToSend))")
                    }, uploadAllFilesComplete: {
                        print("uploadOver")
                        SVProgressHUD.dismiss()
                        self.imagePickerVc?.dismiss(animated: true, completion: nil)
                        self.tableView.reloadData()
                        self.RefreshReleasBtnEnable()
                    })
                }
            }
        }, id: nil, token: nil)
    }
    
    //上传视频
    func uploadVideoWith(phAsset:PHAsset?,preImg:UIImage?){
        self.phAsset = phAsset
        GetQiNiuUploadToken(type: .video, onSuccess: { (qnUploadToken) in
            if let _token = qnUploadToken?.token{
                SVProgressHUD.setStatus(nil)
                let progressBlock:QNUpProgressHandler = {(str,flo) in
                    SVProgressHUD.showProgress(flo)
                }
                let option = QNUploadOption(mime: "", progressHandler: progressBlock, params: ["":""], checkCrc: false, cancellationSignal: { () -> Bool in
                    return false
                })
                let fileName = uploadFileName(type: .video)
                self.qnUploadManager.put(self.phAsset, key: fileName, token: _token, complete: { (responseInfo, str, dic) in
                    if let _error = responseInfo?.error{
                        SVProgressHUD.showErrorWith(msg: _error.localizedDescription)
                    }else{
                        var localMediaModel = LocalMediaModel.init()
                        localMediaModel.imgName = str
                        localMediaModel.img = preImg
                        self.videoArr.append(localMediaModel)
                        SVProgressHUD.dismiss()
                        self.imagePickerVc?.dismiss(animated: true, completion: nil)
                        self.tableView.reloadData()
                        self.RefreshReleasBtnEnable()
                    }
                }, option: option)
            }
        }, id: nil, token: nil)
    }
    
    func generateMediaParameterWith(medias:[LocalMediaModel])->String{
        var str = ""
        for media in medias{
            if let imgName = media.imgName{
                str += "/" + imgName
                str += ","
            }
        }
        if str.lengthOfBytes(using: String.Encoding.utf8) > 1{
            str.removeLast()
        }
        return str
    }
}

extension CreatTopicController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            return self.releaseContentTextInputCell
        }else{
            let source = self.imgArr.count != 0 ? self.imgArr : self.videoArr
            self.releaseContentImgInputCell.configWith(imgArry: source)
            return self.releaseContentImgInputCell
        }
    }
}

extension CreatTopicController:TZImagePickerControllerDelegate{
    
}
