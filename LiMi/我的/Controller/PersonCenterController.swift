//
//  PersonCenterController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/10.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import Moya
import ObjectMapper
import SVProgressHUD
import Kingfisher
import TZImagePickerController
import MobileCoreServices

class PersonCenterController: UITableViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var coverView: UIView!
    //背景图
    @IBOutlet weak var backImageView: UIImageView!
    //头像
    @IBOutlet weak var headImgBtn: UIButton!
    //昵称
    @IBOutlet weak var nickName: UILabel!
    //性别
    @IBOutlet weak var sexImg: UIImageView!

    //认证状态
    @IBOutlet weak var authenticationState: UILabel!
    
    //个性签名
    @IBOutlet weak var signature: UILabel!
    //关注
    @IBOutlet weak var follows: UILabel!
    //粉丝
    @IBOutlet weak var followers: UILabel!
    //收获的点赞
    @IBOutlet weak var beLikedNum: UILabel!
    
    @IBOutlet weak var logOutBtn: UIButton!
    
    var userInfoModel:UserInfoModel?
    var imagePickerVc:TZImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 1000
        self.logOutBtn.layer.cornerRadius = 5
        self.logOutBtn.clipsToBounds = true
//        self.headImgBtn.layer.cornerRadius = 35
//        self.headImgBtn.clipsToBounds = true
        
        self.sexImg.image = nil
        
        self.automaticallyAdjustsScrollViewInsets = false
        if SYSTEM_VERSION <= 11.0{
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }else{
            self.tableView.contentInset = UIEdgeInsets.init(top: -STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
        }
        let editBtn = UIButton.init()
        let cancelAttributeTitle = NSAttributedString.init(string: "编辑", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:UIColor.white])
        editBtn.setAttributedTitle(cancelAttributeTitle, for: .normal)
        editBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 10)
        editBtn.layer.borderWidth = 1
        editBtn.layer.borderColor = UIColor.white.cgColor
        editBtn.addTarget(self, action: #selector(dealToEditInfo(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: editBtn)
        editBtn.layer.cornerRadius = editBtn.frame.size.height*0.5
//        editBtn.clipsToBounds = true
        
        self.coverView.isUserInteractionEnabled = true
        let tapG = UITapGestureRecognizer.init(target: self, action: #selector(dealTapBackImageView))
        self.coverView.addGestureRecognizer(tapG)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = nil
        
        requestData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - misc
    @objc func dealTapBackImageView(){
        self.imagePickerVc = TZImagePickerController.init(maxImagesCount: 1, delegate: self)
        self.imagePickerVc?.allowPickingGif = false
        self.imagePickerVc?.allowPickingVideo = false
        self.imagePickerVc?.didFinishPickingPhotosHandle = {[unowned self] (photos,assets,isOriginal) in
            self.uploadImageWith(images: photos, phAssets: assets as? [PHAsset],type: "back")
        }
        self.present(imagePickerVc!, animated: true, completion: nil)
    }
    
    func uploadImageWith(images:[UIImage]?,phAssets:[PHAsset]?,type:String? = "head"){
        Toast.showStatusWith(text: "正在上传..")
        FileUploadManager.share.uploadImagesWith(images: images, phAssets: phAssets, successBlock: { (image, key) in
            Toast.showStatusWith(text: "正在保存..")

            let moyaProvider = MoyaProvider<LiMiAPI>()
            let headImgUpLoad = HeadImgUpLoad(id: Defaults[.userId], token: Defaults[.userToken], image: "/"+key, type: type)
            _ = moyaProvider.rx.request(.targetWith(target: headImgUpLoad)).subscribe(onSuccess: {[unowned self] (response) in
                let pictureResultModel = Mapper<PictureResultModel>().map(jsonData: response.data)
                if pictureResultModel?.commonInfoModel?.status == successState{
                    if type == "back"{
                        if let url = pictureResultModel?.url{
                            self.userInfoModel?.back_pic = url
                            self.backImageView.kf.setImage(with: URL.init(string: url), placeholder: image, options: nil, progressBlock: nil, completionHandler: nil)
                        }
                    }
                    if type == "head"{
                        if let url = pictureResultModel?.url{
                            self.userInfoModel?.head_pic = url
                            self.headImgBtn.kf.setImage(with: URL.init(string: url), for: .normal, placeholder: image, options: nil, progressBlock: nil, completionHandler: nil)
                        }
                    }
                }
                self.imagePickerVc?.dismiss(animated: true, completion: nil)
                Toast.showErrorWith(model: pictureResultModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
            
            print("imageWidth:\(image.size.width)--imageHeight:\(image.size.height)--key:\(key)")
        }, failedBlock: {
            
        }, completionBlock: {
            self.imagePickerVc?.dismiss(animated: true, completion: nil)
            self.tableView.reloadData()
            print("上传结束")
        }, tokenIDModel: nil)
    }
    
    @IBAction func dealToMyFollows(_ sender: Any) {
        if !AppManager.shared.checkUserStatus(){return}
        let followerListContainController = FollowerListContainController.init(initialIndex: 0)
        self.navigationController?.pushViewController(followerListContainController, animated: true)
    }
    
    @IBAction func dealToMyFollowers(_ sender: Any) {
        if !AppManager.shared.checkUserStatus(){return}
        let followerListContainController = FollowerListContainController.init(initialIndex: 1)
        self.navigationController?.pushViewController(followerListContainController, animated: true)
    }
    
    @IBAction func beLikedNumButtonCliked(_ sender: Any) {
        
    }
    
    @objc func dealToEditInfo(_ sender: Any) {
            let personInfoController = GetViewControllerFrom(sbName: .personalCenter, sbID: "PersonInfoController")
            self.navigationController?.pushViewController(personInfoController, animated: true)
    }
    //点击头像
    @IBAction func dealTapHeadImgBtn(_ sender: Any) {
        //查看大图、拍照、从相册中选择
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionLookBigImage = UIAlertAction.init(title: "查看大图", style: .default) {[unowned self] (_) in
            if let imgURL = self.userInfoModel?.head_pic,let originImg = self.headImgBtn.imageView?.image{
                SKPhotoBrowserOptions.displayCounterLabel = false                         // counter label will be hidden
                SKPhotoBrowserOptions.displayBackAndForwardButton = false                 // back / forward button will be hidden
                SKPhotoBrowserOptions.displayAction = true                               // action button will be hidden
                SKPhotoBrowserOptions.displayCloseButton = false
                SKPhotoBrowserOptions.enableSingleTapDismiss = true
                //SKPhotoBrowserOptions.bounceAnimation = true
                
                let photo = SKPhoto.photoWithImageURL(imgURL)
                photo.shouldCachePhotoURLImage = true
                let images = [photo]
                
                let broswer = SKPhotoBrowser(originImage: originImg ?? GetImgWith(size: SCREEN_RECT.size, color: .clear), photos: images, animatedFromView: self.headImgBtn)
                broswer.initializePageIndex(0)
                UIApplication.shared.keyWindow?.rootViewController?.present(broswer, animated: true, completion: nil)
            }
        }
        let actionTakePhoto = UIAlertAction.init(title: "拍照", style: .default) {[unowned self] (_) in
            let pickerController = UIImagePickerController.init()
            pickerController.sourceType = .camera
            pickerController.allowsEditing = true
            pickerController.delegate = self
            self.present(pickerController, animated: true, completion: nil)
        }
        let actionTakeFromAlbum = UIAlertAction.init(title: "从相册选择", style: .default) {[unowned self] (_) in
            self.imagePickerVc = TZImagePickerController.init(maxImagesCount: 1, delegate: self)
            self.imagePickerVc?.allowCrop = true
            self.imagePickerVc?.autoDismiss = false
            self.imagePickerVc?.imagePickerControllerDidCancelHandle = {[unowned self] in
                self.imagePickerVc?.dismiss(animated: true, completion: nil)
            }
            var rect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH)
            rect.origin.y = SCREEN_HEIGHT*0.5-SCREEN_WIDTH*0.5
            self.imagePickerVc?.cropRect = rect
            self.imagePickerVc?.didFinishPickingPhotosHandle = {[unowned self] (photos,assets,isOriginal) in
                self.uploadImageWith(images: photos, phAssets: nil,type: "head")
            }
            self.present(self.imagePickerVc!, animated: true, completion: nil)
        }
        let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(actionLookBigImage)
        alertController.addAction(actionTakePhoto)
        alertController.addAction(actionTakeFromAlbum)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //点击退出登录
    @IBAction func dealTapLogOut(_ sender: Any) {
        let alertVC = UIAlertController.init(title: "确认退出登录？", message: nil, preferredStyle: .alert)
        let actionOK = UIAlertAction.init(title: "确定", style: .default) {_ in
            NotificationCenter.default.post(name: LOGOUT_NOTIFICATION, object: self, userInfo: nil)
        }
        let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(actionOK)
        alertVC.addAction(actionCancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //请求服务器数据
    func requestData() {
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let personCenter = PersonCenter()
        _ = moyaProvider.rx.request(.targetWith(target: personCenter)).subscribe(onSuccess: { (response) in
            let personCenterModel = Mapper<PersonCenterModel>().map(jsonData: response.data)
            
            let tmpIdentityStatus = Defaults[.userCertificationState]
            Defaults[.userCertificationState] = 2
            //Defaults[.userCertificationState] = personCenterModel?.user_info?.is_access
            if tmpIdentityStatus != 2 && Defaults[.userCertificationState] == 2{
                //发通知
                NotificationCenter.default.post(name: IDENTITY_STATUS_OK_NOTIFICATION, object: nil)
            }
            
            self.refreshUIWith(personCenterModel: personCenterModel)
            Toast.showErrorWith(model: personCenterModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
//            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    //刷新界面
    func refreshUIWith(personCenterModel:PersonCenterModel?){
        self.userInfoModel = personCenterModel?.user_info
        let model = personCenterModel?.user_info
        if let headPic = model?.head_pic{
            self.headImgBtn.kf.setImage(with: URL.init(string: headPic), for: .normal, placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        if model?.sex == 0{
            self.sexImg.image = UIImage.init(named: "ic_girl")
        }else{
            self.sexImg.image = UIImage.init(named: "ic_boy")
        }
        self.nickName.text = model?.nickname
        if let _signature = model?.signature{
            self.signature.text = _signature
        }else{
            self.signature.text = "个性签名空空如也~"
        }
        if let followsNum = model?.attention_num,let followersNum = model?.fans_num,let clickedNum = model?.click_num{
            let followsNumAttr = NSMutableAttributedString.init(string: followsNum.suitableStringValue(), attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 20),NSAttributedStringKey.foregroundColor:UIColor.white])
            let followsNumLabel = NSAttributedString.init(string: "  关注", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:UIColor.white])
            followsNumAttr.append(followsNumLabel)
            self.follows.attributedText = followsNumAttr
            
            let followersNumAttr = NSMutableAttributedString.init(string: followersNum.suitableStringValue(), attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 20),NSAttributedStringKey.foregroundColor:UIColor.white])
            let followersNumLabel = NSAttributedString.init(string: "  粉丝", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:UIColor.white])
            followersNumAttr.append(followersNumLabel)
            self.followers.attributedText = followersNumAttr
            
            let beLikedNumAttr = NSMutableAttributedString.init(string: clickedNum.suitableStringValue(), attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 20),NSAttributedStringKey.foregroundColor:UIColor.white])
            let beLikedNumLabel = NSAttributedString.init(string: "  被赞", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:UIColor.white])
            beLikedNumAttr.append(beLikedNumLabel)
            self.beLikedNum.attributedText = beLikedNumAttr
        }
        if let backPic = model?.back_pic{
            self.backImageView.kf.setImage(with: URL.init(string: backPic), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        if model?.is_access == 2{
            self.authenticationState.text = "已认证"
            self.authenticationState.textColor = UIColor.white
            self.authenticationState.backgroundColor = APP_THEME_COLOR
        }else{
            self.authenticationState.text = "未认证"
            self.authenticationState.textColor = UIColor.white
            self.authenticationState.backgroundColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        }
    }
    
    func checkIdentityInfoWith(identityStatus:Int?){
        //0 ：未认证   1：认证中  2：认证完成  3：认证失败
        if let identityStatus = identityStatus{
            if identityStatus == 0{
//                let identityAuthInfoController = GetViewControllerFrom(sbName: .loginRegister ,sbID: "IdentityAuthInfoController") as! IdentityAuthInfoController
//                self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
                return
            }
            if identityStatus == 1{
                let identityAuthStateController = IdentityAuthStateController()
                identityAuthStateController.state = .inProcessing
                identityAuthStateController.isFromPersonCenter = true
                self.navigationController?.pushViewController(identityAuthStateController, animated: true)
                return
            }
            if identityStatus == 2{
                let identityAuthStateController = IdentityAuthStateController()
                identityAuthStateController.state = .finished
                identityAuthStateController.isFromPersonCenter = true
                self.navigationController?.pushViewController(identityAuthStateController, animated: true)
                return
            }
            if identityStatus == 3{
                let identityAuthStateController = IdentityAuthStateController()
                identityAuthStateController.state = .finished
                identityAuthStateController.isFromPersonCenter = true
                self.navigationController?.pushViewController(identityAuthStateController, animated: true)
                return
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{ return 1}
        if section == 1{ return 6}
        if section == 2{ return 1}
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{return 55.0}
        return UITableViewAutomaticDimension
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
            if indexPath.row == 0{
//                let personInfoController = GetViewControllerFrom(sbName: .personalCenter, sbID: "PersonInfoController")
//                self.navigationController?.pushViewController(personInfoController, animated: true)
            }
        }
        if indexPath.section == 1{
            //我的现金
            if indexPath.row == 0{
                if !AppManager.shared.checkUserStatus(){return}
                let myCashController = MyCashController()
                myCashController.userInfoModel = self.userInfoModel
                self.navigationController?.pushViewController(myCashController, animated: true)
            }
            //我的动态
            if indexPath.row == 1{
                if !AppManager.shared.checkUserStatus(){return}
                let myVideosAndLikedVideosContainController = MyVideosAndLikedVideosContainController.init(initialIndex: 0)
                self.navigationController?.pushViewController(myVideosAndLikedVideosContainController, animated: true)
//                let myTrendListController = MyTrendListController()
//                self.navigationController?.pushViewController(myTrendListController, animated: true)
            }
            //我的订单
            if indexPath.row == 2{
                if !AppManager.shared.checkUserStatus(){return}
                let myOrderListController = MyOrderListController()
                self.navigationController?.pushViewController(myOrderListController, animated: true)
            }
            //我的拉黑
            if indexPath.row == 3{
                if !AppManager.shared.checkUserStatus(){return}
                let myBlackListController = MyBlackListController()
                self.navigationController?.pushViewController(myBlackListController, animated: true)
            }
            //用户反馈
            if indexPath.row == 4{
                if !AppManager.shared.checkUserStatus(){return}
                let feedBackController = FeedBackController()
                self.navigationController?.pushViewController(feedBackController, animated: true)
            }
            //关于粒米
            if indexPath.row == 5{
                let aboutUsController = AboutUsController()
                self.navigationController?.pushViewController(aboutUsController, animated: true)
            }
        }

        
    }

}

extension PersonCenterController:TZImagePickerControllerDelegate{
    
}

extension PersonCenterController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType == kUTTypeImage as String{
            var image:UIImage!
            if picker.allowsEditing{
                image = info[UIImagePickerControllerEditedImage] as! UIImage
            }
            if !picker.allowsEditing{
                image = info[UIImagePickerControllerOriginalImage] as! UIImage
            }
            self.uploadImageWith(images: [image], phAssets: nil, type: "head")
            picker.dismiss(animated: true, completion: nil)
        }
//        NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
//        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
//            UIImage *image;
//            //如果允许编辑则获得编辑后的照片，否则获取原始照片
//            if (picker.allowsEditing) {
//                image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
//            }else{
//                image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
//            }
//            self.resultImgView.image = image;
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
//        }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
//            NSLog(@"video...");
//            NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
//            NSString *urlStr=[url path];
//            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
//                //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
//                UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
//            }
//
//        }
//
//        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}


