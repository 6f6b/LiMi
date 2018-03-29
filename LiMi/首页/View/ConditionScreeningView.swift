//
//  ConditionScreeningView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/25.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD
import ObjectMapper
import Moya
import Dispatch

class ConditionScreeningView: UIView {
    @IBOutlet weak var conditionContainView: UIView!
    @IBOutlet weak var leftTapView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var conditionContainViewRightConstraint: NSLayoutConstraint!
    private var subScreeningViews = [SecondaryConditionScreeningView]()
    ///学校段最大显示数
    private let maxNumShowCollege = 12
    ///学院最大显示数
    private let maxNumShowAcademy = 12
    ///年级最大显示数
    private let maxNumShowGrade = 12
    ///性别最大显示数
    private let maxNumShowSex = 12
    ///技能标签最大显示数
    private let maxNumShowSkill = 12

    
    var dataArray = [[ScreeningConditionsBaseModel]]()
    var selectedModels:[ScreeningConditionsBaseModel?] = [nil,nil,nil,nil,nil]
    var screeningConditionsSelectBlock:((CollegeModel?,AcademyModel?,GradeModel?,SexModel?,SkillModel?)->Void)?
    
//    var selectedCollegeModel:CollegeModel?
//    var selectedAcademyModel:AcademyModel?
//    var selectedGradeModel:GradeModel?
//    var selectedSex:SexModel?
//    var selectedSkillModel:SkillModel?
    
    var isCollegesShow = false
    var isAcademysShow = false
    var isGradeShow = false
    var isSexShow = false
    var isSkillsShow = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapG = UITapGestureRecognizer.init(target: self, action: #selector(dealCancel))
        self.leftTapView.addGestureRecognizer(tapG)
        
        let collectionFrame = CGRect.init(x: 0, y: 20, width: SCREEN_WIDTH*(600/750.0), height: SCREEN_HEIGHT-49-20)
        self.collectionView.frame = collectionFrame
        self.collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        self.collectionView.register(UINib.init(nibName: "ConditionScreeningCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ConditionScreeningCollectionCell")
        self.collectionView.register(ConditionScreeningHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ConditionScreeningHeaderView")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.conditionContainViewRightConstraint.constant = -SCREEN_WIDTH*(600.0/750)
    }

    static func shareConditionScreeningView()->ConditionScreeningView{
        let shareConditionScreeningView = GET_XIB_VIEW(nibName: "ConditionScreeningView") as! ConditionScreeningView
        return shareConditionScreeningView
    }
    
    //MARK: - misc
    @objc func dealCancel(){
        self.dismiss()
    }
    
    func show(animation:Bool = true){
        if self.dataArray.count == 0{self.loadData()}
        self.frame = SCREEN_RECT
        UIApplication.shared.keyWindow?.addSubview(self)
        if animation{
            let delayTime : TimeInterval = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: {
                    self.isHidden = false
                    UIView.animate(withDuration: 0.3, animations: {
                        //animation
                        self.conditionContainViewRightConstraint.constant = 0
                        self.layoutIfNeeded()
                    })
            })
        }
    }
    
    func dismiss(animation:Bool = true){
        if animation{
            let delayTime : TimeInterval = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: {
                UIView.animate(withDuration: 0.3, animations: {
                    //animation
                    self.conditionContainViewRightConstraint.constant = -SCREEN_WIDTH*(600.0/750)
                    self.layoutIfNeeded()
                }, completion: { (_) in
                    self.isHidden = true
                })
            })
        }
    }

    @IBAction func dealReset(_ sender: Any) {
        for i in 0 ..< 5{
            self.resetWith(section: i)
        }
    }
    
    func resetWith(section:Int){
        self.selectedModels[section] = nil
        for model in self.dataArray[section]{
            model.isSelected = false
        }
        self.collectionView.reloadSections([section])
    }
    
