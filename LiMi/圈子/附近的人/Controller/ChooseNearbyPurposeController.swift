//
//  ChooseNearbyPurposeController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/17.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import TZImagePickerController

protocol ChooseNearbyPurposeControllerDelegate : class {
    func chooseNearbyPurposeControllerClickedCancel()
}

class ChooseNearbyPurposeController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var photo: UIImageView!
    var imagePickerVC:TZImagePickerController?
    @IBOutlet weak var purposeContainView: UIView!
    var nearbyPurposeListView:NearbyPurposeListView?
    var selectedPurposes:String?
    var dataArray = [NearbyPurposeModel]()
    
    weak var delegate:ChooseNearbyPurposeControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.nearbyPurposeListView?.superview != nil{return}
        print("layout")
        nearbyPurposeListView = NearbyPurposeListView.init(frame: self.purposeContainView.bounds, maxSelectedNum: 3)
        self.nearbyPurposeListView?.delegate = self
        self.purposeContainView.addSubview(nearbyPurposeListView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setImageWith(key:String?){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let setUserPicture = SetUserPicture.init(images: key)
        _ = moyaProvider.rx.request(.targetWith(target: setUserPicture)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            Toast.showErrorWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let getSelfInfo = GetSelfInfo.init()
        _ = moyaProvider.rx.request(.targetWith(target: getSelfInfo)).subscribe(onSuccess: { (response) in
            let nearbyPurposeInfo = Mapper<NearbyPurposeInfo>().map(jsonData: response.data)
            if let _photo = nearbyPurposeInfo?.user?.photo{
                self.photo.kf.setImage(with: URL.init(string: _photo))
            }
            if let models = nearbyPurposeInfo?.target_list{
                for model in models{
                    self.dataArray.append(model)
                }
                self.nearbyPurposeListView?.reloadDataWith(models: models)
            }
            
            Toast.showErrorWith(model: nearbyPurposeInfo)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    //去选择真是照片
    @IBAction func dealToChoosePhoto(_ sender: Any) {
        self.imagePickerVC = TZImagePickerController.init()
        self.imagePickerVC?.maxImagesCount = 1
        self.imagePickerVC?.allowPickingGif = false
        self.imagePickerVC?.allowPickingVideo = false
        //self.imagePickerVC?.autoDismiss = true
        self.imagePickerVC?.didFinishPickingPhotosHandle = {[unowned self] (imgs,phAssets,bool) in
            FileUploadManager.share.uploadImagesWith(images: imgs, phAssets: (phAssets as? [PHAsset]?)!, successBlock: { (image, key) in
                self.photo.image = image
                self.setImageWith(key: "/\(key)")
            }, failedBlock: {
                Toast.showErrorWith(msg: "上传失败")
            }, completionBlock: {
            }, tokenIDModel: nil)
            
        }
        self.present(self.imagePickerVC!, animated: true, completion: nil)
    }
    
    //保存
    @IBAction func dealSave(_ sender: Any) {
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        LocationManager.shared.startLocateWith(success: { (location) in
            let latitude = location?.coordinate.latitude as? Double
            let longitude = location?.coordinate.longitude as? Double
            let purposes = self.nearbyPurposeListView?.clickedItemWith(clickedModel: nil)
            let setUserInfo = SetUserInfo.init(lat: latitude, lng: longitude, target: purposes)
            _ = moyaProvider.rx.request(.targetWith(target: setUserInfo)).subscribe(onSuccess: { (response) in
                let peopleNearbyContainModel = Mapper<PeopleNearbyContainModel>().map(jsonData: response.data)
                Toast.showErrorWith(model: peopleNearbyContainModel)
                if peopleNearbyContainModel?.commonInfoModel?.status == successState{
                    self.dismiss(animated: true, completion: nil)
                }
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }) { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        }

    }
    
    //关闭
    @IBAction func dealClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.chooseNearbyPurposeControllerClickedCancel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ChooseNearbyPurposeController : NearbyPurposeListViewDelegate{
    func nearbyPurposeListView(view: NearbyPurposeListView, selectedWith purposes: String) -> Bool {
        self.selectedPurposes = purposes
        return true
    }
}
