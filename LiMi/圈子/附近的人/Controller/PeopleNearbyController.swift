//
//  PeopleNearbyController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import SVProgressHUD
import MJRefresh
import IQKeyboardManagerSwift

let collectionViewTopAndBottomSpace = CGFloat(15.0)
let collectionViewLeftAndRightSpace = CGFloat(15.0)
let collectionItemHorizontalSpace = CGFloat(15.0)
let collectionItemVerticalSpace = CGFloat(15.0)

class PeopleNearbyController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var topContainView: UIView!
    @IBOutlet weak var userNickName: UILabel!
    @IBOutlet weak var sexImageView: UIImageView!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var time: UILabel!
    var isAdjustFrame = false
    @IBOutlet weak var carousel: iCarousel!
    //    var collectionView: UICollectionView!
    var dataArray = [FoolishUserInfoModel]()
    var pageIndex = 1
    var sex:Int? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "附近的人"
        
        carousel.isPagingEnabled = true
        carousel.type = .invertedTimeMachine
        
        let filterButton = UIButton.init(type: .custom)
        filterButton.frame = CGRect.init(x: 0, y: 0, width: 25, height: 25)
        filterButton.setImage(UIImage.init(named: "fjr_ic_shaixuan"), for: .normal)
        filterButton.addTarget(self, action: #selector(dealToChooseFilterCondition), for: .touchUpInside)

        let fillInformationButton = UIButton.init(type: .custom)
        fillInformationButton.frame = CGRect.init(x: 0, y: 0, width: 25, height: 25)
        fillInformationButton.setImage(UIImage.init(named: "fjr_ic_xgzl"), for: .normal)
        fillInformationButton.addTarget(self, action: #selector(dealToEditPurpose), for: .touchUpInside)

        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: filterButton),UIBarButtonItem.init(customView: fillInformationButton)]
        
        if Defaults[.isMindedToFinishSignatureInNearby] != true{
            Defaults[.isMindedToFinishSignatureInNearby] = true
        }
        
        self.refreshUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isAdjustFrame{return}
        isAdjustFrame = true
        let width = SCREEN_WIDTH - 60
        let height = (SCREEN_WIDTH-60) * (420.0/315.0)
        self.carousel.frame = CGRect.init(x: 15, y: self.topContainView.frame.maxY+15, width: width, height: height)
    }
    
    //编辑我的purpose
    @objc func dealToEditPurpose(){
        let chooseNearbyPurposeController = ChooseNearbyPurposeController()
        chooseNearbyPurposeController.delegate = self
        self.present(chooseNearbyPurposeController, animated: true, completion: nil)
    }
    
    //编辑我的筛选条件
    @objc func dealToChooseFilterCondition(){
        let purposeScreeningController = PurposeScreeningController()
        self.present(purposeScreeningController, animated: true, completion: nil)
    }
    
    @objc func dealMoreOperation(){
        //只看女生、只看男生、查看全部人、编辑我的个性签名、清除我的位置信息并退出
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionOnlyGirl = UIAlertAction(title: "只看女生", style: .default) { (_) in
            self.sex = 0
            self.loadData()
            print("只看女生")
        }
        let actionOnlyBoy = UIAlertAction(title: "只看男生", style: .default) { (_) in
            self.sex = 1
            self.loadData()
            print("只看男生")
        }
        let actionLookAll = UIAlertAction(title: "查看全部", style: .default) { (_) in
            self.sex = nil
            self.loadData()
            print("查看全部")
        }
        let actionEditMyAutograph = UIAlertAction(title: "编辑个性签名", style: .default) { (_) in
            let editAutographView = GET_XIB_VIEW(nibName: "EditAutographView") as! EditAutographView
            editAutographView.frame = SCREEN_RECT
            UIApplication.shared.keyWindow?.addSubview(editAutographView)
            print("编辑个性签名")
        }
        let actionExitAndClearLocationInfo = UIAlertAction(title: "清除位置信息并退出", style: .default) { (_) in
            self.dealExitAndClearLocationInfo()
            print("清除位置信息并退出")
        }
        let actionCancel = UIAlertAction(title: "取消", style: .cancel) { (_) in
            print("取消")
        }
        alertController.addAction(actionOnlyGirl)
        alertController.addAction(actionOnlyBoy)
        alertController.addAction(actionLookAll)
        alertController.addAction(actionEditMyAutograph)
        alertController.addAction(actionExitAndClearLocationInfo)
        alertController.addAction(actionCancel)

        self.present(alertController, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = APP_THEME_COLOR_1
        
        if self.dataArray.count == 0{
            self.checkUserStatus()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    deinit {
        print("附近的人销毁")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func checkUserStatus(){
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let checkUserInfo = CheckUserInfo.init()
        _ = moyaProvider.rx.request(.targetWith(target: checkUserInfo)).subscribe(onSuccess: {[unowned self] (response) in
            let checkUserStatusModel = Mapper<CheckUserStatusModel>().map(jsonData: response.data)
            if checkUserStatusModel?.status == 0{
                self.loadData()
            }else{
                let chooseNearbyPurposeController = ChooseNearbyPurposeController()
                self.present(chooseNearbyPurposeController, animated: true, completion: nil)
            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    //MARK: - misc
    func loadData(){
            requestData()
    }
    
    func requestData(){
        self.dataArray.removeAll()
        LocationManager.shared.startLocateWith(success: { (location) in
            let latitude = location?.coordinate.latitude as? Double
            let longitude = location?.coordinate.longitude as? Double
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            let nearUserList = NearUserList.init(lng: longitude, lat: latitude)
            _ = moyaProvider.rx.request(.targetWith(target: nearUserList)).subscribe(onSuccess: { (response) in
                let peopleNearbyContainModel = Mapper<PeopleNearbyContainModel>().map(jsonData: response.data)
                if let userInfoModels = peopleNearbyContainModel?.data{
                    for userInfoModel in userInfoModels{
                        self.dataArray.append(userInfoModel)
                    }
                }
                self.refreshUI()
                self.carousel.reloadData()
                Toast.showErrorWith(model: peopleNearbyContainModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }) { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        }
    }
    
    func refreshUI(){
        let isEmptyData = self.dataArray.count == 0 ? true : false
        self.userNickName.isHidden = isEmptyData
        self.distance.isHidden = isEmptyData
        self.time.isHidden = isEmptyData
        self.sexImageView.isHidden = isEmptyData
        self.age.isHidden = isEmptyData
    }
    
    //退出并清除位置信息
    func dealExitAndClearLocationInfo(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let clearLocation = ClearLocation()
        _ = moyaProvider.rx.request(.targetWith(target: clearLocation)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            //成功
            if baseModel?.commonInfoModel?.status == successState{
                //延时1秒执行
                let delayTime : TimeInterval = 1.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                    Toast.dismiss()
                    self.navigationController?.popViewController(animated: true)
                }
            }
            Toast.showResultWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}

extension PeopleNearbyController : iCarouselDelegate,iCarouselDataSource{
    func numberOfItems(in carousel: iCarousel) -> Int {
        return self.dataArray.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let width = SCREEN_WIDTH - 60
        let height = (SCREEN_WIDTH-60) * (420.0/315.0)
        
        let nearbyPeoplePhotoView = NearbyPeoplePhotoView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        let model = self.dataArray[index]
        nearbyPeoplePhotoView.configWith(model: model)
        return nearbyPeoplePhotoView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let index = carousel.currentItemIndex
        if self.dataArray.count == 0 || index >= self.dataArray.count{return}
        let model = self.dataArray[index]
        self.userNickName.text = model.nickname
        if model.sex == 0{
            self.sexImageView.image = UIImage.init(named: "me_ic_boy")
        }else{
            self.sexImageView.image = UIImage.init(named: "me_ic_girl")
        }
        if let _age = model.age{
            self.age.text = "\(_age)岁"
        }
        self.distance.text = model.distance
        self.time.text = model.active_time
    }

    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        let nearbyPeopleDetailsController = NearbyPeopleDetailsController()
        let model = self.dataArray[index]
        nearbyPeopleDetailsController.userInfoModel = model
        let navNearbyPeopleDetailsController = CustomNavigationController.init(rootViewController: nearbyPeopleDetailsController)
        self.present(navNearbyPeopleDetailsController, animated: true, completion: nil)
    }
    

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .wrap:
            return 0
        case .spacing:
            return value*0.7
        case .fadeMax:
            if self.carousel.type == .custom{
                return 0.0
            }else{
                return value
            }
        default:
            return value
        }
    }
}

extension PeopleNearbyController : ChooseNearbyPurposeControllerDelegate{
    func chooseNearbyPurposeControllerClickedCancel() {
        if self.dataArray.count == 0{self.navigationController?.popViewController(animated: true)}
        return
    }
}

