//
//  ChooseFollowedToRemindController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/24.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

protocol ChooseFollowedToRemindControllerDelegate {
    func chooseFollowedToRemindController(controller:ChooseFollowedToRemindController, selectedUser model:UserInfoModel)
}
class ChooseFollowedToRemindController: PulishNextController {
    var pageIndex = 1
    var dataArray = [UserInfoModel]()
    var delegate:ChooseFollowedToRemindControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "@好友"
        self.searchTextField.placeholder = "输入要@的好友昵称"
        self.loadDataWith(name: nil)
        self.searchTextField.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: UIControlEvents.editingChanged)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib.init(nibName: "ChooseToRemindUserInfoCell", bundle: nil), forCellReuseIdentifier: "ChooseToRemindUserInfoCell")
        self.tableView.register(UINib.init(nibName: "ChooseToRemindUserCell", bundle: nil), forCellReuseIdentifier: "ChooseToRemindUserCell")
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadDataWith(name: self.searchTextField.text)
        }
        self.tableView.mj_footer = mjGifFooterWith {[unowned self]  in
            self.pageIndex += 1
            self.loadDataWith(name: self.searchTextField.text)
        }
    }

    func loadDataWith(name:String?){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let userId = Defaults[.userId]
        let  target = MyAttentionList.init(page: self.pageIndex, id: userId, name: name)
        _ = moyaProvider.rx.request(.targetWith(target: target)).subscribe(onSuccess: { (response) in
            if self.pageIndex == 1{self.dataArray.removeAll()}
            let userInfoListModel = Mapper<UserInfoListModel>().map(jsonData: response.data)
            if let userInfos = userInfoListModel?.userInfos{
                for userInfo in userInfos{
                    self.dataArray.append(userInfo)
                }
            }
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: userInfoListModel)
            self.tableView.reloadData()
        }, onError: { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
            if self.tableView.emptyDataSetDelegate == nil{
                self.tableView.emptyDataSetDelegate = self
                self.tableView.emptyDataSetSource = self
                if self.dataArray.count == 0{self.tableView.reloadData()}
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func textFieldValueChanged(textField:UITextField){
        self.pageIndex = 1
        self.loadDataWith(name: textField.text)
    }
}

extension ChooseFollowedToRemindController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{return 54}
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let chooseToRemindUserInfoCell = tableView.dequeueReusableCell(withIdentifier: "ChooseToRemindUserInfoCell", for: indexPath) as! ChooseToRemindUserInfoCell
            return chooseToRemindUserInfoCell
        }
        let model = self.dataArray[indexPath.row]
        let chooseToRemindUserCell = tableView.dequeueReusableCell(withIdentifier: "ChooseToRemindUserCell", for: indexPath) as! ChooseToRemindUserCell
        chooseToRemindUserCell.configWith(model: model)
        return chooseToRemindUserCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataArray[indexPath.row]
//        let userDetailsController = UserDetailsController()
//        userDetailsController.userId = model.user_id!
//        self.navigationController?.pushViewController(userDetailsController, animated: true)
        self.delegate?.chooseFollowedToRemindController(controller: self, selectedUser: model)
        self.navigationController?.popViewController(animated: true)
    }
}

extension ChooseFollowedToRemindController : DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "qsy")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "空空如也~"
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16),NSAttributedStringKey.foregroundColor:RGBA(r: 255, g: 255, b: 255, a: 1)]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
}
