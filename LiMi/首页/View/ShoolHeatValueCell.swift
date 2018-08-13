//
//  ShoolHeatValueCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/10.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol ShoolHeatValueCellDelegate : class{
    func shoolHeatValueCell(cell:ShoolHeatValueCell,clickedThumbUpButtonWith model:CollegeModel?)
}

class ShoolHeatValueCell: UICollectionViewCell {
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var heatValue: UILabel!
    @IBOutlet weak var thumbUpButton: UIButton!
    weak var delegate:ShoolHeatValueCellDelegate?
    var model:CollegeModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addLabel.alpha = 0
        let gradientLayer = CAGradientLayer()
        let alpha = CGFloat(1)
        gradientLayer.colors = [RGBA(r: 255, g: 90, b: 0, a: alpha).cgColor,RGBA(r: 218, g: 0, b: 159, a: alpha).cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0.5)
        gradientLayer.frame = self.containView.bounds
        self.containView.layer.addSublayer(gradientLayer)

        self.containView.bringSubview(toFront: self.addLabel)
        self.containView.bringSubview(toFront: self.heatValue)
        self.containView.bringSubview(toFront: self.thumbUpButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(clickCollegeNotification(notification:)), name: NSNotification.Name.init(rawValue: "CLICK_COLLEGE_NOTIFICATION"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func clickCollegeNotification(notification:Notification){
        if let info = notification.userInfo{
            if self.model?.id != info["collegeId"] as? Int{return}
            model?.is_click = info["isClick"] as? Bool
            model?.click_num = info["clickNum"] as? Int
            
            if let _clickNum = model?.click_num{
                self.heatValue.text = "热气值 \(_clickNum)"
            }
            
            if model?.is_click == true{
                self.addLabel.alpha = 1
                self.thumbUpButton.isSelected = true
                UIView.animate(withDuration: 0.5) {[unowned self] in
                    self.addLabel.alpha = 0
                }
            }else{
                self.addLabel.alpha = 0
                self.thumbUpButton.isSelected = false
            }
        }
    }

    @IBAction func clickedThumbUpButton(_ sender: Any) {
        self.delegate?.shoolHeatValueCell(cell: self, clickedThumbUpButtonWith: self.model)
    }
    
    func configWith(model:CollegeModel?){
        self.model = model
        if let _clickNum = model?.click_num{
            self.heatValue.text = "热气值 \(_clickNum)"
        }
        if let _isClick = model?.is_click{
            self.thumbUpButton.isSelected = _isClick
        }
    }
}
