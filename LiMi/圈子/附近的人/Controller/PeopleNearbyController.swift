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
    @IBOutlet weak var collectionView: UICollectionView!
//    var collectionView: UICollectionView!
    var dataArray = [UserInfoModel]()
    var pageIndex = 1
    var sex:Int? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "附近的人"

        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
        self.collectionView.contentInset = UIEdgeInsets.init(top: 0, left: collectionViewLeftAndRightSpace, bottom: 0, right: collectionViewLeftAndRightSpace)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.collectionView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        self.collectionView.register(UINib.init(nibName: "NearbyPeopleCollectionCell", bundle: nil), forCellWithReuseIdentifier: "NearbyPeopleCollectionCell")
        
        
        let moreOperationBtn = UIButton.init(type: .custom)
        moreOperationBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
//        moreOperationBtn.backgroundColor = UIColor.red
        moreOperationBtn.setImage(UIImage.init(named: "nav_btn_jubao_black"), for: .normal)
        moreOperationBtn.addTarget(self, action: #selector(dealMoreOperation), for: .touchUpInside)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: moreOperationBtn),UIBarButtonItem.init(customView: UIButton())]
//        self.navigationItem.rightBarButtonItem =
        
        self.loadData()
        if Defaults[.isMindedToFinishSignatureInNearby] != true{
            Defaults[.isMindedToFinishSignatureInNearby] = true
            let editAutographView = GET_XIB_VIEW(nibName: "EditAutographView") as! EditAutographView
            editAutographView.frame = SCREEN_RECT
            UIApplication.shared.keyWindow?.addSubview(editAutographView)
        }
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
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
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

    //MARK: - misc
    func loadData(){
        if nil == LocationManager.shared.location{
            LocationManager.shared.startLocateWith(success: {[weak self] (_) in
                self?.requestData()
            }, failed: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }else{
            requestData()
        }
    }
    
    func requestData(){
        //        NearUserList
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let latitude = LocationManager.shared.location?.coordinate.latitude.stringValue()
        let longitude = LocationManager.shared.location?.coordinate.longitude.stringValue()
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let nearUserList = NearUserList(lat: latitude, lng: longitude, page: pageIndex, sex: sex)
        _ = moyaProvider.rx.request(.targetWith(target: nearUserList)).subscribe(onSuccess: { (response) in
            let peopleNearbyContainModel = Mapper<PeopleNearbyContainModel>().map(jsonData: response.data)
            if let userInfoModels = peopleNearbyContainModel?.data{
                for userInfoModel in userInfoModels{
                    self.dataArray.append(userInfoModel)
                }
            }
            self.collectionView.reloadData()
            self.collectionView.mj_footer.endRefreshing()
            self.collectionView.mj_header.endRefreshing()
            Toast.showErrorWith(model: peopleNearbyContainModel)
        }, onError: { (error) in
            self.collectionView.mj_footer.endRefreshing()
            self.collectionView.mj_header.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
        })
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

extension PeopleNearbyController:UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if 0 == section{return 0}
       return  self.dataArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWith = (SCREEN_WIDTH-collectionItemHorizontalSpace-collectionViewLeftAndRightSpace*2-1)/2.0
        let itemHeight = itemWith + 60
        return CGSize.init(width: itemWith, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionItemVerticalSpace
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionItemHorizontalSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if 0 == section{
            return CGSize.init(width: 0, height: collectionViewTopAndBottomSpace)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if 1 == section{
            return CGSize.init(width: 0, height: collectionViewTopAndBottomSpace)
        }
        return CGSize.zero
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let nearbyPeopleCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyPeopleCollectionCell", for: indexPath) as! NearbyPeopleCollectionCell
        nearbyPeopleCollectionCell.configWith(model: self.dataArray[indexPath.row])
        return nearbyPeopleCollectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userDetailsController = UserDetailsController()
        userDetailsController.userId = self.dataArray[indexPath.row].user_id!
        self.navigationController?.pushViewController(userDetailsController, animated: true)
    }
}
