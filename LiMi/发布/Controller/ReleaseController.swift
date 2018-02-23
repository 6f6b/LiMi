//
//  ReleaseController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import TZImagePickerController
import SVProgressHUD
import Moya
import ObjectMapper
import Qiniu
import QiniuUpload

enum MediaType {
    case picture
    case video
}

class ReleaseController: ViewController {
    var releaseBtn:UIButton!
    var tableView:UITableView!
    var releaseContentTextInputCell:ReleaseContentTextInputCell!
    var releaseContentImgInputCell:ReleaseContentImgInputCell!
    var releaseContentTagInputCell:ReleaseContentOtherInputCell!
    var releaseContentRedBagInputCell:ReleaseContentOtherInputCell!
    var imgArr = [LocalMediaModel]()
    var videoArr = [LocalMediaModel]()
    var imagePickerVc:TZImagePickerController?
    var skillModel:SkillModel?
    var qnUploadManager:QNUploadManager!
    var phAsset:PHAsset?
    var sendRedpacketResultModel:SendRedPacketResultModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新动态"
        let navigationBarTitleAttributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = navigationBarTitleAttributes
        
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
        
        self.tableView = UITableView(frame: self.view.bounds)
        self.view.addSubview(self.tableView)
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 100
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
            self.imagePickerVc = TZImagePickerController.init(maxImagesCount: 9-self.imgArr.count, delegate: self)
            self.imagePickerVc?.autoDismiss = false
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
        self.releaseContentTagInputCell = GET_XIB_VIEW(nibName: "ReleaseContentOtherInputCell") as! ReleaseContentOtherInputCell
        self.releaseContentTagInputCell.selectionStyle = .none
        self.releaseContentTagInputCell.leftLabel.text = "添加标签"
        self.releaseContentTagInputCell.leftImgV.image = UIImage.init(named: "fb_icon_bq")
        self.releaseContentTagInputCell.rightLabel.text = nil
        self.releaseContentRedBagInputCell = GET_XIB_VIEW(nibName: "ReleaseContentOtherInputCell") as! ReleaseContentOtherInputCell
        self.releaseContentRedBagInputCell.selectionStyle = .none
        self.releaseContentRedBagInputCell.leftLabel.text = "打赏红包"
        self.releaseContentRedBagInputCell.leftImgV.image = UIImage.init(named: "fb_icon_hb")
        self.releaseContentRedBagInputCell.rightLabel.text = nil
        
        //国内https上传
        let qnConfig = QNConfiguration.build { (builder) in
            builder?.setZone(QNFixedZone.zone0())
        }
        self.qnUploadManager = QNUploadManager(configuration: qnConfig)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        super.viewWillDisappear(animated)
    }

    //MARK: - misc
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
    
    @objc func dealCancel(){
        if let _red_token = self.sendRedpacketResultModel?.red_token{
            let alterController = UIAlertController.init(title: nil, message: "取消发布动态后，红包将退还至你的现金中", preferredStyle: .alert)
            let actionOK = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
                let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
                let cancelReleaseTrends = CancelDynamic(red_token: _red_token)
                _ = moyaProvider.rx.request(.targetWith(target: cancelReleaseTrends)).subscribe(onSuccess: { (response) in
                    let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
                    HandleResultWith(model: resultModel)
                    if resultModel?.commonInfoModel?.status == successState{
                        self.dismiss(animated: true, completion: nil)
                    }
                    SVProgressHUD.showErrorWith(model: resultModel)
                }, onError: { (error) in
                    SVProgressHUD.showErrorWith(msg: error.localizedDescription)
                })
            })
            let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            alterController.addAction(actionOK)
            alterController.addAction(actionCancel)
            self.present(alterController, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dealRelease(){
        self.releaseContentTextInputCell.contentText.resignFirstResponder()
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let imgs = self.generateMediaParameterWith(medias: self.imgArr)
        let video = self.generateMediaParameterWith(medias: self.videoArr)
        let releaseTrends = ReleaseTrends(red_token: self.sendRedpacketResultModel?.red_token ,skill_id: self.skillModel?.id, content: self.releaseContentTextInputCell.contentText.text, images: imgs, video: video)
        _ = moyaProvider.rx.request(.targetWith(target: releaseTrends)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            HandleResultWith(model: resultModel)
            if resultModel?.commonInfoModel?.status == successState{
                NotificationCenter.default.post(name: POST_TREND_SUCCESS_NOTIFICATION, object: nil, userInfo: nil)
                //延时1秒执行
                let time: TimeInterval = 1
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
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
}

//MARK: - UITableViewDelegate、UITableViewDataSource
extension ReleaseController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{return 7}
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                return self.releaseContentTextInputCell
            }
            if indexPath.row == 1{
                let source = self.imgArr.count != 0 ? self.imgArr : self.videoArr
                self.releaseContentImgInputCell.configWith(imgArry: source)
                return self.releaseContentImgInputCell
            }
        }
        if indexPath.section == 1{
            if indexPath.row == 0{
                return self.releaseContentTagInputCell
            }
            if indexPath.row == 1{
                return self.releaseContentRedBagInputCell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            if indexPath.row == 0{
                let tagListView = TagListView(frame: SCREEN_RECT)
                tagListView.selectTagBlock = {(skillModel) in
                    self.skillModel = skillModel
                    self.releaseContentTagInputCell.rightLabel.text = skillModel?.skill
                }
                UIApplication.shared.keyWindow?.addSubview(tagListView)
            }
            if indexPath.row == 1{
                let rewardRedPacketController = RewardRedPacketController()
                rewardRedPacketController.sentRedPacketSuccessBlock = {(money,sendRedPacketResultModel) in
                    self.sendRedpacketResultModel = sendRedPacketResultModel
                    self.releaseContentRedBagInputCell.rightLabel.text = money.decimalValue() + "元"
                }
                self.navigationController?.pushViewController(rewardRedPacketController, animated: true)
            }
        }
    }
    
}

extension ReleaseController:TZImagePickerControllerDelegate{
    
}
