//
//  MyBlackListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/4.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

class MyBlackListController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var pageIndex = 1
    var dataArray = [UserInfoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的拉黑"
        self.tableView.register(UINib.init(nibName: "BlackerCell", bundle: nil), forCellReuseIdentifier: "BlackerCell")
        self.tableView.estimatedRowHeight = 100
        
        
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(dealDidMoreOperation(notification:)), name: DID_MORE_OPERATION, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: DID_MORE_OPERATION, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - misc
    @objc func dealDidMoreOperation(notification:Notification){
        if let userInfo = notification.userInfo{
            if let operationModel = userInfo[MORE_OPERATION_KEY] as? MoreOperationModel{
                if operationModel.operationType == .cancelBlack{
                    for i in 0..<self.dataArray.count{
                        if dataArray[i].user_id == operationModel.user_id{
                            dataArray.remove(at: i)
                            self.tableView.reloadData()
                            return
                        }
                    }
                }
//                //拉黑
//                if operationModel.operationType == .defriend{
//                    self.defriendUserWith(user_id: operationModel.user_id)
//                }
//                //删除
//                if operationModel.operationType == .delete{
//                    self.deleteTrendsWith(actionId: operationModel.action_id)
//                }
            }
        }
    }
    
    func loadData(){
        //MyBlackList
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let myBlackList = MyBlackList.init(page: self.pageIndex)
        _ = moyaProvider.rx.request(.targetWith(target: myBlackList)).subscribe(onSuccess: { (response) in
            let userInfoListModel = Mapper<UserInfoListModel>().map(jsonData: response.data)
            if let userInfos = userInfoListModel?.userInfos{
                for userInfo in userInfos{
                    self.dataArray.append(userInfo)
                }
                if userInfos.count > 0{self.tableView.reloadData()}
            }
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: userInfoListModel)
            if self.tableView.emptyDataSetDelegate == nil{
                self.tableView.emptyDataSetDelegate = self
                self.tableView.emptyDataSetSource = self
                if self.dataArray.count == 0{self.tableView.reloadData()}
            }
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
}

extension MyBlackListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.dataArray[indexPath.row]
        let blackCell = tableView.dequeueReusableCell(withIdentifier: "BlackerCell", for: indexPath) as! BlackerCell
        blackCell.configWith(model: model)
        return blackCell
    }
}


extension MyBlackListController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "zmy_img_nodd")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "你还没拉黑任何人哦~"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:RGBA(r: 153, g: 153, b: 153, a: 1)]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
}
