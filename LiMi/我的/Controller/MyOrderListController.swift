//
//  MyOrderListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import  MJRefresh
import SVProgressHUD
import Moya
import ObjectMapper
import DZNEmptyDataSet

class MyOrderListController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var pageIndex = 1
    var dataArray = [WeekendTourOrderModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "我的订单"
        
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 1000
        self.tableView.register(UINib.init(nibName: "MyTourOrderCell", bundle: nil), forCellReuseIdentifier: "MyTourOrderCell")

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }
    
    deinit {
        print("我的订单列表销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //Mark: - misc
    func loadData(){
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let myTrendList = MyOrderList(page: self.pageIndex)
        _ = moyaProvider.rx.request(.targetWith(target: myTrendList)).subscribe(onSuccess: { (response) in
            let weekendTourOrderContainModel = Mapper<WeekendTourOrderContainModel>().map(jsonData: response.data)
            if let weekendTourOrderModels = weekendTourOrderContainModel?.data{
                for weekendTourOrderModel in weekendTourOrderModels{
                    self.dataArray.append(weekendTourOrderModel)
                }
                if weekendTourOrderModels.count > 0{self.tableView.reloadData()}
            }
            self.tableView.mj_footer.endRefreshing()
            self.tableView.mj_header.endRefreshing()
            Toast.showErrorWith(model: weekendTourOrderContainModel)
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

extension MyOrderListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myTourOrderCell = tableView.dequeueReusableCell(withIdentifier: "MyTourOrderCell", for: indexPath) as! MyTourOrderCell
        myTourOrderCell.configWith(model: self.dataArray[indexPath.row])
        return myTourOrderCell
    }
}

extension MyOrderListController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "zmy_img_nodd")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "暂时还没有订单哦~"
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor:RGBA(r: 153, g: 153, b: 153, a: 1)]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
}

