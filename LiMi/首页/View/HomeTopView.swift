//
//  HomeTopView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/4.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol HomeTopViewDelegate: class {
    func homeTopViewSegmentButtonClicked(button:UIButton , index:Int) -> Bool
    func homeTopViewMsgButtonClicked()
}
class HomeTopView: UIView {
    weak var delegate:HomeTopViewDelegate?
    var topMaskImageView:UIImageView!

    private var navigationBarView:UIView!
    private var recommendButton:UIButton!
    private var followsButton:UIButton!
    private var schoolButton:UIButton!
    private var downImageView:UIImageView!
    
    convenience init(frame: CGRect ,initialIndex:Int,delegate:HomeTopViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
        if initialIndex == 0{
            self.recommendButton.isSelected = true
        }
        if initialIndex == 1{
            self.followsButton.isSelected = true
        }
        if initialIndex == 2{
            self.schoolButton.isSelected = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        self.topMaskImageView = UIImageView.init(frame: frame)
        self.topMaskImageView.image = UIImage.init(named: "zhezhao_up")
        self.addSubview(self.topMaskImageView)
        
        self.navigationBarView = UIView.init(frame: CGRect.init(x: 0, y: frame.size.height-NAVIGATION_BAR_HEIGHT, width: frame.size.width, height: NAVIGATION_BAR_HEIGHT))
        self.navigationBarView.backgroundColor = UIColor.clear
        self.addSubview(self.navigationBarView)
        
        self.recommendButton = self.addSegmentButtonWith(title: "推荐", frame: CGRect.init(x: 15, y: 0, width: 40, height: 20),tag: 0)
        self.followsButton = self.addSegmentButtonWith(title: "关注", frame: CGRect.init(x: self.recommendButton.frame.maxX+5, y: 0, width: 40, height: 20),tag: 1)
        self.schoolButton = self.addSegmentButtonWith(title: "学校", frame: CGRect.init(x: self.followsButton.frame.maxX + 5, y: 0, width: 40, height: 20),tag: 2)
        
        self.downImageView = UIImageView.init(frame: CGRect.init(x: self.schoolButton.frame.maxX+5, y: 20, width: 10, height: 5 ))
        self.downImageView.image = UIImage.init(named: "sch_ic_xiala")
        self.navigationBarView.addSubview(self.downImageView)
        self.downImageView.isHidden = true
//        self.schoolButton.setImage(UIImage.init(named: "sch_ic_xiala"), for: .selected)
//        self.schoolButton.sizeToFitTitleLeftImageWith(distance: 0)
        
//        let systemMessageNumView = GET_XIB_VIEW(nibName: "SystemMessageNumView") as! SystemMessageNumView
//        systemMessageNumView.frame = CGRect.init(x: SCREEN_WIDTH-15-50, y: 0, width: 44, height: 44)
//        systemMessageNumView.tapBlock = {[unowned self] in
//            let appState = AppManager.shared.appState()
//            if appState ==  .imOffLineBusinessOffline{return}
//            self.delegate?.homeTopViewMsgButtonClicked()
//        }
//        var center = systemMessageNumView.center
//        center.y = frame.size.height * 0.5
//        systemMessageNumView.center = center
        
//        self.navigationBarView.addSubview(systemMessageNumView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") 
    }
    
    func addSegmentButtonWith(title:String!,frame:CGRect,tag:Int)->UIButton!{
        let button = UIButton.init(frame: frame)
        button.tag = tag
        button.addTarget(self, action: #selector(segmentButtonClicked(button:)), for: .touchUpInside)
        let normalTitle = NSAttributedString.init(string: title, attributes: [NSAttributedStringKey.foregroundColor:RGBA(r: 255, g: 255, b: 255, a: 0.5),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 20, weight: .bold)])
        let selectedTitle = NSAttributedString.init(string: title, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 28, weight: .bold)])
        button.setAttributedTitle(selectedTitle, for: .normal)
        button.setAttributedTitle(selectedTitle, for: .selected)
        button.sizeToFit()
        button.setAttributedTitle(normalTitle, for: .normal)
        var center = button.center
        center.y = self.navigationBarView.frame.size.height * 0.5
        button.center = center
        self.navigationBarView.addSubview(button)
        return button
    }
    
    @objc func segmentButtonClicked(button:UIButton){
        if (self.delegate?.homeTopViewSegmentButtonClicked(button: button, index: button.tag))!{
            self.recommendButton.isSelected = false
            self.followsButton.isSelected = false
            self.schoolButton.isSelected = false
            
            button.isSelected = true
            if button.tag == 2{self.downImageView.isHidden = false}else{
                self.downImageView.isHidden = true
            }
        }
    }
}
