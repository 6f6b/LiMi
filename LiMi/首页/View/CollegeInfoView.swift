//
//  CollegeInfoView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/9.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol CollegeInfoViewDelegate : class{
    func collegeInfoView(view:CollegeInfoView,clickStackViewWith model:CollegeVideoInfoModel?)
}
class CollegeInfoView: UIView {
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var clickNum: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView4ContentView: UIView!
    @IBOutlet var imageViews: [UIImageView]!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var boysPercent: UILabel!
    @IBOutlet weak var girlsPercent: UILabel!
    
    @IBOutlet weak var boysPercentConstraint: NSLayoutConstraint!
    @IBOutlet weak var girlsPercentConstrain: NSLayoutConstraint!
    
    weak var delegate:CollegeInfoViewDelegate?
    
    var collegeVideoInfoModel:CollegeVideoInfoModel?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapStackView = UITapGestureRecognizer.init(target: self, action: #selector(tapedStackView))
        self.stackView.addGestureRecognizer(tapStackView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(clickCollegeNotification(notification:)), name: NSNotification.Name.init(rawValue: "CLICK_COLLEGE_NOTIFICATION"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func clickCollegeNotification(notification:Notification){
        let info = notification.userInfo
        let model = self.collegeVideoInfoModel
        if model?.college?.id == info!["collegeId"] as? Int{
            if let _clickNum = model?.college?.click_num{
                self.clickNum.text = "\(_clickNum.suitableStringValue())"
            }
        }
    }
    
    @objc func tapedStackView(){
        self.delegate?.collegeInfoView(view: self, clickStackViewWith: self.collegeVideoInfoModel)
    }
    
    func configWith(model:CollegeVideoInfoModel?){
        self.collegeVideoInfoModel = model
        if let videoPictures = model?.videoList{
            self.refreshImageViewsStatusWith(picsNum: videoPictures.count)
            let length = videoPictures.count > 4 ? 4 :videoPictures.count
            for i in 0 ..< length{
                let pic = videoPictures[i]
                let imageView = self.imageViews[i]
                imageView.kf.setImage(with: URL.init(string: pic))
            }
        }else{
            self.refreshImageViewsStatusWith(picsNum: 0)
        }
        self.schoolName.text = model?.college?.name
        if let _clickNum = model?.college?.click_num{
            self.clickNum.text = "\(_clickNum.suitableStringValue())"
        }
        if let _boysPercent = model?.college?.b_g?.b{
            self.boysPercent.text = "\(_boysPercent)%"
            self.girlsPercent.text = "\(100-_boysPercent)%"
            self.boysPercentConstraint.setMultiplier(multiplier: 0.01*CGFloat(_boysPercent))
            self.girlsPercentConstrain.setMultiplier(multiplier: 0.01 * CGFloat(100 - _boysPercent))
        }
    }
    
    func refreshImageViewsStatusWith(picsNum:Int){
        if picsNum <= 0{
            self.imageView1.isHidden = true
            self.imageView2.isHidden = true
            self.imageView3.isHidden = true
            self.imageView4ContentView.isHidden = true
        }
        if picsNum == 1{
            self.imageView1.isHidden = false
            self.imageView2.isHidden = true
            self.imageView3.isHidden = true
            self.imageView4ContentView.isHidden = true
        }
        if picsNum == 2{
            self.imageView1.isHidden = false
            self.imageView2.isHidden = false
            self.imageView3.isHidden = true
            self.imageView4ContentView.isHidden = true
        }
        if picsNum == 3{
            self.imageView1.isHidden = false
            self.imageView2.isHidden = false
            self.imageView3.isHidden = false
            self.imageView4ContentView.isHidden = true
        }
        if picsNum >= 4{
            self.imageView1.isHidden = false
            self.imageView2.isHidden = false
            self.imageView3.isHidden = false
            self.imageView4ContentView.isHidden = false
        }
    }
}
