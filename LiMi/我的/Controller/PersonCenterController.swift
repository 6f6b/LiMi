//
//  PersonCenterController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/10.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import SVProgressHUD
import Kingfisher

class PersonCenterController: UITableViewController {
    @IBOutlet weak var headImgBtn: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var sexImg: UIImageView!
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var authState: UILabel!
    @IBOutlet weak var myCash: UILabel!
    @IBOutlet weak var demandNum: UILabel!
    @IBOutlet weak var trendsNum: UILabel!
    @IBOutlet weak var logOutBtn: UIButton!
    
    var personCenterModel:PersonCenterModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100
        self.logOutBtn.layer.cornerRadius = 5
        self.logOutBtn.clipsToBounds = true
        self.headImgBtn.layer.cornerRadius = 35
        self.headImgBtn.clipsToBounds = true
        
        self.userName.text = nil
        self.sexImg.image = nil
        self.userInfo.text = nil
        self.authState.text = nil
//        self.myCash.text = nil
//        self.demandNum.text = nil
//        self.trendsNum.text = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
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
        let alertVC = UIAlertController.init(title: "确认退出登录？", message: nil, preferredStyle: .alert)
        let actionOK = UIAlertAction.init(title: "确定", style: .default) {_ in
            Defaults[.userId] = nil
            Defaults[.userToken] = nil
            let logVC = GetViewControllerFrom(sbName: .loginRegister, sbID: "LoginController")
            let logNav = NavigationController(rootViewController: logVC)
            self.navigationController?.tabBarController?.present(logNav, animated: true, completion: nil)
        }
        let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(actionOK)
        alertVC.addAction(actionCancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //请求服务器数据
    func requestData() {
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let personCenter = PersonCenter()
        _ = moyaProvider.rx.request(.targetWith(target: personCenter)).subscribe(onSuccess: { (response) in
            let personCenterModel = Mapper<PersonCenterModel>().map(jsonData: response.data)
            self.refreshUIWith(model: personCenterModel)
            SVProgressHUD.showErrorWith(model: personCenterModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    //刷新界面
    func refreshUIWith(model:PersonCenterModel?){
        self.personCenterModel = model
        if let headPic = personCenterModel?.user_info?.head_pic{
            self.headImgBtn.kf.setImage(with: URL.init(string: headPic), for: .normal, placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        if model?.user_info?.sex == "女"{
            self.sexImg.image = UIImage.init(named: "girl")
        }else{
            self.sexImg.image = UIImage.init(named: "boy")
        }
        self.userName.text = self.personCenterModel?.user_info?.true_name
        if let college = model?.user_info?.college,let academy = model?.user_info?.school{
            self.userInfo.text = "\(college)|\(academy)"
        }else{self.userInfo.text = "个人资料待认证"}
        //0 ：未认证   1：认证中  2：认证完成  3：认证失败
        if let identity_status = model?.is_access?.identity_status{
            var statusInfo = "未认证"
            if identity_status == 0{statusInfo = "未认证"}
            if identity_status == 1{statusInfo = "认证中"}
            if identity_status == 2{statusInfo = "认证通过"}
            if identity_status == 3{statusInfo = "认证失败"}
            self.authState.text = statusInfo
        }
    }
    
    func checkIdentityInfoWith(identityStatus:Int?){
        //0 ：未认证   1：认证中  2：认证完成  3：认证失败
        if let identityStatus = identityStatus{
            if identityStatus == 0{
                let identityAuthInfoWithSexAndNameController = GetViewControllerFrom(sbName: .personalCenter, sbID: "IdentityAuthInfoWithSexAndNameController") as! IdentityAuthInfoWithSexAndNameController
                self.navigationController?.pushViewController(identityAuthInfoWithSexAndNameController, animated: true)
                return
            }
            if identityStatus == 1{
                let identityAuthStateController = IdentityAuthStateController()
                identityAuthStateController.state = .inProcessing
                identityAuthStateController.isFromPersonCenter = true
                self.navigationController?.pushViewController(identityAuthStateController, animated: true)
                return
            }
            if identityStatus == 2{
                let identityAuthStateController = IdentityAuthStateController()
                identityAuthStateController.state = .finished
                identityAuthStateController.isFromPersonCenter = true
                self.navigationController?.pushViewController(identityAuthStateController, animated: true)
                return
            }
            if identityStatus == 3{
                let identityAuthStateController = IdentityAuthStateController()
                identityAuthStateController.state = .finished
                identityAuthStateController.isFromPersonCenter = true
                self.navigationController?.pushViewController(identityAuthStateController, animated: true)
                return
            }
        }
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
                let personInfoController = GetViewControllerFrom(sbName: .personalCenter, sbID: "PersonInfoController")
                self.navigationController?.pushViewController(personInfoController, animated: true)
            }
        }
        if indexPath.section == 1{
            if indexPath.row == 0{
                self.checkIdentityInfoWith(identityStatus: self.personCenterModel?.is_access?.identity_status)
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
