//
//  FollowerListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/4.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

enum FollowType {
    case follows
    case followers
    case recentFollowers
}

class FollowerListController: ViewController {
   
    var tableView: UITableView!
    var pageIndex = 1
    var followType:FollowType = .follows
    var dataArray = [UserInfoModel]()
    
    init(followType:FollowType) {
        super.init(nibName: nil, bundle: nil)
        self.followType = followType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView.init(frame: self.view.bounds)
        self.view.addSubview(self.tableView)
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "FollowerCell", bundle: nil), forCellReuseIdentifier: "FollowerCell")
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        
        self.loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(receivedNotificationWith(notification:)), name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    @objc func receivedNotificationWith(notification:Notification?){
        if let info = notification?.userInfo{
            let userId = info[USER_ID_KEY] as? Int
            let relationship = info[RELATIONSHIP_KEY] as? Int
            for i in 0..<self.dataArray.count{
                let userModel = self.dataArray[i]
                if userModel.user_id == userId{
                    userModel.is_attention = relationship
                    //is_attention=0 未关注 1 已关注 2 互关注
                    if self.followType == .followers{
                        self.tableView.reloadData()
                    }
                    if self.followType == .follows{
                        if userModel.is_attention == 0{
                            self.tableView.reloadData()
                            return
                        }
                        if userModel.is_attention != 0{
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func loadData(){
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        var target:TargetType!
        if self.followType == .follows{
            target = MyAttentionList(page: self.pageIndex)
        }
        if self.followType == .followers{
            target = MyFansList(page: self.pageIndex)
        }
        if self.followType == .recentFollowers{
            target = MyFansList(page: self.pageIndex)
        }
        _ = moyaProvider.rx.request(.targetWith(target: target)).subscribe(onSuccess: { (response) in
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

extension FollowerListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.dataArray[indexPath.row]
        let followerCell = tableView.dequeueReusableCell(withIdentifier: "FollowerCell", for: indexPath) as! FollowerCell
        followerCell.configWith(model: model)
        return followerCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataArray[indexPath.row]
        let userDetailsController = UserDetailsController()
        userDetailsController.userId = model.user_id!
        self.navigationController?.pushViewController(userDetailsController, animated: true)
    }
}

extension FollowerListController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "qsy_img_nogz")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = self.followType == .follows ? "你还没关注任何人哦~" : "还没有任何人关注你哦~"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:RGBA(r: 153, g: 153, b: 153, a: 1)]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
}
