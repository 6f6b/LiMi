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
    
    var screeningConditionsModel:ScreeningConditionsModel?
    var screeningConditionsSelectBlock:((CollegeModel?,AcademyModel?,GradeModel?,SexModel?,SkillModel?)->Void)?
    var selectedCollegeModelIndex:Int?
    var selectedAcademyModelIndex:Int?
    var selectedGradeModelIndex:Int?
    var selectedSexIndex:Int?
    var selectedSkillModelIndex:Int?
    
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
        
        self.loadData()
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
        if let colleges = self.screeningConditionsModel?.college{
            for _college in colleges{
                _college.isSelected = false
            }
        }
        //学校
        if let academies = self.screeningConditionsModel?.academy{
            for _academy in academies{
                _academy.isSelected = false
            }
        }
        //年级
        if let grades = self.screeningConditionsModel?.grade{
            for _grade in grades{
                _grade.isSelected = false
            }
        }
        //性别
        if let sexs = self.screeningConditionsModel?.sex{
            for _sex in sexs{
                _sex.isSelected = false
            }
        }
        //skill
        if let skills = self.screeningConditionsModel?.skill{
            for _skill in skills{
                _skill.isSelected = false
            }
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func dealOK(_ sender: Any) {
        var college:CollegeModel? = nil
        var academy:AcademyModel? = nil
        var grade:GradeModel? = nil
        var sex:SexModel? = nil
        var skill:SkillModel? = nil
        if let colleges = self.screeningConditionsModel?.college{
            for _college in colleges{
                if _college.isSelected{
                    college = _college
                    break
                }
            }
        }
        //学校
        if let academies = self.screeningConditionsModel?.academy{
            for _academy in academies{
                if _academy.isSelected{
                    academy = _academy
                    break
                }
            }
        }
        //年级
        if let grades = self.screeningConditionsModel?.grade{
            for _grade in grades{
                if _grade.isSelected{
                    grade = _grade
                    break
                }
            }
        }
        //性别
        if let sexs = self.screeningConditionsModel?.sex{
            for _sex in sexs{
                if _sex.isSelected{
                    sex = _sex
                    break
                }
            }
        }
        //skill
        if let skills = self.screeningConditionsModel?.skill{
            for _skill in skills{
                if _skill.isSelected{
                    skill = _skill
                }
            }
        }
        if let _screeningConditionsSelectBlock = self.screeningConditionsSelectBlock{
            _screeningConditionsSelectBlock(college, academy, grade, sex, skill)
            self.isHidden = true
        }
    }
    
    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let screeningConditions = ScreeningConditions()
        _ = moyaProvider.rx.request(.targetWith(target: screeningConditions)).subscribe(onSuccess: { (response) in
            let screeningConditionsModel = Mapper<ScreeningConditionsModel>().map(jsonData: response.data)
            self.screeningConditionsModel = screeningConditionsModel
            HandleResultWith(model: screeningConditionsModel)
            self.collectionView.reloadData()
            SVProgressHUD.showErrorWith(model: screeningConditionsModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func loadAcademysWith(collegeModel:CollegeModel?){
        if let _collegeModel = collegeModel{
            if _collegeModel.isSelected{
                let moyaProvider = MoyaProvider<LiMiAPI>()
                let academyList = AcademyList(collegeID: collegeModel?.coid?.stringValue())
                
                _ = moyaProvider.rx.request(.targetWith(target: academyList)).subscribe(onSuccess: { (response) in
                    let academyContainerModel = Mapper<AcademyContainerModel>().map(jsonData: response.data)
                    if let academys = academyContainerModel?.academies{
                        self.screeningConditionsModel?.academy = academys
                        self.collectionView.reloadSections([1])
                    }
                    SVProgressHUD.showErrorWith(model: academyContainerModel)
                }, onError: { (error) in
                    SVProgressHUD.showErrorWith(msg: error.localizedDescription)
                })
            }
            if !_collegeModel.isSelected{
                self.screeningConditionsModel?.academy = nil
                self.collectionView.reloadSections([1])
            }
        }
    }
}

extension ConditionScreeningView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            if isCollegesShow{
                if let colleges = self.screeningConditionsModel?.college{
                    return colleges.count
                }
            }else{
                if let colleges = self.screeningConditionsModel?.college{
                    return colleges.count >= 3 ? 3 : colleges.count
                }
            }
        }
        if section == 1{
            if isAcademysShow{
                if let academies = self.screeningConditionsModel?.academy{
                    return academies.count
                }
            }else{
                if let academies = self.screeningConditionsModel?.academy{
                    return academies.count >= 3 ? 3 : academies.count
                }
            }
        }
        if section == 2{
            if isGradeShow{
                if let grades = self.screeningConditionsModel?.grade{
                    return grades.count
                }
            }else{
                if let grades = self.screeningConditionsModel?.grade{
                    return grades.count >= 3 ? 3 : grades.count
                }
            }
        }
        if section == 3{
            if isSexShow{
                if let sex = self.screeningConditionsModel?.sex{
                    return sex.count
                }
            }else{
                if let sex = self.screeningConditionsModel?.sex{
                    return sex.count >= 3 ? 3 : sex.count
                }
            }
        }
        if section == 4{
            if isSkillsShow{
                if let skills = self.screeningConditionsModel?.skill{
                    return skills.count
                }
            }else{
                if let skills = self.screeningConditionsModel?.skill{
                    return skills.count >= 3 ? 3 : skills.count
                }
            }
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConditionScreeningCollectionCell", for: indexPath) as! ConditionScreeningCollectionCell
        if indexPath.section == 0{
            cell.configWith(collegeModel: self.screeningConditionsModel?.college![indexPath.row])
        }
        if indexPath.section == 1{
            cell.configWith(academyModel: self.screeningConditionsModel?.academy![indexPath.row])
        }
        if indexPath.section == 2{
            cell.configWith(gradeModel: self.screeningConditionsModel?.grade![indexPath.row])
        }
        if indexPath.section == 3{
            cell.configWith(sex: self.screeningConditionsModel?.sex![indexPath.row])
        }
        if indexPath.section == 4{
            cell.configWith(skillModel: self.screeningConditionsModel?.skill![indexPath.row])
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
        headerView.spreadBlock = {isSpread in
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
        //学校
        if indexPath.section == 0{
            if nil != self.screeningConditionsModel?.college{
                let model = self.screeningConditionsModel?.college![indexPath.row]
                let isSelected = !(model?.isSelected)!
                for model in (self.screeningConditionsModel?.college)!{
                    model.isSelected = false
                }
                model?.isSelected = isSelected
                collectionView.reloadSections([indexPath.section])
                //请求学院的信息
                self.loadAcademysWith(collegeModel: model)
            }
        }
        if indexPath.section == 1{
            if nil != self.screeningConditionsModel?.academy{
                let model = self.screeningConditionsModel?.academy![indexPath.row]
                let isSelected = !(model?.isSelected)!
                for model in (self.screeningConditionsModel?.academy)!{
                    model.isSelected = false
                }
                model?.isSelected = isSelected
                collectionView.reloadSections([indexPath.section])
            }
        }
        if indexPath.section == 2{
            if nil != self.screeningConditionsModel?.grade{
                let model = self.screeningConditionsModel?.grade![indexPath.row]
                let isSelected = !(model?.isSelected)!
                for model in (self.screeningConditionsModel?.grade)!{
                    model.isSelected = false
                }
                model?.isSelected = isSelected
                collectionView.reloadSections([indexPath.section])
            }
        }
        if indexPath.section == 3{
            if nil != self.screeningConditionsModel?.sex{
                let model = self.screeningConditionsModel?.sex![indexPath.row]
                let isSelected = !(model?.isSelected)!
                for model in (self.screeningConditionsModel?.sex)!{
                    model.isSelected = false
                }
                model?.isSelected = isSelected
                collectionView.reloadSections([indexPath.section])
            }
        }
        if indexPath.section == 4{
            if nil != self.screeningConditionsModel?.skill{
                let model = self.screeningConditionsModel?.skill![indexPath.row]
                let isSelected = !(model?.isSelected)!
                for model in (self.screeningConditionsModel?.skill)!{
                    model.isSelected = false
                }
                model?.isSelected = isSelected
                collectionView.reloadSections([indexPath.section])
            }
        }
    }
}
