//
//  UserDetailSelectTrendsTypeView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/6.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class UserDetailSelectTrendsTypeView: UIView {
    var leftBtn:UIButton!
    var rightBtn:UIButton!
    var leftBottomLine:UIView!
    var rightBottomeLine:UIView!
    var initialIndex = 0
    var tapBlock:((Int)->Void)?
    
    convenience init(initialIndex:Int) {
        self.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 50))
        self.initialIndex = initialIndex
        self.refreshUIWith(selectedIndex: self.initialIndex)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.leftBtn = UIButton.init(type: .custom)
        self.leftBtn.addTarget(self, action: #selector(dealTapBtn(btn:)), for: .touchUpInside)
        self.leftBtn.setTitleColor(RGBA(r: 51, g: 51, b: 51, a: 1), for: .normal)
        self.leftBtn.setTitle("动态", for: .normal)
        self.leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.addSubview(self.leftBtn)
        self.leftBtn.snp.makeConstraints {[unowned self] (make) in
            make.left.equalTo(self).offset(15)
            make.top.equalTo(self).offset(40)
        }
        
        self.rightBtn = UIButton.init(type: .custom)
        self.rightBtn.addTarget(self, action: #selector(dealTapBtn(btn:)), for: .touchUpInside)
        self.rightBtn.setTitleColor(RGBA(r: 51, g: 51, b: 51, a: 1), for: .normal)
        self.rightBtn.setTitle("需求", for: .normal)
        self.rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.addSubview(self.rightBtn)
        self.rightBtn.snp.makeConstraints {[unowned self] (make) in
            make.left.equalTo(self.leftBtn.snp.right).offset(30)
            make.centerY.equalTo(self.leftBtn)
        }
        
        self.leftBottomLine = UIView.init()
        self.leftBottomLine.backgroundColor = APP_THEME_COLOR
        self.leftBottomLine.layer.cornerRadius = 1.5
        self.leftBottomLine.clipsToBounds = true
        self.addSubview(self.leftBottomLine)
        self.leftBottomLine.snp.makeConstraints {[unowned self] (make) in
            make.centerX.equalTo(self.leftBtn)
            make.width.equalTo(30)
            make.height.equalTo(3)
            make.top.equalTo(self.leftBtn.snp.bottom).offset(0)
            make.bottom.equalTo(self)
        }
        
        self.rightBottomeLine = UIView.init()
        self.rightBottomeLine.backgroundColor = APP_THEME_COLOR
        self.rightBottomeLine.layer.cornerRadius = 1.5
        self.rightBottomeLine.clipsToBounds = true
        self.addSubview(self.rightBottomeLine)
        self.rightBottomeLine.snp.makeConstraints {[unowned self] (make) in
            make.centerX.equalTo(self.rightBtn)
            make.width.equalTo(30)
            make.height.equalTo(3)
            make.centerY.equalTo(self.leftBottomLine)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - misc
    @objc func dealTapBtn(btn:UIButton!){
        var index = 0
        if btn.isEqual(self.leftBtn){
            index = 0
        }
        if btn.isEqual(self.rightBtn){
            index = 1
        }
        self.refreshUIWith(selectedIndex: index)
        if let _tapBlock = self.tapBlock{
            _tapBlock(index)
        }
    }
    
    func refreshUIWith(selectedIndex:Int){
        if selectedIndex == 0{
            self.leftBtn.setTitleColor(APP_THEME_COLOR, for: .normal)
            self.rightBtn.setTitleColor(RGBA(r: 204, g: 204, b: 204, a: 1), for: .normal)
            self.leftBottomLine.isHidden = false
            self.rightBottomeLine.isHidden = true
        }
        if selectedIndex == 1{
            self.leftBtn.setTitleColor(RGBA(r: 204, g: 204, b: 204, a: 1), for: .normal)
            self.rightBtn.setTitleColor(APP_THEME_COLOR, for: .normal)
            self.leftBottomLine.isHidden = true
            self.rightBottomeLine.isHidden = false
        }
    }

}
