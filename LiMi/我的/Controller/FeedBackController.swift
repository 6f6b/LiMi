//
//  FeedBackController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import TZImagePickerController
import QiniuUpload
import Qiniu
import Moya
import ObjectMapper

class FeedBackController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}

    @IBOutlet weak var tableView: UITableView!
    var feedBackQuestionCategoryCell:FeedBackQuestionCategoryCell!
    var releaseContentTextInputCell:ReleaseContentTextInputCell!
    var releaseContentImgInputCell:ReleaseContentImgInputCell!
    var contactWayInputCell:ContactWayInputCell!
    var submitFeedbackCell:SubmitFeedbackCell!
    var imgArr = [LocalMediaModel]()
    var videoArr = [LocalMediaModel]()
    var feedbackQuestionModels:[FeedBackQuestionModel]!
    var selectedFeedBackQuestionModel:FeedBackQuestionModel?
    var imagePickerVc:TZImagePickerController?
    var qnUploadManager:QNUploadManager!
    var phAsset:PHAsset?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "用户反馈"
        
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
        
        //问题分类
        let feedBackQuestionModel1 = FeedBackQuestionModel(type: 1, info: "功能问题", isSelect: false)
        let feedBackQuestionModel2 = FeedBackQuestionModel(type: 2, info: "性能问题", isSelect: false)
        let feedBackQuestionModel3 = FeedBackQuestionModel(type: 3, info: "其他问题", isSelect: false)
        self.feedbackQuestionModels = [feedBackQuestionModel1,feedBackQuestionModel2,feedBackQuestionModel3]
        self.feedBackQuestionCategoryCell = FeedBackQuestionCategoryCell()
        self.feedBackQuestionCategoryCell.tapBlock = {[unowned self] (feedBackQuestionModel) in
            self.selectedFeedBackQuestionModel = feedBackQuestionModel
        }
        self.feedBackQuestionCategoryCell.congfigWith(models: self.feedbackQuestionModels)
        
        //问题内容
        self.releaseContentTextInputCell = GET_XIB_VIEW(nibName: "ReleaseContentTextInputCell") as! ReleaseContentTextInputCell
        self.releaseContentTextInputCell.placeHolder.text = "请输入遇到的问题"
        self.releaseContentTextInputCell.selectionStyle = .none
        self.releaseContentTextInputCell.textChangeBlock = {[unowned self] _ in
            self.RefreshSubmitBtnEnable()
        }
        //图片
        self.releaseContentImgInputCell = ReleaseContentImgInputCell()
        self.releaseContentImgInputCell.selectionStyle = .none
        self.releaseContentImgInputCell.addImgBlock = {[unowned self] in
            if self.videoArr.count >= 1{
                Toast.showInfoWith(text:"最多选择一个视频")
                return
            }
            self.imagePickerVc = TZImagePickerController.init(maxImagesCount: 9-self.imgArr.count, delegate: self)
            self.imagePickerVc?.autoDismiss = false
            self.imagePickerVc?.imagePickerControllerDidCancelHandle = {[unowned self] in
                self.imagePickerVc?.dismiss(animated: true, completion: nil)
            }
            if self.imgArr.count > 0{self.imagePickerVc?.allowPickingVideo = false}
            self.imagePickerVc?.didFinishPickingPhotosHandle = {[unowned self] (photos,assets,isOriginal) in
                self.uploadImageWith(images: photos, phAssets: assets as! [PHAsset]?)
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
        //联系方式
        self.contactWayInputCell = GET_XIB_VIEW(nibName: "ContactWayInputCell") as! ContactWayInputCell
        
        //提交cell
        self.submitFeedbackCell = GET_XIB_VIEW(nibName: "SubmitFeedbackCell") as! SubmitFeedbackCell
        self.submitFeedbackCell.submitBlock = {[unowned self] in
            let imgs = self.generateMediaParameterWith(medias: self.imgArr)

            let feedBack = FeedBack(type: self.selectedFeedBackQuestionModel?.type, info: self.releaseContentTextInputCell.contentText.text, pic: imgs, phone: self.contactWayInputCell.contactInfo.text)
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
//            let imgs = self.generateMediaParameterWith(medias: self.imgArr)
//            let video = self.generateMediaParameterWith(medias: self.videoArr)
            _ = moyaProvider.rx.request(.targetWith(target: feedBack)).subscribe(onSuccess: { (response) in
                let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
                if resultModel?.commonInfoModel?.status == successState{
                    //延时1秒执行
                    let delayTime: TimeInterval = 1.0
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                        Toast.dismiss()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                Toast.showResultWith(model: resultModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }
        
        self.tableView.estimatedRowHeight = 1000
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //国内https上传
        let qnConfig = QNConfiguration.build { (builder) in
            builder?.setZone(QNFixedZone.zone0())
        }
        self.qnUploadManager = QNUploadManager(configuration: qnConfig)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.shared.statusBarStyle = .default
//        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
//        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
//        self.navigationController?.navigationBar.tintColor = UIColor.white
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }
    
    deinit {
        print("反馈销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    func RefreshSubmitBtnEnable(){
//        if !IsEmpty(textView: self.releaseContentTextInputCell.contentText) || self.imgArr.count != 0 || self.videoArr.count != 0{
//            self.makeReleaseBtn(isEnable: true)
//        }else{
//            self.makeReleaseBtn(isEnable: false)
//        }
    }
    
    func uploadImageWith(images:[UIImage]?,phAssets:[PHAsset]?){
        //上传图片
        self.videoArr.removeAll()
        Toast.showStatusWith(text: "正在上传..")
        FileUploadManager.share.uploadImagesWith(images: images, phAssets: phAssets, successBlock: { (image, key) in
            var localMediaModel = LocalMediaModel.init()
            localMediaModel.key = key
            localMediaModel.image = image
            self.imgArr.append(localMediaModel)
            print("imageWidth:\(image.size.width)--imageHeight:\(image.size.height)--key:\(key)")
        }, failedBlock: {
            
        }, completionBlock: {
            Toast.dismiss()
            self.imagePickerVc?.dismiss(animated: true, completion: nil)
            self.tableView.reloadData()
            self.RefreshSubmitBtnEnable()
        }, tokenIDModel: nil)
    }
    
    func uploadVideoWith(phAsset:PHAsset?,preImg:UIImage?){
        //上传视频
        self.imgArr.removeAll()
            Toast.showStatusWith(text: "正在上传..")
            FileUploadManager.share.uploadVideoWith(preImage: preImg, phAsset: phAsset, successBlock: { (image, key) in
                var localMediaModel = LocalMediaModel.init()
                localMediaModel.key = key
                localMediaModel.image = preImg
                self.videoArr.append(localMediaModel)
                Toast.dismiss()
                self.imagePickerVc?.dismiss(animated: true, completion: nil)
            }, failedBlock: {
                
            }, completionBlock: {
                self.tableView.reloadData()
                self.RefreshSubmitBtnEnable()
            })
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

extension FeedBackController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let feedBackHeaderView = FeedBackHeaderView()
        if section == 0{feedBackHeaderView.infoLabel.text = "问题分类"}
        if section == 1{feedBackHeaderView.infoLabel.text = "问题描述"}
        if section == 2{feedBackHeaderView.infoLabel.text = "联系方式"}
        if section == 3{
            let view = UIView()
            view.backgroundColor = UIColor.groupTableViewBackground
            return view
        }
        return feedBackHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3{
            return 60
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            return self.feedBackQuestionCategoryCell
        }
        if indexPath.section == 1{
            if indexPath.row == 0{
                return self.releaseContentTextInputCell
            }
            if indexPath.row == 1{
                let source = self.imgArr.count != 0 ? self.imgArr : self.videoArr
                self.releaseContentImgInputCell.configWith(imgArry: source)
                return self.releaseContentImgInputCell
            }
        }
        if indexPath.section == 2{
            return self.contactWayInputCell
        }
        if indexPath.section == 3{
            return self.submitFeedbackCell
        }
        return UITableViewCell()
    }
}

extension FeedBackController:TZImagePickerControllerDelegate{
    
}
