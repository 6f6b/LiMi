//
//  FinishPersonInfoController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import Moya
import TZImagePickerController
import ObjectMapper
import Kingfisher

class FinishPersonInfoController: ViewController {
    @IBOutlet weak var realName: UITextField!
    @IBOutlet weak var boyBtn: UIButton!
    @IBOutlet weak var girlBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var headImgBtn: UIButton!
    
    var imagePickerVc:TZImagePickerController?
    var loginModel:LoginModel?
    var headImageUrl:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "完善个人信息"
        self.nextBtn.layer.cornerRadius = 20
        self.nextBtn.clipsToBounds = true
        self.headImgBtn.layer.cornerRadius = 50
        self.headImgBtn.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    //选择男性
    @IBAction func dealSelectBoy(_ sender: Any) {
        self.girlBtn.isSelected = false
        self.boyBtn.isSelected = true
    }
    
    //选择女性
    @IBAction func dealSelectGirl(_ sender: Any) {
        self.girlBtn.isSelected = true
        self.boyBtn.isSelected = false
    }
    
    @IBAction func dealTapHeadImg(_ sender: Any) {
        self.imagePickerVc = TZImagePickerController.init(maxImagesCount: 1, delegate: self)
        self.imagePickerVc?.allowCrop = true
        var rect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH)
        rect.origin.y = SCREEN_HEIGHT*0.5-SCREEN_WIDTH*0.5
        self.imagePickerVc?.cropRect = rect
        //self.imagePickerVc?.autoDismiss = true
        self.imagePickerVc?.imagePickerControllerDidCancelHandle = {[unowned self] in
            self.imagePickerVc?.dismiss(animated: true, completion: nil)
        }
        self.imagePickerVc?.didFinishPickingPhotosHandle = {[unowned self] (photos,assets,isOriginal) in
            guard let _images = photos,let _phAssets = assets as? [PHAsset] else{
                Toast.showErrorWith(msg: "选择照片失败")
                self.imagePickerVc?.dismiss(animated: true, completion: nil)
                return
            }
            self.uploadHeadImageWith(images: _images, phAssets: _phAssets)
        }
        self.present(self.imagePickerVc!, animated: true, completion: nil)
    }
    
    func uploadHeadImageWith(images:[UIImage]?,phAssets:[PHAsset]?){
        let tokenIdModel = TokenIDModel.init(token: self.loginModel?.token, Id: self.loginModel?.id)
        FileUploadManager.share.uploadImagesWith(images: images, phAssets: phAssets, successBlock: { (image, key) in
            let moyaProvider = MoyaProvider<LiMiAPI>()
            let headImgUpLoad = HeadImgUpLoad(id: self.loginModel?.id, token: self.loginModel?.token, image: "/"+key, type: "head")
            _ = moyaProvider.rx.request(.targetWith(target: headImgUpLoad)).subscribe(onSuccess: { (response) in
                let model = Mapper<BaseModel>().map(jsonData: response.data)
                if model?.commonInfoModel?.status == successState{
                    self.headImgBtn.setImage(image, for: .normal)
                    self.headImageUrl = key
                }
                Toast.showResultWith(model: model)
                self.imagePickerVc?.dismiss(animated: true, completion: nil)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }, failedBlock: {
            
        }, completionBlock: {
            
        }, tokenIDModel: tokenIdModel)
    }

    
    //下一步
    @IBAction func dealTapNext(_ sender: Any) {
        //判断是否选择了性别
        if self.boyBtn.isSelected == false && self.girlBtn.isSelected == false{
            Toast.showErrorWith(msg: "请选择性别")
            return
        }
        //判断是否填写了姓名
        if IsEmpty(textField: self.realName){
            Toast.showErrorWith(msg: "请输入姓名")
            return
        }
        //判断是否上传了头像
        if self.headImageUrl == nil{
            Toast.showErrorWith(msg: "请完善您的头像")
            return
        }
        Toast.showStatusWith(text: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let sex = self.boyBtn.isSelected ? 1:0
        let registerFinishNameAndSex = RegisterFinishNameAndSex(id: self.loginModel?.id, token: self.loginModel?.token, true_name: self.realName.text, sex: sex.stringValue())
        _ = moyaProvider.rx.request(.targetWith(target: registerFinishNameAndSex)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                //存储userid和token
                Defaults[.userId] = self.loginModel?.id
                Defaults[.userToken] = self.loginModel?.token
                LoginServiceToMainController(loginRootController: self.navigationController)
//                let identityAuthInfoController = GetViewControllerFrom(sbName: .loginRegister ,sbID: "IdentityAuthInfoController") as! IdentityAuthInfoController
//                self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
            }
            Toast.showErrorWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    
}

extension FinishPersonInfoController:TZImagePickerControllerDelegate{
//    func imag
}
