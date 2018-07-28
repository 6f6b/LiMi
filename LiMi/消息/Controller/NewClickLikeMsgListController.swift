//
//  NewClickLikeMsgListController.swift
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

class NewClickLikeMsgListController: SubMsgController {
    var dataArray = [ThumbUpAndCommentMessageModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "点赞"

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "ClickLikeMsgCell", bundle: nil), forCellReuseIdentifier: "ClickLikeMsgCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let target = ClickMessageList(page: self.pageIndex)
        
        _ = moyaProvider.rx.request(.targetWith(target: target)).subscribe(onSuccess: {[unowned self] (response) in
            if self.pageIndex == 1{self.dataArray.removeAll()}
            let thumbUpAndCommentMessageContainModel = Mapper<ThumbUpAndCommentMessageContainModel>().map(jsonData: response.data)
            if let thumbUpAndCommentMessageModels = thumbUpAndCommentMessageContainModel?.datas{
                for thumbUpAndCommentMessageModel in thumbUpAndCommentMessageModels{
                    self.dataArray.append(thumbUpAndCommentMessageModel)
                }
                self.tableView.reloadData()
            }
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: thumbUpAndCommentMessageContainModel)
            }, onError: { (error) in
                self.tableView.mj_footer.endRefreshing()
                self.tableView.mj_header.endRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}
extension NewClickLikeMsgListController : UITableViewDelegate,UITableViewDataSource{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClickLikeMsgCell", for: indexPath) as! ClickLikeMsgCell
        let model = self.dataArray[indexPath.row]
        cell.configWith(model: model)
        return cell
    }
}
