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
import SwiftyJSON

class CreatTopicController: UIViewController {
    var releaseBtn:UIButton!
    var releaseContentTextInputCell:ReleaseContentTextInputCell!
    var releaseContentImgInputCell:ReleaseContentImgInputCell!
    var imgArr = [LocalMediaModel]()
    var videoArr = [LocalMediaModel]()
    var imagePickerVc:TZImagePickerController?
    var qnUploadManager:QNUploadManager!
    var phAsset:PHAsset?
    var topicCircleId:Int?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加话题"
        let navigationBarTitleAttributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = navigationBarTitleAttributes
        
        self.tableView.estimatedRowHeight = 1000

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
        self.releaseContentTextInputCell.textChangeBlock = {[unowned self] _ in
            self.RefreshReleasBtnEnable()
        }
        self.releaseContentImgInputCell = ReleaseContentImgInputCell()
        self.releaseContentImgInputCell.selectionStyle = .none
        self.releaseContentImgInputCell.addImgBlock = {[unowned self] in
            if self.videoArr.count >= 1{
                Toast.showInfoWith(text:"最多选择一个视频")
                return
            }
            self.imagePickerVc = TZImagePickerController.init(maxImagesCount: 1, delegate: self)
            self.imagePickerVc?.autoDismiss = false
            self.imagePickerVc?.allowPickingVideo = false
            self.imagePickerVc?.imagePickerControllerDidCancelHandle = {[unowned self] in
                self.imagePickerVc?.dismiss(animated: true, completion: nil)
            }
            self.imagePickerVc?.didFinishPickingPhotosHandle = {[unowned self] (photos,assets,isOriginal) in
                self.uploadImagesWith(images: photos, phAssets: assets as? [PHAsset])
            }
            self.imagePickerVc?.didFinishPickingVideoHandle = {[unowned self] (img,other) in
                self.uploadVideoWith(phAsset: other as? PHAsset, preImg: img)
            }
            self.present(self.imagePickerVc!, animated: true, completion: nil)
        }
        self.releaseContentImgInputCell.deleteImgBlock = {[unowned self] (index) in
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
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]

    }
    
    deinit {
        print("创建话题界面销毁")
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
        Toast.showStatusWith(text: nil)
        self.releaseContentTextInputCell.contentText.resignFirstResponder()
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let picUrl = self.generateMediaParameterWith(medias: self.imgArr)
        let image = self.imgArr.first?.image
        let picInfo = ["url":picUrl,"width":image?.size.width,"height":image?.size.height] as [String : Any]
        var pic:String? = ""
        if let data = try? JSONSerialization.data(withJSONObject: picInfo, options: .prettyPrinted){
            pic = String.init(data: data, encoding: String.Encoding.utf8)
        }
        let addTopicAction = AddTopicAction(pic: pic, topic_id: self.topicCircleId, content: self.releaseContentTextInputCell.contentText.text)
        _ = moyaProvider.rx.request(.targetWith(target: addTopicAction)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                NotificationCenter.default.post(name: POST_TOPIC_SUCCESS_NOTIFICATION, object: nil, userInfo: nil)
                //延时1秒执行
                let delayTime : TimeInterval = 1.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                    self.dismiss(animated: true, completion: {
                        Toast.dismiss()
                    })
                }
            }
            Toast.showResultWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
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
    
    func uploadImagesWith(images:[UIImage]?,phAssets:[PHAsset]?){
        self.videoArr.removeAll()
        self.imgArr.removeAll()
        Toast.showStatusWith(text: "正在上传...")
        FileUploadManager.share.uploadImagesWith(images: images, phAssets: phAssets, successBlock: { (image, key) in
            var localMediaModel = LocalMediaModel.init()
            localMediaModel.key = key
            localMediaModel.image = image
            self.imgArr.append(localMediaModel)
        }, failedBlock: {
            self.tableView.reloadData()
            Toast.showErrorWith(msg: "上传图片失败")
        }, completionBlock: {
            Toast.dismiss()
            self.imagePickerVc?.dismiss(animated: true, completion: nil)
            self.tableView.reloadData()
            self.RefreshReleasBtnEnable()
        }, tokenIDModel: nil)
    }
    
    //上传视频
    func uploadVideoWith(phAsset:PHAsset?,preImg:UIImage?){
        self.videoArr.removeAll()
        self.imgArr.removeAll()
        Toast.showStatusWith(text: "正在上传...")
        FileUploadManager.share.uploadVideoWith(preImage: preImg, phAsset: phAsset, successBlock: { (image, fileKey) in
            var localMediaModel = LocalMediaModel.init()
            localMediaModel.key = fileKey
            localMediaModel.image = preImg
            self.videoArr.append(localMediaModel)
        }, failedBlock: {
            self.tableView.reloadData()
            Toast.showErrorWith(msg: "上传视频失败")
        }, completionBlock: {
            Toast.dismiss()
            self.imagePickerVc?.dismiss(animated: true, completion: nil)
            self.tableView.reloadData()
            self.RefreshReleasBtnEnable()
        }, tokenIDModel: nil)
        
//        GetQiNiuUploadToken(type: .video, onSuccess: { (qnUploadToken) in
//            if let _token = qnUploadToken?.token{
//                Toast.showStatusWith(text: nil)
//                let progressBlock:QNUpProgressHandler = {[unowned self] (str,flo) in
//                    //Toast.showProgress(flo)
//                }
//                let option = QNUploadOption(mime: "", progressHandler: progressBlock, params: ["":""], checkCrc: false, cancellationSignal: { () -> Bool in
//                    return false
//                })
//                let fileName = uploadFileName(type: .video)
//                self.qnUploadManager.put(self.phAsset, key: fileName, token: _token, complete: { (responseInfo, str, dic) in
//                    if let _error = responseInfo?.error{
//                        Toast.showErrorWith(msg: _error.localizedDescription)
//                    }else{
//                        var localMediaModel = LocalMediaModel.init()
//                        localMediaModel.key = str
//                        localMediaModel.image = preImg
//                        self.videoArr.append(localMediaModel)
//                        Toast.dismiss()
//                        self.imagePickerVc?.dismiss(animated: true, completion: nil)
//                        self.tableView.reloadData()
//                        self.RefreshReleasBtnEnable()
//                    }
//                }, option: option)
//            }
//        }, id: nil, token: nil)
    }
    
    func generateMediaParameterWith(medias:[LocalMediaModel])->String{
        var str = ""
        for media in medias{
            if let imgName = media.key{
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
