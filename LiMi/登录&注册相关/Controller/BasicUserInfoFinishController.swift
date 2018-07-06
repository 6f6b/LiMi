
//
//  BasicUserInfoFinishController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/2.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import TZImagePickerController

class BasicUserInfoFinishController: UITableViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    var loginModel:LoginModel?
    
    @IBOutlet weak var headBacgroundView: UIView!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var boyButton: UIButton!
    @IBOutlet weak var girlButton: UIButton!
    var imagePickerVc:TZImagePickerController?
    var selectSex:SexStatus?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 200
        
        let tapHead = UITapGestureRecognizer.init(target: self, action: #selector(tapedHeadBackgroundView))
        self.headBacgroundView.addGestureRecognizer(tapHead)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - actions
    @objc func tapedHeadBackgroundView(){
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
            let headImgUpLoad = HeadImgUpLoad(id: self.loginModel?.id, token: self.loginModel?.token, image: "/" + key, type: "head")
            _ = moyaProvider.rx.request(.targetWith(target: headImgUpLoad)).subscribe(onSuccess: {[unowned self] (response) in
                let pictureResultModel = Mapper<PictureResultModel>().map(jsonData: response.data)
                if pictureResultModel?.commonInfoModel?.status == successState{
                    if let url = pictureResultModel?.url{
                        print(url)
                        self.headImageView.kf.setImage(with: URL.init(string: url), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
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

    
    @IBAction func skipButtonClicked(_ sender: Any) {
        NotificationCenter.default.post(Notification.init(name: REGISTER_FINISHED_NOTIFICATION))
    }
    @IBAction func boyButtonClicked(_ sender: Any) {
        self.selectSex = .male
        self.boyButton.backgroundColor = RGBA(r: 79, g: 175, b: 253, a: 1)
        self.girlButton.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
    }
    @IBAction func girlButtonClicked(_ sender: Any) {
        self.selectSex = .female
        self.girlButton.backgroundColor = RGBA(r: 255, g: 100, b: 136, a: 1)
        self.boyButton.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        if IsEmpty(textField: self.nickName){
            Toast.showErrorWith(msg: "昵称不能为空")
            return
        }
        if self.selectSex == nil{
            Toast.showErrorWith(msg: "请选择性别")
            return
        }
        let sex:Int = self.selectSex == .male ? 1 : 0
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let perfectUserBasicInfo = PerfectUserBasicInfo.init(nickname: self.nickName.text, sex: sex, id: self.loginModel?.id, token: loginModel?.token)
        _ = moyaProvider.rx.request(.targetWith(target: perfectUserBasicInfo)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                NotificationCenter.default.post(Notification.init(name: REGISTER_FINISHED_NOTIFICATION))
                
            }
            Toast.showErrorWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
        //PerfectUserBasicInfo
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


}

extension BasicUserInfoFinishController:TZImagePickerControllerDelegate{
    
}
