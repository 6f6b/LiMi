//
//  NewFansMsgListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/26.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import MJRefresh
import ObjectMapper
import DZNEmptyDataSet

class NewFansMsgListController: SubMsgController {
    var dataArray = [NewFansMsgModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "粉丝"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "NewFansMsgCell", bundle: nil), forCellReuseIdentifier: "NewFansMsgCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func loadData(){
        let geNewAttentionList = GetNewAttentionList(page: self.pageIndex)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: geNewAttentionList)).subscribe(onSuccess: { (response) in
            if self.pageIndex == 1{self.dataArray.removeAll()}
            let newFansMsgListModel = Mapper<NewFansMsgListModel>().map(jsonData: response.data)
            if let newFansMsgModels = newFansMsgListModel?.data{
                for newFansMsgModel in newFansMsgModels{
                    self.dataArray.append(newFansMsgModel)
                }
            }
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: newFansMsgListModel)
        }, onError: { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}
extension NewFansMsgListController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewFansMsgCell", for: indexPath) as! NewFansMsgCell
        let model = self.dataArray[indexPath.row]
        cell.delegate = self
        cell.configWith(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataArray[indexPath.row]
        if let userId = model.uid{
            let userDetailController = UserDetailsController()
            userDetailController.userId = userId
            self.navigationController?.pushViewController(userDetailController, animated: true)
        }
    }
}

extension NewFansMsgListController : NewFansMsgCellDelegate{
    func dealChangeRelationshipWith(model:NewFansMsgModel?){
        if let userId = model?.uid{
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            let addAttention = AddAttention.init(attention_id: userId)
            _ = moyaProvider.rx.request(.targetWith(target: addAttention)).subscribe(onSuccess: {[unowned self] (response) in
                let personCenterModel = Mapper<PersonCenterModel>().map(jsonData: response.data)
                if personCenterModel?.commonInfoModel?.status == successState{
                    NotificationCenter.default.post(name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil, userInfo: [USER_ID_KEY:model?.uid,RELATIONSHIP_KEY:personCenterModel?.user_info?.is_attention])
                }
                Toast.showErrorWith(model: personCenterModel)
                }, onError: { (error) in
                    Toast.showErrorWith(msg: error.localizedDescription)
            })
        }
    }
    
    func newFansMsgCell(cell: NewFansMsgCell, clickFollowButtonWith model: NewFansMsgModel?) {
        if model?.is_attention == 0{
            self.dealChangeRelationshipWith(model: model)
        }else{
            let popViewForChooseToUnFollow = PopViewForChooseToUnFollow.init(frame: SCREEN_RECT)
            popViewForChooseToUnFollow.tapRightBlock = {[unowned self] () in
                self.dealChangeRelationshipWith(model: model)
            }
            popViewForChooseToUnFollow.show()
        }
    }
}
