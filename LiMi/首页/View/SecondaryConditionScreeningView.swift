//
//  SecondaryConditionScreeningView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SecondaryConditionScreeningView: UIView {
    var navigationView:ConditionScreeningView?
//    var leftConstraint:
    
    //上部容器
    var topToolsContainView:UIView!
    var backBtn:UIButton!
    var okBtn:UIButton!
    var titleLabel:UILabel!
    
    //tableview
    var tableView:UITableView!

    convenience init() {
        self.init(frame: SCREEN_RECT)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.topToolsContainView = UIView()
        self.topToolsContainView.backgroundColor = UIColor.white
        self.addSubview(self.topToolsContainView)
        self.topToolsContainView.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.height.equalTo(64)
            make.right.equalTo(self)
        }
        
        self.backBtn = UIButton.init()
        self.backBtn.setBackgroundImage(UIImage.init(named: "hb_btn_back"), for: .normal)
        self.backBtn.addTarget(self, action: #selector(dealPop), for: .touchUpInside)
        self.backBtn.sizeToFit()
        self.topToolsContainView.addSubview(self.backBtn)
        self.backBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.topToolsContainView)
            make.left.equalTo(self.topToolsContainView).offset(15)
        }
        
        self.titleLabel = UILabel.init()
        self.titleLabel.text = nil
        self.titleLabel.font = UIFont.systemFont(ofSize: 15)
        self.titleLabel.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
        self.topToolsContainView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {[unowned self] (make) in
            make.center.equalTo(self.topToolsContainView)
        }
        
        self.okBtn = UIButton.init()
        self.okBtn.setTitle("确定", for: .normal)
        self.okBtn.addTarget(self, action: #selector(dealOK), for: .touchUpInside)
        self.okBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.okBtn.setTitleColor(RGBA(r: 153, g: 153, b: 153, a: 1), for: .normal)
        self.topToolsContainView.addSubview(self.okBtn)
        self.okBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.topToolsContainView)
            make.right.equalTo(self.topToolsContainView).offset(-15)
        }
        
        self.tableView = UITableView.init()
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topToolsContainView.snp.bottom)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }
        
        self.backBtn = UIButton.init()
    }
    
    //MARK: - misc
    @objc func dealPop(){
        self.navigationView?.popView()
    }
    
    @objc func dealOK(){
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
