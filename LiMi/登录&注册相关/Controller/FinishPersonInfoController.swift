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

class FinishPersonInfoController: ViewController {
    @IBOutlet weak var realName: UITextField!
    @IBOutlet weak var girlPreImg: UIImageView!
    @IBOutlet weak var boyPreImg: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var headImgBtn: UIButton!
    var imagePickerVc:TZImagePickerController?
    var headImg:UIImage?
    var userIdParameters:Int?
    var tokenParameters:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "完善个人信息"
        self.nextBtn.layer.cornerRadius = 20
        self.nextBtn.clipsToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    //选择男性
    @IBAction func dealSelectBoy(_ sender: Any) {
        self.boyPreImg.isHidden = false
        self.girlPreImg.isHidden = true
    }
    
    //选择女性
    @IBAction func dealSelectGirl(_ sender: Any) {
        self.boyPreImg.isHidden = true
        self.girlPreImg.isHidden = false
    }
    
    @IBAction func dealTapHeadImg(_ sender: Any) {
        self.imagePickerVc = TZImagePickerController.init(maxImagesCount: 1, delegate: self)
        self.imagePickerVc?.didFinishPickingPhotosHandle = {(photos,assets,isOriginal) in
            if let loadImg = photos?.first{
                self.headImg = loadImg
                self.uploadWith(img: loadImg)
            }
        }
        self.present(self.imagePickerVc!, animated: true, completion: nil)
    }
    
    func uploadWith(img:UIImage){
                SVProgressHUD.show(withStatus: "正在上传..")
                let moyaProvider = MoyaProvider<LiMiAPI>()
                let headImgUpLoad = HeadImgUpLoad(id: self.userIdParameters?.stringValue(), token: tokenParameters, imgs: [img])
                _ = moyaProvider.rx.request(.targetWith(target: headImgUpLoad)).subscribe(onSuccess: { (response) in
                    do {
                        let model = try response.mapObject(BaseModel.self)
                        if model.commonInfoModel?.flag == successState{
                            self.headImgBtn.setImage(self.headImg, for: .normal)
                        }
                        SVProgressHUD.showResultWith(model: model)
                    }
                    catch{SVProgressHUD.showErrorWith(msg: error.localizedDescription)}
                }, onError: { (error) in
                    SVProgressHUD.showErrorWith(msg: error.localizedDescription)
                })
    }
    
    //下一步
    @IBAction func dealTapNext(_ sender: Any) {
        //判断是否选择了性别
        if self.boyPreImg.isHidden == true && self.girlPreImg.isHidden == true{
            SVProgressHUD.showError(withStatus: "请选择性别")
            return
        }
        //判断是否填写了姓名
        if isEmpty(textField: self.realName){
            SVProgressHUD.showError(withStatus: "请输入姓名")
            return
        }
        SVProgressHUD.show(withStatus: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let sex = self.girlPreImg.isHidden ? 1:0
        let registerFinishNameAndSex = RegisterFinishNameAndSex(id: userIdParameters?.stringValue(), token: tokenParameters, true_name: self.realName.text, sex: sex.stringValue())
        _ = moyaProvider.rx.request(.targetWith(target: registerFinishNameAndSex)).subscribe(onSuccess: { (response) in
            do {
                let model = try response.mapObject(TmpAuthCodeModel.self)
                if model.commonInfoModel?.flag == successState{
                    SVProgressHUD.dismiss()
                    let identityAuthInfoController = Helper.getViewControllerFrom(sbName: .loginRegister ,sbID: "IdentityAuthInfoController") as! IdentityAuthInfoController
                    identityAuthInfoController.sexParameter = self.girlPreImg.isHidden ? 1:0
                    identityAuthInfoController.nameParameter = self.realName.text
                    self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
                }else{
                    SVProgressHUD.showResultWith(model: model)
                }
                
            }
            catch{SVProgressHUD.showErrorWith(msg: error.localizedDescription)}
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    
}

extension FinishPersonInfoController:TZImagePickerControllerDelegate{
//    func imag
}
