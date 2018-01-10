//
//  IdentityAuthInfoController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class IdentityAuthInfoController: UITableViewController {
    @IBOutlet weak var headImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var school: UILabel!
    //学院
    @IBOutlet weak var academy: UILabel!
    @IBOutlet weak var age: UILabel!
    //是否显示notice
    var isShowNotice = true
    //是否从个人中心跳转而来
    var isFromPersonalCenter = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "身份认证"
        self.tableView.estimatedRowHeight = 100
        self.tableView.estimatedSectionHeaderHeight = 100
        if !self.isFromPersonalCenter{
            self.tableView.backgroundColor = UIColor.white
        }
        
        let sumbitBtn = UIButton.init(type: .custom)
        let sumBitAttributeTitle = NSAttributedString.init(string: "提交", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        sumbitBtn.setAttributedTitle(sumBitAttributeTitle, for: .normal)
        sumbitBtn.sizeToFit()
        sumbitBtn.addTarget(self, action: #selector(dealSumbit), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sumbitBtn)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notNowBtn = UIButton.init(type: .custom)
        let notNowAttributeTitle = NSAttributedString.init(string: "暂不", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white])
        notNowBtn.setAttributedTitle(notNowAttributeTitle, for: .normal)
        notNowBtn.sizeToFit()
        notNowBtn.addTarget(self, action: #selector(dealNotNow), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem?.customView = notNowBtn
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func dealSumbit(){
        let identityAuthStateController = IdentityAuthStateController()
        self.navigationController?.pushViewController(identityAuthStateController, animated: true)
    }
    
    @objc func dealNotNow(){
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromPersonalCenter{return 3}
        if !isFromPersonalCenter{
            if section == 0{return 0}
            if section == 1{return 4}
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3{return UITableViewAutomaticDimension}
        return 54
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isShowNotice && section == 0{
            let headerView = Helper.getViewFromXib(name: "IdentityAuthInfoHeaderView") as! IdentityAuthInfoHeaderView
            headerView.deleteBlock = {
                self.isShowNotice = false
                tableView.reloadData()
            }
            return headerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isFromPersonalCenter{
            if section == 0{return 7}
        }
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.isShowNotice{return UITableViewAutomaticDimension}
        return 0.001
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0{
            let chooseSchoolController = ChooseSchoolController()
            self.navigationController?.pushViewController(chooseSchoolController, animated: true)
        }
    }

}
