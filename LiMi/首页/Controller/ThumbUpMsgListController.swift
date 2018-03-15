//
//  ThumbUpMsgListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/5.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import MJRefresh
import DZNEmptyDataSet

class ThumbUpMsgListController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var pageIndex:Int = 1
    var dataArray = [ThumbUpAndCommentMessageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "SystemMsgWithThumUpOrCommentsCell", bundle: nil), forCellReuseIdentifier: "SystemMsgWithThumUpOrCommentsCell")
        
        self.loadData()
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(clearSuccess), name: CLEAR_COMMENTS_AND_THUMBUP_MESSAGE_SUCCESS, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: CLEAR_COMMENTS_AND_THUMBUP_MESSAGE_SUCCESS, object: nil)
        print("点赞消息页销毁")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - misc
    @objc func clearSuccess(){
        self.loadData()
    }

    func loadData(){
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let clickMessageList = ClickMessageList(page: self.pageIndex)
        _ = moyaProvider.rx.request(.targetWith(target: clickMessageList)).subscribe(onSuccess: { (response) in
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

extension ThumbUpMsgListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataArray[indexPath.row]
        let systemMsgWithThumUpOrCommentsCell = tableView.dequeueReusableCell(withIdentifier: "SystemMsgWithThumUpOrCommentsCell", for: indexPath) as! SystemMsgWithThumUpOrCommentsCell
        systemMsgWithThumUpOrCommentsCell.tapHeadImgBlock = {[unowned self] in
            let userDetailsController = UserDetailsController()
            userDetailsController.userId = (model.user_id)!
            self.navigationController?.pushViewController(userDetailsController, animated: true)
        }
        systemMsgWithThumUpOrCommentsCell.configWith(model: model)
        return systemMsgWithThumUpOrCommentsCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataArray[indexPath.row]
        let trendModel = TrendModel(map: Map.init(mappingType: .fromJSON, JSON: ["":""]))
        if model.type == 0{
            trendModel?.action_id = model.type_id
        }
        if model.type == 1{
            trendModel?.topic_action_id = model.type_id
        }
        let commentsWithTrendController = CommentsWithTrendController()
        commentsWithTrendController.trendModel = trendModel
        self.navigationController?.pushViewController(commentsWithTrendController, animated: true)
    }
}

extension ThumbUpMsgListController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "qsy_img_nosx")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "暂时没有人给你点赞哦~"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:RGBA(r: 153, g: 153, b: 153, a: 1)]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
}
