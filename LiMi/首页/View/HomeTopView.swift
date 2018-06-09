//
//  HomeTopView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/4.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol HomeTopViewDelegate {
    func homeTopViewSegmentButtonClicked(button:UIButton , index:Int)
    func homeTopViewMsgButtonClicked()
}
class HomeTopView: UIView {
    var delegate:HomeTopViewDelegate?
    private var navigationBarView:UIView!
    private var recommendButton:UIButton!
    private var followsButton:UIButton!
    private var schoolButton:UIButton!
    
    
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
        
        self.navigationBarView = UIView.init(frame: CGRect.init(x: 0, y: frame.size.height-NAVIGATION_BAR_HEIGHT, width: frame.size.width, height: NAVIGATION_BAR_HEIGHT))
        self.navigationBarView.backgroundColor = UIColor.clear
        self.addSubview(self.navigationBarView)
        
        self.recommendButton = self.addSegmentButtonWith(title: "推荐", frame: CGRect.init(x: 15, y: 0, width: 40, height: 20),tag: 0)
        self.followsButton = self.addSegmentButtonWith(title: "关注", frame: CGRect.init(x: self.recommendButton.frame.maxX+5, y: 0, width: 40, height: 20),tag: 1)
        self.schoolButton = self.addSegmentButtonWith(title: "学校", frame: CGRect.init(x: self.followsButton.frame.maxX + 5, y: 0, width: 40, height: 20),tag: 2)
        self.schoolButton.setImage(UIImage.init(named: "sch_ic_xiala"), for: .selected)
//        self.schoolButton.sizeToFitTitleLeftImageWith(distance: 0)
        
        let systemMessageNumView = GET_XIB_VIEW(nibName: "SystemMessageNumView") as! SystemMessageNumView
        systemMessageNumView.frame = CGRect.init(x: SCREEN_WIDTH-15-50, y: 0, width: 44, height: 44)
        systemMessageNumView.tapBlock = {[unowned self] in
            let appState = AppManager.shared.appState()
            if appState ==  .imOffLineBusinessOffline{return}
            self.delegate?.homeTopViewMsgButtonClicked()
        }
        var center = systemMessageNumView.center
        center.y = frame.size.height * 0.5
        systemMessageNumView.center = center
        
        self.navigationBarView.addSubview(systemMessageNumView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") 
    }
    
    func addSegmentButtonWith(title:String!,frame:CGRect,tag:Int)->UIButton!{
        let button = UIButton.init(frame: frame)
        button.tag = tag
        button.addTarget(self, action: #selector(segmentButtonClicked(button:)), for: .touchUpInside)
        let normalTitle = NSAttributedString.init(string: title, attributes: [NSAttributedStringKey.foregroundColor:RGBA(r: 106, g: 106, b: 106, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 20, weight: .bold)])
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
        self.recommendButton.isSelected = false
        self.followsButton.isSelected = false
        self.schoolButton.isSelected = false

        button.isSelected = true
        self.delegate?.homeTopViewSegmentButtonClicked(button: button, index: button.tag)
    }
}
