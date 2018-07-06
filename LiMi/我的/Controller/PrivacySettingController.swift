//
//  PrivacySettingController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/28.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class PrivacySettingController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var tableView: UITableView!
    var userInfoModel:UserInfoModel?
    
    var dataArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "隐私设置"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(MenuWithSwitchCell.self, forCellReuseIdentifier: "MenuWithSwitchCell")
        self.dataArray = ["允许关注者发私信","公开赞过的视频","公开我的粉丝列表","公开我的关注列表"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

extension PrivacySettingController :UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuWithSwitchCell = tableView.dequeueReusableCell(withIdentifier: "MenuWithSwitchCell", for: indexPath) as! MenuWithSwitchCell
        let title = self.dataArray[indexPath.row]
//        var send_status:Bool? //1,允许未关注的人发送消息  0相反
//        var clickVL_status:Bool?//1,公开喜欢的视频         0相反
//        var fansL_status:Bool?//1,公开粉丝列表           0 相反
//        var attentionL_status:Bool?//1,   公开关注列表    0 相反
        if indexPath.row == 0{
            menuWithSwitchCell.configWith(title: title, isOn: self.userInfoModel?.send_status, indexPath: indexPath)
        }
        if indexPath.row == 1{
            menuWithSwitchCell.configWith(title: title, isOn: self.userInfoModel?.clickVL_status, indexPath: indexPath)
        }
        if indexPath.row == 2{
            menuWithSwitchCell.configWith(title: title, isOn: self.userInfoModel?.fansL_status, indexPath: indexPath)
        }
        if indexPath.row == 3{
            menuWithSwitchCell.configWith(title: title, isOn: self.userInfoModel?.attentionL_status, indexPath: indexPath)
        }
        menuWithSwitchCell.clickSwitchViewBlock = {[unowned self] (switchView,_indexPath) in
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            var type:String?
            if _indexPath?.row == 0{type = "send"}
            if _indexPath?.row == 1{type = "click"}
            if _indexPath?.row == 2{type = "fans"}
            if _indexPath?.row == 3{type = "attention"}
            let value = switchView.isOn ? 1 : 0
            let privacyAction = PrivacyAction.init(type: type, value: value)
            
            _ = moyaProvider.rx.request(.targetWith(target: privacyAction)).subscribe(onSuccess: { (response) in
                let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
                if resultModel?.commonInfoModel?.status == successState{
                    if _indexPath?.row == 0,let status = self.userInfoModel?.send_status{
                        self.userInfoModel?.send_status = !status
                    }
                    if _indexPath?.row == 1,let status = self.userInfoModel?.clickVL_status{
                        self.userInfoModel?.clickVL_status = !status
                    }
                    if _indexPath?.row == 2,let status = self.userInfoModel?.fansL_status{
                        self.userInfoModel?.fansL_status = !status
                    }
                    if _indexPath?.row == 3,let status = self.userInfoModel?.attentionL_status{
                        self.userInfoModel?.attentionL_status = !status
                    }
                    tableView.reloadData()
                }
                Toast.showResultWith(model: resultModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }
        return menuWithSwitchCell
    }
}


