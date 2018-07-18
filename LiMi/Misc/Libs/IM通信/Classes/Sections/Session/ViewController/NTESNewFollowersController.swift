//
//  NTESNewFollowersController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/28.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

class NTESNewFollowersController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @objc var session:NIMSession!
    var tableView:UITableView!
    var dataArray = [UserInfoModel]()
    var pageIndex:Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关注通知"
        self.view.backgroundColor = UIColor.white
        NIMSDK.shared().conversationManager.markAllMessagesRead(in: self.session)
        
        let sumbitBtn = UIButton.init(type: .custom)
        let sumBitAttributeTitle = NSAttributedString.init(string: "清空", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:APP_THEME_COLOR])
        sumbitBtn.setAttributedTitle(sumBitAttributeTitle, for: .normal)
        sumbitBtn.sizeToFit()
        sumbitBtn.addTarget(self, action: #selector(dealClear), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sumbitBtn)
        
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64))
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 100
        self.tableView.register(UINib.init(nibName: "NewFollowersCell", bundle: nil), forCellReuseIdentifier: "NewFollowersCell")
        
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        
        self.loadData()
    }

    //MARK: - misc
    @objc func dealClear(){
        //        ClearMessage
        let alertController = UIAlertController(title: "确认清空通知", message: nil, preferredStyle: .alert)
        let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let actionOK = UIAlertAction.init(title: "确定", style: .default) { _ in
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            let clearMessage = ClearMessage(type: 2)
            _ = moyaProvider.rx.request(.targetWith(target: clearMessage)).subscribe(onSuccess: { (response) in
                let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
                if baseModel?.commonInfoModel?.status == successState{
                    self.tableView.mj_header.beginRefreshing()
                    NIMSDK.shared().conversationManager.deleteAllmessages(in: self.session, option: nil)
                }
                Toast.showErrorWith(model: baseModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionOK)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadData(){
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let geNewAttentionList = GetNewAttentionList(page: self.pageIndex)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: geNewAttentionList)).subscribe(onSuccess: { (response) in
            let userInfoListModel = Mapper<UserInfoListModel>().map(jsonData: response.data)
            if let userInfos = userInfoListModel?.userInfos{
                for userInfo in userInfos{
                    self.dataArray.append(userInfo)
                }
                //if userInfos.count > 0{self.tableView.reloadData()}
            }
            self.tableView.reloadData()
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

extension NTESNewFollowersController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newFollowersCell = tableView.dequeueReusableCell(withIdentifier: "NewFollowersCell", for: indexPath) as! NewFollowersCell
        let userInfoModel = self.dataArray[indexPath.row]
        newFollowersCell.configWith(model: userInfoModel)
        return newFollowersCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userDetailsController = UserDetailsController()
        let userId = self.dataArray[indexPath.row].uid
        userDetailsController.userId = userId!
        self.navigationController?.pushViewController(userDetailsController, animated: true)
    }
}

extension NTESNewFollowersController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "qsy_img_nogz")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "还没有任何人关注你哦~"
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:RGBA(r: 153, g: 153, b: 153, a: 1)]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
}
