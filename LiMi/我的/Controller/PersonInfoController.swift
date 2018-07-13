//
//  PersonInfoController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/10.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import ObjectMapper
import TZImagePickerController

class PersonInfoController: UITableViewController {
    @IBOutlet weak var headImg: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var sexRightBar: UIImageView!
    @IBOutlet weak var sexRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signature: UILabel!
    
    @IBOutlet weak var certificationState: UILabel!
    @IBOutlet weak var certificationRightBar: UIImageView!
    @IBOutlet weak var certificationRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var school: UILabel!
    //学院
    @IBOutlet weak var academy: UILabel!
    @IBOutlet weak var grade: UILabel!
    var userInfoModel:UserInfoModel?
    var imagePickerVc:TZImagePickerController?
    
    override func viewDidLoad() {
        self.title = "个人资料"
        super.viewDidLoad()
        self.headImg.layer.cornerRadius = 19.5
        self.headImg.clipsToBounds = true
        
        self.userName.text = nil
        self.sex.text = nil
        self.school.text = nil
        self.academy.text = nil
        self.grade.text = nil
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        self.navigationController?.navigationBar.shadowImage = GetImgWith(size: CGSize.init(width: SCREEN_WIDTH, height: NAVIGATION_BAR_SEPARATE_LINE_HEIGHT), color: NAVIGATION_BAR_SEPARATE_COLOR)

        self.requestData()
    }
    
