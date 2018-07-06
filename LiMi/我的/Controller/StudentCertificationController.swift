//
//  StudentCertificationController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/3.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import TZImagePickerController

class StudentCertificationController: UITableViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var exampleImageView: UIImageView!
    @IBOutlet weak var authentificationImageView: UIImageView!
    ///证件图片链接
    var certificateImageUrl:String?
    
    var imagePickerVC:TZImagePickerController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "学生认证"
        self.tableView.estimatedRowHeight = 1000
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - actions
    @IBAction func selectImageButtonClicked(_ sender: Any) {
        self.imagePickerVC = TZImagePickerController.init()
        self.imagePickerVC?.maxImagesCount = 1
        self.imagePickerVC?.allowPickingGif = false
        self.imagePickerVC?.allowPickingVideo = false
        //self.imagePickerVC?.autoDismiss = true
        self.imagePickerVC?.didFinishPickingPhotosHandle = {[unowned self] (imgs,phAssets,bool) in
            FileUploadManager.share.uploadImagesWith(images: imgs, phAssets: (phAssets as? [PHAsset]?)!, successBlock: { (image, key) in
                self.authentificationImageView.image = image
                self.certificateImageUrl = key
            }, failedBlock: {
                
            }, completionBlock: {
            }, tokenIDModel: nil)
            
        }
        self.present(self.imagePickerVC!, animated: true, completion: nil)
    }
    
    @IBAction func dealToAuthenticate(_ sender: Any) {
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        if self.certificateImageUrl == nil{
            Toast.showErrorWith(msg: "请先上传证件图片")
            return
        }
        let perfectUserInfo = CenterPerfectUserInfo.init(identity_pic: "/\(self.certificateImageUrl!)")
        _ = moyaProvider.rx.request(.targetWith(target: perfectUserInfo)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
            
                Defaults[.userCertificationState] = 2
//                let identityAuthStateController = IdentityAuthStateController()
//                identityAuthStateController.isFromPersonCenter = false
//                self.navigationController?.popViewController(animated: true)
            }
            Toast.showResultWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}
