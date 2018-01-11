//
//  PersonCenterController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/10.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class PersonCenterController: UITableViewController {
    @IBOutlet weak var headImgBtn: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var authState: UILabel!
    @IBOutlet weak var myCash: UILabel!
    @IBOutlet weak var demandNum: UILabel!
    @IBOutlet weak var trendsNum: UILabel!
    @IBOutlet weak var logOutBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100
        self.logOutBtn.layer.cornerRadius = 5
        self.logOutBtn.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - misc
    //点击头像
    @IBAction func dealTapHeadImgBtn(_ sender: Any) {
    }
    
    //点击退出登录
    @IBAction func dealTapLogOut(_ sender: Any) {
        Helper.saveToken(token: nil)
        Helper.saveUserId(userId: nil)
        let logVC = Helper.getViewControllerFrom(sbName: .loginRegister, sbID: "LoginController")
        let logNav = NavigationController(rootViewController: logVC)
        self.navigationController?.tabBarController?.present(logNav, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{ return 1}
        if section == 1{ return 3}
        if section == 2{ return 2}
        if section == 3{ return 3}
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3{return 0.001}
        return 7
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {return UITableViewAutomaticDimension}
        if indexPath.section == 3 && indexPath.row == 2{return UITableViewAutomaticDimension}
        return 54
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
            if indexPath.row == 0{
                let personInfoController = Helper.getViewControllerFrom(sbName: .personalCenter, sbID: "PersonInfoController")
                self.navigationController?.pushViewController(personInfoController, animated: true)
            }
        }
        if indexPath.section == 1{
            if indexPath.row == 0{
                let identityAuthInfoController = Helper.getViewControllerFrom(sbName: .loginRegister, sbID: "IdentityAuthInfoController") as! IdentityAuthInfoController
                identityAuthInfoController.isFromPersonalCenter = true
                self.navigationController?.pushViewController(identityAuthInfoController, animated: true)
            }
        }
        if indexPath.section == 2{
            if indexPath.row == 0{
                
            }
        }
        if indexPath.section == 3{
            if indexPath.row == 0{
                
            }
        }
        
    }

}
