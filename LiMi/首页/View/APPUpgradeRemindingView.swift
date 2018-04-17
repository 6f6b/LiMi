//
//  APPUpgradeRemindingView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/24.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class APPUpgradeRemindingView: UIView {
    @IBOutlet weak var upgradeVersionInfo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var upgradeBtn: UIButton!
    @IBOutlet weak var notUpgradeBtn: UIButton!
    @IBOutlet weak var forceUpgradeBtn: UIButton!
    @IBOutlet weak var forceUpgradeContainView: UIView! //强制更新
    @IBOutlet weak var upgradeContainView: UIView!  //可选更新
    var upgradeModel:AppUpgradeModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.upgradeBtn.layer.cornerRadius = 5
        self.upgradeBtn.clipsToBounds = true
        
        self.notUpgradeBtn.layer.cornerRadius = 5
        self.notUpgradeBtn.clipsToBounds = true
        
        self.forceUpgradeBtn.layer.cornerRadius = 5
        self.forceUpgradeBtn.clipsToBounds = true
        
        self.forceUpgradeContainView.isHidden = true
        self.upgradeContainView.isHidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    //升级
    @IBAction func dealToUpgrade(_ sender: Any) {
        var upgradeURL:URL!
        if let _url = self.upgradeModel?.update_url{
            upgradeURL = URL.init(string: _url)
//            print(upgradeURL)
//            print(_url)
//            print(self.upgradeModel?.update_url)
        }else{
            upgradeURL = URL.init(string: "https://itunes.apple.com/cn/app/id1364395349?mt=8")
        }
//        print(upgradeURL)
        UIApplication.shared.openURL(upgradeURL)
    }
    //暂不升级
    @IBAction func dealNotUpgradeNow(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    func showWith(upgradeModel:AppUpgradeModel?){
        if let _upgradeModel = upgradeModel{
            self.upgradeModel = _upgradeModel
            self.frame = SCREEN_RECT
            UIApplication.shared.keyWindow?.addSubview(self)
            
            //刷新信息
            if _upgradeModel.update == 0{
                self.forceUpgradeContainView.isHidden = false
            }else{
                self.upgradeContainView.isHidden = false
            }
            self.tableView.reloadData()
            if let _versionNum = upgradeModel?.version{
                self.upgradeVersionInfo.text = "版本升级\(_versionNum)"
            }
        }
    }
}

extension APPUpgradeRemindingView:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _content = self.upgradeModel?.content{
            return _content.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as! UITableViewCell
        cell.textLabel?.textAlignment = .left
        if let title = self.upgradeModel?.content![indexPath.row]{
            cell.textLabel?.attributedText = NSAttributedString.init(string: title, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }
}
