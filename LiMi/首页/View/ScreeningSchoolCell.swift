//
//  ScreeningSchoolCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ScreeningSchoolCell: UITableViewCell {
    @IBOutlet weak var shoolName: UILabel!
    @IBOutlet weak var selectImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configWith(model:ScreeningConditionsBaseModel?){
        if let _model = model as? CollegeModel{
            self.configWith(collegeModel: _model)
        }
        if let _model = model as? AcademyModel{
            self.configWith(academyModel: _model)
        }
        if model != nil{
            if model!.isSelected{
                self.selectImage.isHidden = false
                self.shoolName.textColor = APP_THEME_COLOR
            }
            if !model!.isSelected{
                self.selectImage.isHidden = true
                self.shoolName.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
            }
        }
    }
    
    func configWith(collegeModel:CollegeModel?){
        if let _model = collegeModel{
            self.shoolName.text = _model.name
        }
    }
    func configWith(academyModel:AcademyModel?){
        if let _model = academyModel{
            self.shoolName.text = _model.name
        }
    }
}
