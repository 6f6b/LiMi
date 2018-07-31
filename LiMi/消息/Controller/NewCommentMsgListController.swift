//
//  NewCommentMsgListController.swift
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

class NewCommentMsgListController: SubMsgController {
    var dataArray = [ThumbUpAndCommentMessageModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "评论"

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "CommentMsgCell", bundle: nil), forCellReuseIdentifier: "CommentMsgCell")
        self.tableView.estimatedRowHeight = 100
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    override func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let target = CommentMessageList(page: self.pageIndex)

        _ = moyaProvider.rx.request(.targetWith(target: target)).subscribe(onSuccess: {[unowned self] (response) in
            if self.pageIndex == 1{self.dataArray.removeAll()}
            let thumbUpAndCommentMessageContainModel = Mapper<ThumbUpAndCommentMessageContainModel>().map(jsonData: response.data)
            if let thumbUpAndCommentMessageModels = thumbUpAndCommentMessageContainModel?.datas{
                for thumbUpAndCommentMessageModel in thumbUpAndCommentMessageModels{
                    self.dataArray.append(thumbUpAndCommentMessageModel)
                }
            }
            self.tableView.reloadData()
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
extension NewCommentMsgListController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///0:动态  1：话题  2：短视频  3：关注     指定数据来源分类
        let model = self.dataArray[indexPath.row]
        if model.type == 0{
            
        }
        if model.type == 1{
            
        }
        if model.type == 2{
            let singleVideoPlayController = SingleVideoPlayController()
            singleVideoPlayController.videoTrendId = model.type_id
            self.navigationController?.pushViewController(singleVideoPlayController, animated: true)
        }
        if model.type == 3{
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentMsgCell", for: indexPath) as! CommentMsgCell
        let model = self.dataArray[indexPath.row]
        cell.configWith(model: model)
        return cell
    }
}
