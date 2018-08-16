//
//  UserInfoEditController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/29.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import TZImagePickerController

class UserInfoEditController: UITableViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var userHeadImageView: UIImageView!
    @IBOutlet weak var nicknameTextFeild: UITextField!
    @IBOutlet weak var sex: UITextField!
    @IBOutlet weak var school: UITextField!
    @IBOutlet weak var authenticationButton: UIButton!
    @IBOutlet weak var area: UITextField!
    @IBOutlet weak var birthday: UITextField!
    @IBOutlet weak var signatureTextFeild: UITextField!
    @IBOutlet weak var signatureCharacterNum: UILabel!
    
    var imagePickerVc:TZImagePickerController?
    
    var userInfoModel:UserInfoModel?
    
    var headImageURL:String?
    var sexValue:Int?
    var college:CollegeModel?
    var cityModel:CityModel?
    var birthdayValue:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "申请认证"
        
        let saveButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        saveButton.setTitle("保存", for: .normal)
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        saveButton.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: saveButton)
        
        self.headImageURL = self.userInfoModel?.head_pic
        self.sexValue = self.userInfoModel?.sex
        self.college = self.userInfoModel?.college
        self.cityModel = self.userInfoModel?.city
        self.birthdayValue = self.userInfoModel?.birthday
        
        let tapedUserHead = UITapGestureRecognizer.init(target: self, action: #selector(tapedUserHeadImageView))
        self.userHeadImageView.addGestureRecognizer(tapedUserHead)
        
        self.signatureTextFeild.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: .editingChanged)
        self.refreshUI()
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func refreshUI(){
        if let headImage = self.userInfoModel?.head_pic{
            self.userHeadImageView.kf.setImage(with: URL.init(string: headImage), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.nicknameTextFeild.text = self.userInfoModel?.nickname
        var sexStr:String?
        if self.userInfoModel?.sex == 0{
            sexStr = "女"
        }
        if self.userInfoModel?.sex == 1{
            sexStr = "男"
        }
        self.sex.text = sexStr
        self.school.text = self.userInfoModel?.college?.name
        if let birthday = self.userInfoModel?.birthday{
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = Date.init(timeIntervalSinceNow: TimeInterval.init(birthday))
            self.birthday.text = dateFormatter.string(from: date)
        }
        self.area.text = self.userInfoModel?.city?.name
        self.signatureTextFeild.text = self.userInfoModel?.signature
        
        self.authenticationButton.isHidden = false
        self.authenticationButton.isUserInteractionEnabled = true
        var authenticationTitle = ""
        if self.userInfoModel?.is_access == 0{
            //未认证
            authenticationTitle = "未认证"
        }
        if self.userInfoModel?.is_access == 1{
            //认证中
            authenticationTitle = "认证中"
            self.authenticationButton.isUserInteractionEnabled = false
        }
        if self.userInfoModel?.is_access == 2{
            //认证通过
            authenticationTitle = "认证通过"
            self.authenticationButton.isUserInteractionEnabled = false
        }
        if self.userInfoModel?.is_access == 3{
            //认证失败
            authenticationTitle = "认证失败"
        }
        self.authenticationButton.setTitle(authenticationTitle, for: .normal)

        var signature = ""
        if let _sinature = self.signatureTextFeild.text{
            signature = _sinature
        }
        self.signatureCharacterNum.text = "\(NSString.init(string: signature).length)/20"
    }
    
    func uploadImageWith(images:[UIImage]?,phAssets:[PHAsset]?){
        Toast.showStatusWith(text: "正在上传..")
        FileUploadManager.share.uploadImagesWith(images: images, phAssets: phAssets, successBlock: { (image, key) in
            Toast.showStatusWith(text: "正在保存..")
            
            let moyaProvider = MoyaProvider<LiMiAPI>()
            let headImgUpLoad = HeadImgUpLoad(id: nil, token: nil, image: "/" + key, type: "head")
            _ = moyaProvider.rx.request(.targetWith(target: headImgUpLoad)).subscribe(onSuccess: {[unowned self] (response) in
                let pictureResultModel = Mapper<PictureResultModel>().map(jsonData: response.data)
                if pictureResultModel?.commonInfoModel?.status == successState{
                    if let url = pictureResultModel?.url{
                        print(url)
                        self.userInfoModel?.head_pic = url
                        self.userHeadImageView.kf.setImage(with: URL.init(string: url), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
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
    
    //MARK: - actions
    @objc func textFieldValueChanged(textField:UITextField!){
        var text = NSString.init()
        if let position = textField.markedTextRange{
            //校验是否处在拼写期间
            if let _ = textField.position(from: position.start, offset: 0){return}
            if let _text = textField.text{
                text = NSString.init(string: _text)
            }
            if text.length > 20{
                text = NSString.init(string: text.substring(with: NSRange.init(location: 0, length: 20)))
            }
            textField.text = String.init(text)
            self.signatureCharacterNum.text = "\(text.length)/20"
        }else{
            if let _text = textField.text{
                text = NSString.init(string: _text)
            }
            if text.length > 20{
                text = NSString.init(string: text.substring(with: NSRange.init(location: 0, length: 20)))
            }
            textField.text = String.init(text)
            self.signatureCharacterNum.text = "\(text.length)/20"
        }
    }
    
    @objc func tapedUserHeadImageView(){
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
    
    @objc func saveButtonClicked(){
//        if IsEmpty(textField: self.nicknameTextFeild){
//            Toast.showErrorWith(msg: "昵称不能为空")
//            return
//        }
//        if self.sexValue == nil{
//            Toast.showErrorWith(msg: "性别不能为空")
//            return
//        }
        if self.college == nil{
            Toast.showErrorWith(msg: "学校不能为空")
            return
        }
//        if self.cityModel == nil{
//            Toast.showErrorWith(msg: "地区不能为空")
//            return
//        }
//        if self.birthdayValue == nil{
//            Toast.showErrorWith(msg: "生日不能为空")
//            return
//        }
//        if IsEmpty(textField: self.signatureTextFeild){
//            Toast.showErrorWith(msg: "签名不能为空")
//            return
//        }
        Toast.showStatusWith(text: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let editUserInfo = EditUsrInfo.init(nickname: self.nicknameTextFeild.text, signature: self.signatureTextFeild.text, sex: self.sexValue, birthday: self.birthdayValue, city_id: self.cityModel?.id, province_id: self.cityModel?.province?.id, college_id: self.college?.id)
        _ = moyaProvider.rx.request(.targetWith(target: editUserInfo)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                self.userInfoModel?.nickname = self.nicknameTextFeild.text
                self.userInfoModel?.signature = self.signatureTextFeild.text
                self.userInfoModel?.sex = self.sexValue
                self.userInfoModel?.birthday = self.birthdayValue
                self.userInfoModel?.city = self.cityModel
                self.userInfoModel?.college = self.college
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(0.5)), execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
            Toast.showResultWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    @IBAction func unAuthentificationButtonClicked(_ sender: Any) {
        let studentCertificationController = GetViewControllerFrom(sbName: .personalCenter, sbID: "StudentCertificationController") as! StudentCertificationController
        self.navigationController?.pushViewController(studentCertificationController, animated: true)
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{return 250}
        if indexPath.row == 6{return heightWith(text: self.signatureTextFeild.text)}
        return 55
    }

    func heightWith(text:String?)->CGFloat{
        return 55
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.nicknameTextFeild.resignFirstResponder()
        self.signatureTextFeild.resignFirstResponder()
        if indexPath.row == 1{}
        //性别
        if indexPath.row == 2{
            let dataPickerView = DataPickerView(dataArray: ["男","女"], initialSelectRow: 0) { (sex) in
                self.sex.text = sex
                var sexParameter = 1
                if sex == "女"{sexParameter = 0}
                self.sexValue = sexParameter
            }
            dataPickerView?.toShow()
        }
        //学校
        if indexPath.row == 3{
            if self.userInfoModel?.is_access == 1 || self.userInfoModel?.is_access == 2{
                return
            }
            let schoolListController = SchoolListController()
            schoolListController.delegate = self
            self.present(schoolListController, animated: true, completion: nil)
        }
        //地区
        if indexPath.row == 4{
            let provinceListController = ProvinceListController()
            provinceListController.selectCityBlock = {[unowned self] (cityModel) in
                self.area.text = cityModel.name
                self.cityModel = cityModel
                self.navigationController?.popToViewController(self, animated: true)
            }
            self.navigationController?.pushViewController(provinceListController, animated: true)
        }
        //生日
        if indexPath.row == 5{
            let datePickerView = GET_XIB_VIEW(nibName: "DatePickerView") as! DatePickerView
            datePickerView.frame = SCREEN_RECT
            datePickerView.datePicker.minimumDate = Date.init(timeIntervalSinceNow: -100*365*24*60*60)
            datePickerView.datePicker.maximumDate = Date.init(timeIntervalSinceNow: -18*365*24*60*60)
            if let _birthdayValue = self.birthdayValue{
                datePickerView.datePicker.date = Date.init(timeIntervalSinceNow: TimeInterval(_birthdayValue))
            }
            datePickerView.datePickerBlock = {[unowned self] (date) in
                let dateForMatter = DateFormatter()
                dateForMatter.dateFormat = "yyyy-MM-dd"
                self.birthday.text = dateForMatter.string(from: date)
                self.birthdayValue = Int(date.timeIntervalSinceNow)
            }
            UIApplication.shared.keyWindow?.addSubview(datePickerView)
        }
        //签名
        if indexPath.row == 6{}
    }

}

extension UserInfoEditController : UITextFieldDelegate{
}

extension UserInfoEditController : TZImagePickerControllerDelegate{
    
}

extension UserInfoEditController : SchoolListControllerDelegate{
    func schoolListControllerCancelButtonClicked() {
        
    }
    
    func schoolListControllerChoosedSchoolWith(model: CollegeModel) {
        self.college = model
        self.school.text = model.name
        self.dismiss(animated: true, completion: nil)
    }
}
