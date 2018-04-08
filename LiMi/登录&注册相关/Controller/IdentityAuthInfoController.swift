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

class IdentityAuthInfoController: UITableViewController {
    
    @IBOutlet weak var trueName: UITextField!
    @IBOutlet weak var school: UILabel!
    //学院
    @IBOutlet weak var academy: UILabel!
    @IBOutlet weak var grade: UILabel!
    
    @IBOutlet weak var certificateImage: UIImageView!
    @IBOutlet weak var authenticationBtn: UIButton!
    
    ///证件图片链接
    var certificateImageUrl:String?
    
    var imagePickerVC:TZImagePickerController?
    
    var collegeModel:CollegeModel?
    var academyModel:AcademyModel?
    var gradeModel:GradeModel?
    
    //是否显示notice
    var isShowNotice = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "学生认证"
        self.tableView.estimatedRowHeight = 1000
        self.tableView.estimatedSectionHeaderHeight = 100
        
        
        self.school.text = nil
        self.academy.text = nil
        self.grade.text = nil

        self.authenticationBtn.layer.cornerRadius = 20
        self.authenticationBtn.clipsToBounds = true
        
        self.trueName.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        self.navigationController?.navigationBar.shadowImage = GetImgWith(size: CGSize.init(width: SCREEN_WIDTH, height: NAVIGATION_BAR_SEPARATE_LINE_HEIGHT), color: NAVIGATION_BAR_SEPARATE_COLOR)

        
//        let notNowBtn = UIButton.init(type: .custom)
//        let notNowAttributeTitle = NSAttributedString.init(string: "暂不", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:APP_THEME_COLOR])
//        notNowBtn.setAttributedTitle(notNowAttributeTitle, for: .normal)
//        notNowBtn.sizeToFit()
//        notNowBtn.addTarget(self, action: #selector(dealNotNow), for: .touchUpInside)
//        self.navigationItem.leftBarButtonItem?.customView = notNowBtn
    }
    
    deinit {
        print("认证信息销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK:  - misc
    
    func refreshCertificationBtn(){
        if IsEmpty(textField: self.trueName) || self.collegeModel == nil || self.academyModel == nil || self.gradeModel == nil || self.certificateImageUrl == nil{
            self.authenticationBtn.backgroundColor = RGBA(r: 153, g: 153, b: 153, a: 1)
            self.authenticationBtn.isUserInteractionEnabled = false
        }else{
            self.authenticationBtn.backgroundColor = APP_THEME_COLOR
            self.authenticationBtn.isUserInteractionEnabled = true
        }
    }
    
    //选择证件图片
    @IBAction func dealTochooseCertificateImage(_ sender: Any) {
        self.imagePickerVC = TZImagePickerController.init()
        self.imagePickerVC?.maxImagesCount = 1
        self.imagePickerVC?.allowPickingGif = false
        self.imagePickerVC?.allowPickingVideo = false
        //self.imagePickerVC?.autoDismiss = true
        self.imagePickerVC?.didFinishPickingPhotosHandle = {[unowned self] (imgs,phAssets,bool) in
            FileUploadManager.share.uploadImagesWith(images: imgs, phAssets: (phAssets as? [PHAsset]?)!, successBlock: { (image, key) in
                self.certificateImage.image = image
                self.certificateImageUrl = key
            }, failedBlock: {
                
            }, completionBlock: {
                self.refreshCertificationBtn()
            }, tokenIDModel: nil)

        }
        self.present(self.imagePickerVC!, animated: true, completion: nil)
    }
    
    //提交认证
    @IBAction func dealToAuthenticate(_ sender: Any) {
        self.dealSumbit()
    }
    
    @objc func dealSumbit(){
        if IsEmpty(textField: self.trueName){
            Toast.showErrorWith(msg: "请输入您的真实姓名")
            return
        }
        if(self.collegeModel == nil){
            //显示错误警告
            Toast.showErrorWith(msg: "请选择学校")
            return
        }
        if(self.academy == nil){
            //显示错误警告
            Toast.showErrorWith(msg: "请选择学院")
            return
        }
        if(self.grade == nil){
            //显示错误警告
            Toast.showErrorWith(msg: "请选择年级")
            return
        }
        if (self.certificateImageUrl == nil){
            Toast.showErrorWith(msg: "请上传您的相关证件")
            return
        }
        Toast.showStatusWith(text: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let perfectUserInfo = CenterPerfectUserInfo.init(type: "1", true_name: self.trueName.text, college: self.collegeModel?.coid, school: self.academyModel?.id, grade: self.gradeModel?.id, identity_pic: self.certificateImageUrl)
        _ = moyaProvider.rx.request(.targetWith(target: perfectUserInfo)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                Defaults[.userCertificationState] = 1
                let identityAuthStateController = IdentityAuthStateController()
                identityAuthStateController.isFromPersonCenter = false
                self.navigationController?.popViewController(animated: true)
            }
            Toast.showErrorWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @objc func dealNotNow(){
        //返回主界面
        LoginServiceToMainController(loginRootController: self.navigationController)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 4}
        if section == 1{return 1}
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{return UITableViewAutomaticDimension}
        return 54
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isShowNotice && section == 0{
            let headerView = GET_XIB_VIEW(nibName: "IdentityAuthInfoHeaderView") as! IdentityAuthInfoHeaderView
            headerView.deleteBlock = {[unowned self] in
                self.isShowNotice = false
                tableView.reloadData()
            }
            return headerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.isShowNotice{return UITableViewAutomaticDimension}
        if section == 1{return 7}
        return 0.001
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            if indexPath.row == 1{
                self.toChooseCollege()
            }
            if indexPath.row == 2{
                self.toChooseAcademy()
            }
            if indexPath.row == 3{
                self.toChooseGrade()
            }
        }
    }

}

extension IdentityAuthInfoController{
    func toChooseCollege(){
        let chooseSchoolController = ChooseSchoolController()
        chooseSchoolController.chooseBlock = {[unowned self] (collegeModel) in
            self.school.text = collegeModel?.name
            self.collegeModel = collegeModel
            self.academyModel = nil
            self.academy.text = nil
            self.refreshCertificationBtn()
        }
        self.present(chooseSchoolController, animated: true, completion: nil)
    }
    
    func toChooseAcademy(){
        if let collegeId = self.collegeModel?.coid{
            let chooseAcademyController = ChooseAcademyController()
            chooseAcademyController.collegeId = collegeId
            chooseAcademyController.chooseAcademyBlock = {[unowned self] (academyModel) in
                self.academy.text = academyModel?.name
                self.academyModel = academyModel
                self.refreshCertificationBtn()
            }
            self.navigationController?.pushViewController(chooseAcademyController, animated: true)
        }else{
            Toast.showErrorWith(msg: "请先选择大学")
        }
    }
    
    func toChooseGrade(){
        let chooseGradeController = ChooseGradeController()
        chooseGradeController.chooseGradeBlock = {[unowned self] (gradeModel) in
            self.grade.text = gradeModel?.name
            self.gradeModel = gradeModel
            self.refreshCertificationBtn()
        }
        self.navigationController?.pushViewController(chooseGradeController, animated: true)
    }
}

extension IdentityAuthInfoController{
    @objc func textFieldChanged(textField:UITextField){
        self.refreshCertificationBtn()
    }
}
