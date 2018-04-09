//
//  PersonCenterController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/10.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import SVProgressHUD
import Kingfisher
import TZImagePickerController

class PersonCenterController: UITableViewController {
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
    
    
    @IBOutlet weak var logOutBtn: UIButton!
    
    var personCenterModel:PersonCenterModel?
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
            self.tableView.contentInset = UIEdgeInsets.init(top: -64, left: 0, bottom: 0, right: 0)
        }
        
        let editBtn = UIButton.init(type: .custom)
        let cancelAttributeTitle = NSAttributedString.init(string: "编辑", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:UIColor.white])
        editBtn.setAttributedTitle(cancelAttributeTitle, for: .normal)
        editBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 20)
        editBtn.layer.cornerRadius = 10
        editBtn.clipsToBounds = true
        editBtn.layer.borderWidth = 1
        editBtn.layer.borderColor = UIColor.white.cgColor
        editBtn.addTarget(self, action: #selector(dealToEditInfo(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: editBtn)
        
        self.coverView.isUserInteractionEnabled = true
        let tapG = UITapGestureRecognizer.init(target: self, action: #selector(dealTapBackImageView))
        self.coverView.addGestureRecognizer(tapG)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = nil
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
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
            self.uploadImageWith(images: photos, phAssets: assets as? [PHAsset])
        }
        self.present(imagePickerVc!, animated: true, completion: nil)
    }
    
    func uploadImageWith(images:[UIImage]?,phAssets:[PHAsset]?){
        Toast.showStatusWith(text: "正在上传")
        FileUploadManager.share.uploadImagesWith(images: images, phAssets: phAssets, successBlock: { (image, key) in
            var localMediaModel = LocalMediaModel.init()
            localMediaModel.key = key
            localMediaModel.image = image
            
            let moyaProvider = MoyaProvider<LiMiAPI>()
            let headImgUpLoad = HeadImgUpLoad(id: Defaults[.userId], token: Defaults[.userToken], image: "/"+key, type: "back")
            _ = moyaProvider.rx.request(.targetWith(target: headImgUpLoad)).subscribe(onSuccess: {[unowned self] (response) in
                let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
                if resultModel?.commonInfoModel?.status == successState{
                    self.backImageView.image = image
                }
                self.imagePickerVc?.dismiss(animated: true, completion: nil)
                Toast.showErrorWith(model: resultModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
            
            print("imageWidth:\(image.size.width)--imageHeight:\(image.size.height)--key:\(key)")
        }, failedBlock: {
            
        }, completionBlock: {
            Toast.dismiss()
            self.imagePickerVc?.dismiss(animated: true, completion: nil)
            self.tableView.reloadData()
            print("上传结束")
        }, tokenIDModel: nil)
    }
    
    @IBAction func dealToMyFollows(_ sender: Any) {
        let followerListContainController = FollowerListContainController.init(initialIndex: 0)
        self.navigationController?.pushViewController(followerListContainController, animated: true)
    }
    
    @IBAction func dealToMyFollowers(_ sender: Any) {
        let followerListContainController = FollowerListContainController.init(initialIndex: 1)
        self.navigationController?.pushViewController(followerListContainController, animated: true)
    }
    @objc func dealToEditInfo(_ sender: Any) {
            let personInfoController = GetViewControllerFrom(sbName: .personalCenter, sbID: "PersonInfoController")
            self.navigationController?.pushViewController(personInfoController, animated: true)
    }
    //点击头像
    @IBAction func dealTapHeadImgBtn(_ sender: Any) {
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
            self.refreshUIWith(personCenterModel: personCenterModel)
            Toast.showErrorWith(model: personCenterModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
//            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    //刷新界面
    func refreshUIWith(personCenterModel:PersonCenterModel?){
        self.personCenterModel = personCenterModel
        let model = personCenterModel?.user_info
        if let headPic = model?.head_pic{
            self.headImgBtn.kf.setImage(with: URL.init(string: headPic), for: .normal, placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        if model?.sex == "女"{
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
        if let followsNum = model?.attention_num,let followersNum = model?.fans_num{
            let followsNumAttr = NSMutableAttributedString.init(string: followsNum, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 20),NSAttributedStringKey.foregroundColor:UIColor.white])
            let followsNumLabel = NSAttributedString.init(string: "  关注", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:UIColor.white])
            followsNumAttr.append(followsNumLabel)
            self.follows.attributedText = followsNumAttr
            
            let followersNumAttr = NSMutableAttributedString.init(string: followersNum, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 20),NSAttributedStringKey.foregroundColor:UIColor.white])
            let followersNumLabel = NSAttributedString.init(string: "  粉丝", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:UIColor.white])
            followersNumAttr.append(followersNumLabel)
            self.followers.attributedText = followersNumAttr
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
                let identityAuthInfoController = GetViewControllerFrom(sbName: .loginRegister ,sbID: "IdentityAuthInfoController") as! IdentityAuthInfoController
                self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
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
                let myCashController = MyCashController()
                myCashController.personCenterModel = self.personCenterModel
                self.navigationController?.pushViewController(myCashController, animated: true)
            }
            //我的动态
            if indexPath.row == 1{
                if !AppManager.shared.checkUserStatus(){return}
                let myTrendListController = MyTrendListController()
                self.navigationController?.pushViewController(myTrendListController, animated: true)
            }
            //我的订单
            if indexPath.row == 2{
                if !AppManager.shared.checkUserStatus(){return}
                let myOrderListController = MyOrderListController()
                self.navigationController?.pushViewController(myOrderListController, animated: true)
            }
            //我的拉黑
            if indexPath.row == 3{
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
                self.navigationController?.pushViewController(aboutUsController, animated: true)            }
        }

        
    }

}

extension PersonCenterController:TZImagePickerControllerDelegate{
    
}