    deinit {
        print("个人信息销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - misc
    func requestData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let userInfoList = UserInfoList()
        _ = moyaProvider.rx.request(.targetWith(target: userInfoList)).subscribe(onSuccess: {[unowned self] (response) in
            let personCenterModel = Mapper<PersonCenterModel>().map(jsonData: response.data)
            self.userInfoModel = personCenterModel?.user_info
            self.tableView.reloadData()
            self.refreshUIWith(model: self.userInfoModel)
            Toast.showErrorWith(model: personCenterModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func refreshUIWith(model:UserInfoModel?){
        if let headUrl = model?.head_pic{
            self.headImg.kf.setImage(with: URL.init(string: headUrl), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.userName.text = model?.true_name
        self.nickName.text = model?.nickname
        self.signature.text = self.userInfoModel?.signature == nil ? "个性签名空空如也~" : self.userInfoModel?.signature
        var sexStr:String?
        if self.userInfoModel?.sex == 0{
            sexStr = "女"
        }
        if self.userInfoModel?.sex == 1{
            sexStr = "男"
        }
        self.sex.text = sexStr
        if self.userInfoModel?.is_access == 0{
            self.certificationState.text = "去认证"
            self.sexRightBar.isHidden = false
            self.certificationRightBar.isHidden = false
            self.sexRightConstraint.constant = 10
            self.certificationRightConstraint.constant = 10
        }
        if self.userInfoModel?.is_access == 1{
            self.certificationState.text = "认证中"
            self.sexRightBar.isHidden = true
            self.certificationRightBar.isHidden = true
            self.sexRightConstraint.constant = -7
            self.certificationRightConstraint.constant = -7
        }
        if self.userInfoModel?.is_access == 2{
            self.certificationState.text = "已认证"
            self.sexRightBar.isHidden = true
            self.certificationRightBar.isHidden = true
            self.sexRightConstraint.constant = -7
            self.certificationRightConstraint.constant = -7
        }
        self.school.text  = model?.college?.name
        //self.academy.text = model?.school
        self.grade.text = model?.grade
    }
    
    //选择头像
    func dealTapToSelectImg(){
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
            self.uploadImageWith(images: photos, phAssets: (assets as? [PHAsset]?)!)
        }
        self.present(self.imagePickerVc!, animated: true, completion: nil)
    }
    
    func uploadImageWith(images:[UIImage]?,phAssets:[PHAsset]?){
        Toast.showStatusWith(text: "正在上传..")
        FileUploadManager.share.uploadImagesWith(images: images, phAssets: phAssets, successBlock: { (image, key) in
            Toast.showStatusWith(text: "正在保存..")
            
            let moyaProvider = MoyaProvider<LiMiAPI>()
            let headImgUpLoad = HeadImgUpLoad(id: Defaults[.userId], token: Defaults[.userToken], image: "/" + key, type: "head")
            _ = moyaProvider.rx.request(.targetWith(target: headImgUpLoad)).subscribe(onSuccess: {[unowned self] (response) in
                let pictureResultModel = Mapper<PictureResultModel>().map(jsonData: response.data)
                if pictureResultModel?.commonInfoModel?.status == successState{
                    if let url = pictureResultModel?.url{
                        self.userInfoModel?.head_pic = url
                        print(url)
                        self.headImg.kf.setImage(with: URL.init(string: url), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
                    }
                }
                self.imagePickerVc?.dismiss(animated: true, completion: nil)
                Toast.showErrorWith(model: pictureResultModel)
                }, onError: { (error) in
                    Toast.showErrorWith(msg: error.localizedDescription)
            })
            
        }, failedBlock: {
            
        }, completionBlock: {
            self.imagePickerVc?.dismiss(animated: true, completion: nil)
            self.tableView.reloadData()
            print("上传结束")
        }, tokenIDModel: nil)
    }

    //去修改用户名
    func dealToAlterUserName(){
        let alterUserNameController = AlterUserNameController()
        alterUserNameController.initialUserName = self.userInfoModel?.nickname
        alterUserNameController.alterUserNameBlock = {[unowned self] (name) in
            self.userInfoModel?.nickname = name
            self.refreshUIWith(model: self.userInfoModel)
        }
        self.navigationController?.pushViewController(alterUserNameController, animated: true)
    }
    
    //去修改用户性别
    func dealToAlterUserSex(){
//        let dataPickerView = DataPickerView(dataArray: ["男","女"], initialSelectRow: 0) { (sex) in
//            if sex == self.userInfoModel?.sex{return}
//            var sexParameter = 1
//            if sex == "女"{sexParameter = 0}
//            Toast.showStatusWith(text: nil)
//            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
//            let editUserInfo = EditUsrInfo(nickname: nil, signature: nil,sex:sexParameter)
//            _ = moyaProvider.rx.request(.targetWith(target: editUserInfo)).subscribe(onSuccess: {[unowned self] (response) in
//                let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
//                if resultModel?.commonInfoModel?.status == successState{
//                    self.userInfoModel?.sex = sex
//                    self.refreshUIWith(model: self.userInfoModel)
//                }
//                Toast.showResultWith(model: resultModel)
//            }, onError: { (error) in
//                Toast.showErrorWith(msg: error.localizedDescription)
//            })
//        }
//        dataPickerView?.toShow()
    }

    func dealToAlterAutograph(){
        let alterUserSinatureController = AlterUserSinatureController()
        alterUserSinatureController.initialUserSinatrue = self.userInfoModel?.signature
        alterUserSinatureController.alterSinatureBlock = {[unowned self] (signature) in
            self.userInfoModel?.signature = signature
            self.refreshUIWith(model: self.userInfoModel)
        }
        self.navigationController?.pushViewController(alterUserSinatureController, animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{ return 4}
        if section == 1{
            return 1
        }
        if section == 2{return 4}
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{return 7}
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            if indexPath.row == 0{self.dealTapToSelectImg()}
            if indexPath.row == 1{self.dealToAlterUserName()}
            if indexPath.row == 2{
                if Defaults[.userCertificationState] == 2{return}
                self.dealToAlterUserSex()
            }
            if indexPath.row == 3{self.dealToAlterAutograph()}
        }
        if indexPath.section == 1{
            if Defaults[.userCertificationState] != 0{return}
        }
    }
}


extension PersonInfoController:TZImagePickerControllerDelegate{
    
}
