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
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var school: UILabel!
    //学院
    @IBOutlet weak var academy: UILabel!
    @IBOutlet weak var grade: UILabel!
    var model:UserInfoListModel?
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
        
        self.requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - misc
    func requestData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let userInfoList = UserInfoList()
        _ = moyaProvider.rx.request(.targetWith(target: userInfoList)).subscribe(onSuccess: { (response) in
            let userInfoListModel = Mapper<UserInfoListModel>().map(jsonData: response.data)
            self.model = userInfoListModel
            self.refreshUIWith(model: self.model)
            SVProgressHUD.showErrorWith(model: userInfoListModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func refreshUIWith(model:UserInfoListModel?){
        if let headUrl = model?.userInfo?.head_pic{
            self.headImg.kf.setImage(with: URL.init(string: headUrl), placeholder: UIImage.init(named: "touxiang1"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.userName.text = model?.userInfo?.true_name
        self.sex.text = model?.userInfo?.sex
        self.school.text  = model?.userInfo?.college
        self.academy.text = model?.userInfo?.school
        self.grade.text = model?.userInfo?.grade
    }
    
    //选择头像
    func dealTapToSelectImg(){
        self.imagePickerVc = TZImagePickerController.init(maxImagesCount: 1, delegate: self)
        self.imagePickerVc?.allowCrop = true
        var rect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH)
        rect.origin.y = SCREEN_HEIGHT*0.5-SCREEN_WIDTH*0.5
        self.imagePickerVc?.cropRect = rect
        self.imagePickerVc?.didFinishPickingPhotosHandle = {(photos,assets,isOriginal) in
            let compressImg = CompressImgWith(img: photos?.first, maxKB: HEAD_IMG_MAX_MEMERY_SIZE)
            let localImgUrl = GenerateImgUrlWith(img: compressImg)
            self.uploadImgWith(imgUrl: localImgUrl)
        }
        self.present(self.imagePickerVc!, animated: true, completion: nil)
    }
    
    //去修改用户名
    func dealToAlterUserName(){
        let alterUserNameController = AlterUserNameController()
        alterUserNameController.initialUserName = self.model?.userInfo?.true_name
        alterUserNameController.alterUserNameBlock = {(name) in
            self.userName.text = name
        }
        self.navigationController?.pushViewController(alterUserNameController, animated: true)
    }
    
    //去修改用户性别
    func dealToAlterUserSex(){
        let dataPickerView = DataPickerView(dataArray: ["男","女"], initialSelectRow: 0) { (sex) in
            if sex == self.model?.userInfo?.sex{return}
            var sexParameter = "1"
            if sex == "女"{sexParameter = "0"}
            SVProgressHUD.show(withStatus: nil)
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            let editUsrInfo = EditUsrInfo(field: "sex", value: sexParameter)
            _ = moyaProvider.rx.request(.targetWith(target: editUsrInfo)).subscribe(onSuccess: { (response) in
                let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
                if resultModel?.commonInfoModel?.status == successState{
                    self.sex.text = sex
                    self.model?.userInfo?.sex = sex
                }
                SVProgressHUD.showResultWith(model: resultModel)
            }, onError: { (error) in
                SVProgressHUD.showErrorWith(msg: error.localizedDescription)
            })
        }
        dataPickerView?.toShow()
//        let alterUserSexController = AlterUserSexController()
//        alterUserSexController.alterUserSexBlock = {(sex) in
//            self.sex.text = sex
//        }
//        self.navigationController?.pushViewController(alterUserSexController, animated: true)
    }
    
    func uploadImgWith(imgUrl:URL?){
        SVProgressHUD.show(withStatus: "正在上传..")
        let moyaProvider = MoyaProvider<LiMiAPI>()
        
        let headImgUpLoad = HeadImgUpLoad(headImgUrl: imgUrl, id: nil, token: nil)
        _ = moyaProvider.rx.request(.targetWith(target: headImgUpLoad)).subscribe(onSuccess: { (response) in
            do {
                let model = try response.mapObject(BaseModel.self)
                if model.commonInfoModel?.status == successState{
                    self.headImg.kf.setImage(with: imgUrl, placeholder: UIImage.init(named: "touxiang1"), options: nil, progressBlock: nil, completionHandler: nil)
                }
                SVProgressHUD.showResultWith(model: model)
            }
            catch{SVProgressHUD.showErrorWith(msg: error.localizedDescription)}
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{ return 3}
        if section == 1{ return 3}
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 7
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
            if indexPath.row == 2{self.dealToAlterUserSex()}
        }
        if indexPath.section == 1{}
    }
}

extension PersonInfoController:TZImagePickerControllerDelegate{
    
}
