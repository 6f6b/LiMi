//
//  IdentityAuthInfoController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import ObjectMapper
import TZImagePickerController

class IdentityAuthInfoWithSexAndNameController: UITableViewController {
    @IBOutlet weak var headImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var school: UILabel!
    //学院
    @IBOutlet weak var academy: UILabel!
    @IBOutlet weak var grade: UILabel!
    var imagePickerVc:TZImagePickerController?
    var identityInfoModel:IdentityInfoModel?
    
    //是否显示notice
    var isShowNotice = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "身份认证"
        self.tableView.estimatedRowHeight = 100
        self.tableView.estimatedSectionHeaderHeight = 100
        
        let sumbitBtn = UIButton.init(type: .custom)
        let sumBitAttributeTitle = NSAttributedString.init(string: "提交", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        sumbitBtn.setAttributedTitle(sumBitAttributeTitle, for: .normal)
        sumbitBtn.sizeToFit()
        sumbitBtn.addTarget(self, action: #selector(dealSumbit), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sumbitBtn)
        
        self.headImg.layer.cornerRadius = 19.5
        self.headImg.clipsToBounds = true
        self.userName.text = nil
        self.sex.text = nil
        self.school.text = nil
        self.academy.text = nil
        self.grade.text = nil
        
        requestDatas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notNowBtn = UIButton.init(type: .custom)
        let notNowAttributeTitle = NSAttributedString.init(string: "暂不", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        notNowBtn.setAttributedTitle(notNowAttributeTitle, for: .normal)
        notNowBtn.sizeToFit()
        notNowBtn.addTarget(self, action: #selector(dealNotNow), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem?.customView = notNowBtn
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - misc
    func requestDatas(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let centerShowUserInfo = CenterShowUserInfo()
        _ = moyaProvider.rx.request(.targetWith(target: centerShowUserInfo)).subscribe(onSuccess: { (response) in
            let identityInfoModel = Mapper<IdentityInfoModel>().map(jsonData: response.data)
            self.refreshUIWith(model: identityInfoModel)
            SVProgressHUD.showErrorWith(model: identityInfoModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func refreshUIWith(model:IdentityInfoModel?){
        self.identityInfoModel = model
        if let headImg = model?.head_pic{
            self.headImg.kf.setImage(with: URL.init(string: headImg), placeholder: UIImage.init(named: "touxiang1"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.userName.text = model?.true_name
        self.sex.text = model?.sex
        self.school.text = model?.college?.name
        self.academy.text = model?.school?.name
        self.grade.text = model?.grade?.name
    }
    
    //提交
    @objc func dealSumbit(){
        //检测学校是否为空
        if self.identityInfoModel?.college?.coid == nil{
            SVProgressHUD.showErrorWith(msg: "请选择学校")
            return
        }
        //检测学院是否为空
        if self.identityInfoModel?.school?.scid == nil{
            SVProgressHUD.showErrorWith(msg: "请选择学院")
            return
        }
        //检测年级是否为空
        if self.identityInfoModel?.grade?.id == nil{
            SVProgressHUD.showErrorWith(msg: "请选择年级")
            return
        }
        SVProgressHUD.show(withStatus: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let centerPerfectUserInfo = CenterPerfectUserInfo(type: "1", true_name: self.identityInfoModel?.true_name, sex: "1", college: self.identityInfoModel?.college?.coid?.stringValue(), school: self.identityInfoModel?.school?.scid?.stringValue(), grade: self.identityInfoModel?.grade?.id?.stringValue())
        _ = moyaProvider.rx.request(.targetWith(target: centerPerfectUserInfo)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                let identityAuthStateController = IdentityAuthStateController()
                identityAuthStateController.isFromPersonCenter = true
                self.navigationController?.pushViewController(identityAuthStateController, animated: true)
            }
            SVProgressHUD.showErrorWith(model: resultModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @objc func dealNotNow(){
        self.navigationController?.popViewController(animated: true)
    }
    
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
    
    func dealToAlterUserName(){
        let alterUserNameController = AlterUserNameController()
        alterUserNameController.initialUserName = self.identityInfoModel?.true_name
        alterUserNameController.alterUserNameBlock = {(name) in
            self.userName.text = name
        }
        self.navigationController?.pushViewController(alterUserNameController, animated: true)
    }
    
    func dealToAlterUserSex(){
        let alterUserSexController = AlterUserSexController()
        alterUserSexController.alterUserSexBlock = {(sex) in
            self.sex.text = sex
        }
        self.navigationController?.pushViewController(alterUserSexController, animated: true)
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3{return UITableViewAutomaticDimension}
        return 54
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isShowNotice && section == 0{
            let headerView = GET_XIB_VIEW(nibName: "IdentityAuthInfoHeaderView") as! IdentityAuthInfoHeaderView
            headerView.deleteBlock = {
                self.isShowNotice = false
                tableView.reloadData()
            }
            return headerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{return 7}
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.isShowNotice{return UITableViewAutomaticDimension}
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            if indexPath.row == 0{self.dealTapToSelectImg()}
            if indexPath.row == 1{self.dealToAlterUserName()}
            if indexPath.row == 2{self.dealToAlterUserSex()}
        }
        if indexPath.section == 1{
            if indexPath.row == 0{self.toChooseCollege()}
            if indexPath.row == 1{self.toChooseAcademy()}
            if indexPath.row == 2{self.toChooseGrade()}
        }
    }
    
}

extension IdentityAuthInfoWithSexAndNameController{
    func toChooseCollege(){
        let chooseSchoolController = ChooseSchoolController()
        chooseSchoolController.chooseBlock = {(collegeModel) in
            self.school.text = collegeModel?.name
            self.identityInfoModel?.college = collegeModel
            self.identityInfoModel?.school = nil
            self.refreshUIWith(model: self.identityInfoModel)
        }
        self.navigationController?.pushViewController(chooseSchoolController, animated: true)
    }
    
    func toChooseAcademy(){
        if let collegeId = self.identityInfoModel?.college?.coid{
            let chooseAcademyController = ChooseAcademyController()
            chooseAcademyController.collegeId = collegeId
            chooseAcademyController.chooseAcademyBlock = {(academyModel) in
                self.academy.text = academyModel?.name
                self.identityInfoModel?.school = academyModel
            }
            self.navigationController?.pushViewController(chooseAcademyController, animated: true)
        }else{
            SVProgressHUD.showErrorWith(msg: "请先选择大学")
        }
    }
    
    func toChooseGrade(){
        let chooseGradeController = ChooseGradeController()
        chooseGradeController.chooseGradeBlock = {(gradeModel) in
            self.grade.text = gradeModel?.name
            self.identityInfoModel?.grade = gradeModel
        }
        self.navigationController?.pushViewController(chooseGradeController, animated: true)
    }
}

extension IdentityAuthInfoWithSexAndNameController:TZImagePickerControllerDelegate{
    
}
