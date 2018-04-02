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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "完善个人信息"
        self.nextBtn.layer.cornerRadius = 20
        self.nextBtn.clipsToBounds = true
        self.headImgBtn.layer.cornerRadius = 35
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
        self.imagePickerVc?.autoDismiss = false
        self.imagePickerVc?.imagePickerControllerDidCancelHandle = {[unowned self] in
            self.imagePickerVc?.dismiss(animated: true, completion: nil)
        }
        self.imagePickerVc?.didFinishPickingPhotosHandle = {[unowned self] (photos,assets,isOriginal) in
            let compressImg = CompressImgWith(img: photos?.first, maxKB: HEAD_IMG_MAX_MEMERY_SIZE)
            self.uploadHeadImgWith(img: compressImg)
        }
        self.present(self.imagePickerVc!, animated: true, completion: nil)
    }
    
    func uploadHeadImgWith(img:UIImage?){
        GetQiNiuUploadToken(type: .picture, onSuccess: { (tokenModel) in
            if let filePath = GenerateImgPathlWith(img: img){
                let fileName = uploadFileName(type: .picture)
                QiNiuUploadManager?.putFile(filePath, key: fileName, token: tokenModel?.token, complete: { (response, str, dic) in
                    //开始上传服务器
                    Toast.showStatusWith(text: "正在上传..")
                    let moyaProvider = MoyaProvider<LiMiAPI>()
                    let headImgUpLoad = HeadImgUpLoad(id: self.loginModel?.id, token: self.loginModel?.token, image: "/"+str!, type: "head")
                    _ = moyaProvider.rx.request(.targetWith(target: headImgUpLoad)).subscribe(onSuccess: { (response) in
                        do {
                            let model = try response.mapObject(BaseModel.self)
                            if model.commonInfoModel?.status == successState{
                                self.headImgBtn.setImage(img, for: .normal)
                            }
                            Toast.showResultWith(model: model)
                        }
                        catch{Toast.showErrorWith(msg: error.localizedDescription)}
                        self.imagePickerVc?.dismiss(animated: true, completion: nil)
                    }, onError: { (error) in
                        Toast.showErrorWith(msg: error.localizedDescription)
                    })
                    
                }, option: nil)
            }
        }, id: self.loginModel?.id?.stringValue(), token: self.loginModel?.token)
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
                let identityAuthInfoController = GetViewControllerFrom(sbName: .loginRegister ,sbID: "IdentityAuthInfoController") as! IdentityAuthInfoController
                self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
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
