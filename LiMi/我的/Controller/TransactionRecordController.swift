//
//  TransactionRecordController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import MJRefresh
import SVProgressHUD
import Moya
import ObjectMapper
import DZNEmptyDataSet

class TransactionRecordController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var dataArray = [TransactionModel]()
    var pageIndex = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "交易记录"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 100
        self.tableView.register(UINib.init(nibName: "TransactionRecordCell", bundle: nil), forCellReuseIdentifier: "TransactionRecordCell")
        
        self.loadData()
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
    }

    deinit {
        print("交易记录销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    func loadData(){
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let transactonRecordList = TransactonRcord(page: self.pageIndex)
        _ = moyaProvider.rx.request(.targetWith(target: transactonRecordList)).subscribe(onSuccess: { (response) in
            let transactionListModel = Mapper<TransactonListModel>().map(jsonData: response.data)
            if let transactionModels  = transactionListModel?.datas{
                for transactionModel in transactionModels{
                    self.dataArray.append(transactionModel)
                }
            }
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: transactionListModel)
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

extension TransactionRecordController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transactionRecordCell = tableView.dequeueReusableCell(withIdentifier: "TransactionRecordCell", for: indexPath) as! TransactionRecordCell
        transactionRecordCell.configWith(transactionModel:self.dataArray[indexPath.row])
        return transactionRecordCell
    }
}

extension TransactionRecordController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "qsy_img_nojl")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "暂时还没有交易记录哦~"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:RGBA(r: 153, g: 153, b: 153, a: 1)]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
}
