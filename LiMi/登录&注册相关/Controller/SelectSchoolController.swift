//
//  SelectSchoolController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/2.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class SelectSchoolController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    var loginModel:LoginModel?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dissmissTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    
    var selectedModel:CollegeModel?
    var selectedIndex:Int?
    var dataArray = [CollegeModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UINib.init(nibName: "SchoolCell", bundle: nil), forCellWithReuseIdentifier: "SchoolCell")
        self.collectionView.register(SeletSchoolHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SeletSchoolHeaderView")
        self.collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 15)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.requestData()
    }

    func requestData(){
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let collegeList = CollegeList(college: nil)
        
        _ = moyaProvider.rx.request(.targetWith(target: collegeList)).subscribe(onSuccess: { (response) in
            let collegeContainerModel = Mapper<CollegeContainerModel>().map(jsonData: response.data)
            if let colleges = collegeContainerModel?.colleges{
                for college in colleges{
                    self.dataArray.append(college)
                }
                self.collectionView.reloadData()
            }
            Toast.showErrorWith(model: collegeContainerModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dissMissButtonClicked(_ sender: Any) {
        let alertVC = UIAlertController.init(title: "关闭页面，将无法保存你的登录信息", message: nil, preferredStyle: .alert)
        let actionOK = UIAlertAction.init(title: "关闭", style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(actionOK)
        alertVC.addAction(actionCancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if self.selectedModel == nil{
            Toast.showErrorWith(msg: "请先选择学校")
            return
        }
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let setSchool = SetSchool.init(college_id: self.selectedModel?.id, id: self.loginModel?.id, token: self.loginModel?.token)
        _ = moyaProvider.rx.request(.targetWith(target: setSchool)).subscribe(onSuccess: { (response) in
            let loginModel = Mapper<LoginModel>().map(jsonData: response.data)
            if loginModel?.commonInfoModel?.status == successState{
                Defaults[.userId] = loginModel?.id
                Defaults[.userToken] = loginModel?.token
                let basicUserInfoFinishController = GetViewControllerFrom(sbName: .loginRegister, sbID: "BasicUserInfoFinishController") as! BasicUserInfoFinishController
                basicUserInfoFinishController.loginModel = loginModel
                self.present(basicUserInfoFinishController, animated: true, completion: nil)
            }
            Toast.showErrorWith(model: loginModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }

}

extension SelectSchoolController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.dataArray.count == 0{return 0}
        return self.dataArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let seletSchoolHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SeletSchoolHeaderView", for: indexPath) as! SeletSchoolHeaderView
        return seletSchoolHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let schoolCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SchoolCell", for: indexPath) as! SchoolCell
        let isSelected = indexPath.row == self.selectedIndex ? true : false
        let isLast = indexPath.row == self.dataArray.count ? true : false
        var collegeModel:CollegeModel?
        if !isLast{
            collegeModel = self.dataArray[indexPath.row]
        }
        if isLast{
            if self.selectedIndex == self.dataArray.count{
                collegeModel = self.selectedModel
            }
        }
        schoolCell.configWith(model: collegeModel, isLast: isLast, isSelected: isSelected)
        return schoolCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        
        if indexPath.row == self.dataArray.count{
            let schoolListController = SchoolListController()
            schoolListController.delegate = self
            self.present(schoolListController, animated: true, completion: nil)
        }else{
            self.selectedModel = self.dataArray[indexPath.row]
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: SCREEN_WIDTH, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.dataArray.count == 0{return CGSize.zero}
        let isLast = indexPath.row == self.dataArray.count ? true : false
        var size = CGSize.init(width: 100, height: 38)

        if !isLast{
            let collegeModel = self.dataArray[indexPath.row]
            if let name = collegeModel.name{
                let textSize = name.sizeWith(limitWidth: 1000, font: 16)
                size.width = textSize.width + 50
            }
        }
        if isLast{
            if self.selectedIndex == self.dataArray.count{
                if let name = self.selectedModel?.name{
                    let textSize = name.sizeWith(limitWidth: 1000, font: 16)
                    size.width = textSize.width+25+45
                }
            }else{
                let textSize = "没有你的学校？快去搜索吧".sizeWith(limitWidth: 1000, font: 16)
                size.width = textSize.width+25+45
            }
        }
        return size
    }
}

extension SelectSchoolController:SchoolListControllerDelegate{
    func schoolListControllerCancelButtonClicked() {
        
    }
    
    func schoolListControllerChoosedSchoolWith(model: CollegeModel) {
        //先判断原数组有没有
        for i in 0..<self.dataArray.count{
            if self.dataArray[i].id == model.id{
                self.selectedIndex = i
                self.selectedModel = model
                self.collectionView.reloadData()
                self.dismiss(animated: true, completion: nil)
                return
            }
        }
        self.selectedIndex = self.dataArray.count
        self.selectedModel = model
        self.collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}
