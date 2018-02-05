//
//  ConditionScreeningCollectionCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/25.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ConditionScreeningCollectionCell: UICollectionViewCell {
    @IBOutlet weak var infoContainView: UIView!
    @IBOutlet weak var info: UILabel!
    var tapBlock:(()->Void)?
    var isSelectedStatus = false
    override func awakeFromNib() {
        super.awakeFromNib()
        self.infoContainView.layer.cornerRadius = 4
        self.infoContainView.clipsToBounds = true
        
//        let tapG = UITapGestureRecognizer(target: self, action: #selector(dealTap))
//        self.infoContainView.addGestureRecognizer(tapG)
    }
    
    @objc func dealTap(){
//        if let _tapBlock = self.tapBlock{
//            _tapBlock()
//        }
//        self.isSelectedStatus = !self.isSelectedStatus
//        self.showWith(isSelectedStatus: self.isSelectedStatus)
    }
    
    func showWith(isSelectedStatus:Bool){
        if isSelectedStatus{
            self.infoContainView.backgroundColor = APP_THEME_COLOR
            self.info.textColor = UIColor.white
        }
        if !isSelectedStatus{
            self.infoContainView.backgroundColor = RGBA(r: 240, g: 240, b: 240, a: 1)
            self.info.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
        }
    }

    func configWith(collegeModel:CollegeModel?){
        self.info.text = collegeModel?.name
        self.showWith(isSelectedStatus: (collegeModel?.isSelected)!)
    }
    func configWith(academyModel:AcademyModel?){
        self.info.text = academyModel?.name
        self.showWith(isSelectedStatus: (academyModel?.isSelected)!)
    }
    func configWith(gradeModel:GradeModel?){
        self.info.text = gradeModel?.name
        self.showWith(isSelectedStatus: (gradeModel?.isSelected)!)

    }
    func configWith(sex:SexModel?){
        self.info.text = sex?.sex
        self.showWith(isSelectedStatus: (sex?.isSelected)!)

    }
    func configWith(skillModel:SkillModel?){
        self.info.text = skillModel?.skill
        self.showWith(isSelectedStatus: (skillModel?.isSelected)!)
    }
}