    @IBAction func dealOK(_ sender: Any) {
        if let _screeningConditionsSelectBlock = self.screeningConditionsSelectBlock{
            let selectedCollege = self.selectedModels[0] as? CollegeModel
            let selectedAcademy = self.selectedModels[1] as? AcademyModel
            let selectedGrade = self.selectedModels[2] as? GradeModel
            let selectedSex = self.selectedModels[3] as? SexModel
            let selectedSkill = self.selectedModels[4] as? SkillModel

            _screeningConditionsSelectBlock(selectedCollege, selectedAcademy, selectedGrade, selectedSex, selectedSkill)
            self.isHidden = true
        }
    }
    
    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let screeningConditions = ScreeningConditions()
        _ = moyaProvider.rx.request(.targetWith(target: screeningConditions)).subscribe(onSuccess: { (response) in
            let screeningConditionsModel = Mapper<ScreeningConditionsModel>().map(jsonData: response.data)
            if let datas = screeningConditionsModel?.datas{self.dataArray = datas}
            self.collectionView.reloadData()
            Toast.showErrorWith(model: screeningConditionsModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    //在collectionView中点选
    func dealTapWith(indexPath:IndexPath){
        //先取出这个元素selectedModel
        let selectedModel = self.dataArray[indexPath.section][indexPath.row]
        //记录这个元素的selected值
        let isSelected = selectedModel.isSelected
        //将对应section的选中model置空
        self.selectedModels[indexPath.section] = nil
        //遍历所有元素，置为false
        for model in self.dataArray[indexPath.section]{
            model.isSelected = false
        }
        //将selectedModel的selected值取反
        selectedModel.isSelected = !isSelected
        //判断选中则将对应section的选中model置为selectedModel
        if selectedModel.isSelected{
            self.selectedModels[indexPath.section] = selectedModel
        }
        if indexPath.section == 0{self.loadAcademysWith(collegeModel: self.selectedModels[0] as! CollegeModel)}
        self.collectionView.reloadSections([indexPath.section])
    }
    
    ///在次级界面点选回调
    func dealSelectedModelWith(section:Int,selectedModel:ScreeningConditionsBaseModel?){
        //先重置section
        self.resetWith(section: section)
        //为空则返回
        if selectedModel == nil{return}
        //不为空
        if selectedModel != nil{
            //遍历section内的元素。
            var nowSelectedModel:ScreeningConditionsBaseModel?
            for model in self.dataArray[section]{
                if model.id == selectedModel?.id{
                    model.isSelected = selectedModel!.isSelected
                    nowSelectedModel = model
                    break
                }
            }
            if nowSelectedModel == nil{nowSelectedModel = selectedModel}
            self.selectedModels[section] = nowSelectedModel
            self.collectionView.reloadSections([section])
        }
        if section == 0{self.loadAcademysWith(collegeModel: self.selectedModels[0] as! CollegeModel)}
    }
    
    ///返回最后一个cell显示的model
    func lastModelFor(indexPath:IndexPath)->ScreeningConditionsBaseModel?{
        let selectedModel = self.selectedModels[indexPath.section]
        for i in 0 ..< self.maxNumShowCollege-1{
            if selectedModel?.id == self.dataArray[indexPath.section][i].id{
                return nil
            }
        }
        return self.selectedModels[indexPath.section]
    }

    func loadAcademysWith(collegeModel:CollegeModel?){
        self.selectedModels[1] = nil
        if let _collegeModel = collegeModel{
            if _collegeModel.isSelected{
                let moyaProvider = MoyaProvider<LiMiAPI>()
                let academyList = AcademyList(collegeID: collegeModel?.coid?.stringValue())
                
                _ = moyaProvider.rx.request(.targetWith(target: academyList)).subscribe(onSuccess: { (response) in
                    let academyContainerModel = Mapper<AcademyContainerModel>().map(jsonData: response.data)
                    if let academys = academyContainerModel?.academies{
                        self.dataArray[1] = academys
                        self.collectionView.reloadSections([1])
                    }
                    Toast.showErrorWith(model: academyContainerModel)
                }, onError: { (error) in
                    Toast.showErrorWith(msg: error.localizedDescription)
                })
            }
            if !_collegeModel.isSelected{
                self.dataArray[1].removeAll()
                self.collectionView.reloadSections([1])
            }
        }
    }
    
    func push(secondaryConditionScreeningView:SecondaryConditionScreeningView?,animation:Bool = true){
        if let _secondaryConditionScreeningView = secondaryConditionScreeningView{
            //加入数组
            _secondaryConditionScreeningView.navigationView = self
            self.subScreeningViews.append(_secondaryConditionScreeningView)
            self.conditionContainView.addSubview(_secondaryConditionScreeningView)
            _secondaryConditionScreeningView.snp.makeConstraints({[unowned self] (make) in
                make.top.equalTo(self.conditionContainView)
                make.left.equalTo(self.conditionContainView).offset(SCREEN_WIDTH*(600/750.0))
                make.bottom.equalTo(self.conditionContainView)
                make.width.equalTo(SCREEN_WIDTH*(600/750.0))
            })
            let delayTime : TimeInterval = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: {
                UIView.animate(withDuration: 0.3, animations: {
                    _secondaryConditionScreeningView.snp.remakeConstraints({[unowned self] (make) in
                        make.top.equalTo(self.conditionContainView)
                        make.left.equalTo(self.conditionContainView).offset(0)
                        make.bottom.equalTo(self.conditionContainView)
                        make.width.equalTo(SCREEN_WIDTH*(600/750.0))
                    })
                    self.layoutIfNeeded()
                })
            })
        }
    }
    func popView(){
        if let _secondaryConditionScreeningView = self.subScreeningViews.last{
            UIView.animate(withDuration: 0.3, animations: {
                _secondaryConditionScreeningView.snp.remakeConstraints({ (make) in
                    make.top.equalTo(self.conditionContainView)
                    make.left.equalTo(self.conditionContainView).offset(SCREEN_WIDTH*(600/750.0))
                    make.bottom.equalTo(self.conditionContainView)
                    make.width.equalTo(SCREEN_WIDTH*(600/750.0))
                })
                self.layoutIfNeeded()
            }, completion: { [unowned self] _ in
                self.subScreeningViews.removeLast()
                _secondaryConditionScreeningView.removeFromSuperview()
            })
        }
    }
}

extension ConditionScreeningView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dataArray.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let models = self.dataArray[section]
        if section == 0{
            if isCollegesShow{
                return models.count < self.maxNumShowCollege ? models.count : self.maxNumShowCollege
            }else{
                return models.count >=  3 ? 3 : models.count
            }
        }
        if section == 1{
            if isAcademysShow{
                return models.count < self.maxNumShowAcademy ? models.count : self.maxNumShowAcademy
            }else{
                return models.count >=  3 ? 3 : models.count
            }
        }
        if section == 2{
            if isGradeShow{
                return models.count < self.maxNumShowGrade ? models.count : self.maxNumShowGrade
            }else{
                return models.count >=  3 ? 3 : models.count
            }
        }
        if section == 3{
            if isSexShow{
                return models.count < self.maxNumShowSex ? models.count : self.maxNumShowSex
            }else{
                return models.count >=  3 ? 3 : models.count
            }
        }
        if section == 4{
            if isSkillsShow{
                return models.count < self.maxNumShowSkill ? models.count : self.maxNumShowSkill
            }else{
                return models.count >=  3 ? 3 : models.count
            }
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConditionScreeningCollectionCell", for: indexPath) as! ConditionScreeningCollectionCell
        var model:ScreeningConditionsBaseModel?
        if indexPath.row < maxNumShowCollege-1{
            model = self.dataArray[indexPath.section][indexPath.row]
        }
        if indexPath.row >= maxNumShowCollege-1{
            model = self.lastModelFor(indexPath: indexPath)
        }

        if indexPath.row < maxNumShowCollege-1{
            cell.configWith(model: model, isLast: false)
        }
        if indexPath.row >= maxNumShowCollege-1{
            cell.configWith(model: model, isLast: true)
        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            let size = CGSize.init(width: (SCREEN_WIDTH*(600.0/750)-31)/3.0, height: 44)
            return size
        }
        let size = CGSize.init(width: (SCREEN_WIDTH*(600.0/750)-31)/3.0, height: 33)
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerSize = CGSize(width: SCREEN_WIDTH, height: 50)
        return headerSize
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ConditionScreeningHeaderView", for: indexPath) as! ConditionScreeningHeaderView

        if indexPath.section == 0{
            headerView.headImgV.image = UIImage.init(named: "sx_icon_school")
            headerView.spreadBtn.isSelected = !self.isCollegesShow
            headerView.info.text = "学校"
        }
        if indexPath.section == 1{
            headerView.headImgV.image = UIImage.init(named: "sx_icon_zhuanye")
            headerView.spreadBtn.isSelected = !self.isAcademysShow
            headerView.info.text = "学院"
        }
        if indexPath.section == 2{
            headerView.headImgV.image = UIImage.init(named: "sx_icon_ruxue")
            headerView.spreadBtn.isSelected = !self.isGradeShow
            headerView.info.text = "入学年份"
        }
        if indexPath.section == 3{
            headerView.headImgV.image = UIImage.init(named: "sx_icon_xingbie")
            headerView.spreadBtn.isSelected = !self.isSexShow
            headerView.info.text = "性别"
        }
        if indexPath.section == 4{
            headerView.headImgV.image = UIImage.init(named: "sx_icon_biaoqian")
            headerView.spreadBtn.isSelected = !self.isSkillsShow
            headerView.info.text = "需求标签"
        }
        headerView.spreadBlock = {[unowned self] isSpread in
            if indexPath.section == 0{self.isCollegesShow = !isSpread}
            if indexPath.section == 1{self.isAcademysShow = !isSpread}
            if indexPath.section == 2{self.isGradeShow = !isSpread}
            if indexPath.section == 3{self.isSexShow = !isSpread}
            if indexPath.section == 4{self.isSkillsShow = !isSpread}
            self.collectionView.reloadSections([indexPath.section])
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < self.maxNumShowCollege-1{
            self.dealTapWith(indexPath: indexPath)
        }
        if indexPath.row >= self.maxNumShowCollege-1{
            if indexPath.section == 0{
                //显示二级筛选
                let secondaryConditionScreeningSchool = SecondaryConditionScreeningSchool()
                secondaryConditionScreeningSchool.selectedCollegeModel = self.selectedModels[indexPath.section] as? CollegeModel
                secondaryConditionScreeningSchool.selecteBlock = {[unowned self] (selectedModel) in
                    self.dealSelectedModelWith(section: indexPath.section, selectedModel: selectedModel)
                }
                self.push(secondaryConditionScreeningView: secondaryConditionScreeningSchool)
            }
            if indexPath.section == 1{
                let secondaryConditionScreeningAcademy = SecondaryConditionScreeningAcademy()
                secondaryConditionScreeningAcademy.selectedCollegeModel = self.selectedModels[0] as? CollegeModel
                secondaryConditionScreeningAcademy.selectedAcademyModel = self.selectedModels[indexPath.section] as? AcademyModel
                secondaryConditionScreeningAcademy.selecteBlock = {[unowned self] (selectedModel) in
                    self.dealSelectedModelWith(section: indexPath.section, selectedModel: selectedModel)
                }
                self.push(secondaryConditionScreeningView: secondaryConditionScreeningAcademy)
            }
            if indexPath.section == 2{
                let secondaryConditionScreeningGrade = SecondaryConditionScreeningGrade()
                secondaryConditionScreeningGrade.selectedGradeModel = self.selectedModels[indexPath.section] as? GradeModel
                secondaryConditionScreeningGrade.selecteBlock = {[unowned self] (selectedModel) in
                    self.dealSelectedModelWith(section: indexPath.section, selectedModel: selectedModel)
                }
                self.push(secondaryConditionScreeningView: secondaryConditionScreeningGrade)
            }
            if indexPath.section == 4{
                let secondaryConditionScreeningSkills = SecondaryConditionScreeningSkills()
                secondaryConditionScreeningSkills.selectedSkillModel = self.selectedModels[indexPath.section] as? SkillModel
                secondaryConditionScreeningSkills.selecteBlock = {[unowned self] (selectedModel) in
                    self.dealSelectedModelWith(section: indexPath.section, selectedModel: selectedModel)
                }
                self.push(secondaryConditionScreeningView: secondaryConditionScreeningSkills)
            }
        }
    }
}
