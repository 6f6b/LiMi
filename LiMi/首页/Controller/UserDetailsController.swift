//
//  UserDetailsController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class UserDetailsController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var userDetailHeadView:UserDetailHeadView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "用户详情"

        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsets.init(top: -20, left: 0, bottom: 0, right: 0)
        self.tableView.estimatedRowHeight = 100
        self.tableView.estimatedSectionFooterHeight = 100
        self.tableView.estimatedSectionHeaderHeight = 100
        self.registerTrendsCellFor(tableView: self.tableView)
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.isHidden = true
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    @IBAction func dealBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dealMoreOperation(_ sender: Any) {
    }
    
}

extension UserDetailsController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let _ = self.userDetailHeadView{}else{
            self.userDetailHeadView = GET_XIB_VIEW(nibName: "UserDetailHeadView") as? UserDetailHeadView
        }
        return userDetailHeadView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trendCell = cellFor(indexPath: indexPath,tableView: tableView)
        trendCell.trendsTopToolsContainView.tapHeadBtnBlock = {
//            let userDetailsController = UserDetailsController()
//            self.navigationController?.pushViewController(userDetailsController, animated: true)
        }
        trendCell.trendsBottomToolsContainView.tapThumbUpBtnBlock = {
            
        }
        trendCell.trendsBottomToolsContainView.tapCommentBtnBlock = {
            let commentsWithTrendController = CommentsWithTrendController()
            self.navigationController?.pushViewController(commentsWithTrendController, animated: true)
        }
        return trendCell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let ratio = 1 +  (-scrollView.contentOffset.y/SCREEN_WIDTH)
        if ratio >= 1{
            self.userDetailHeadView?.headImgVHeightConstraint.constant = (self.userDetailHeadView?.headImgVHeightConstraint.constant)!*ratio
        }else{self.userDetailHeadView?.headImgVHeightConstraint.constant = 230}
    }
    
    func cellFor(indexPath:IndexPath,tableView:UITableView)->TrendsCell{
        var trendsCell:TrendsCell!
        if indexPath.row == 0{
            trendsCell = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextCell", for: indexPath) as! TrendsCell
        }
        if indexPath.row == 1{
            trendsCell = tableView.dequeueReusableCell(withIdentifier: "TrendsWithPictureCell", for: indexPath) as! TrendsCell
        }
        if indexPath.row == 2{
            trendsCell = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextAndPictrueCell", for: indexPath) as! TrendsCell
        }
        if indexPath.row == 3{
            trendsCell = tableView.dequeueReusableCell(withIdentifier: "TrendsWithVideoCell", for: indexPath) as! TrendsCell
        }
        if indexPath.row == 4{
            trendsCell = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextAndVideoCell", for: indexPath) as! TrendsCell
        }else{
            trendsCell = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextCell", for: indexPath) as! TrendsCell
        }
        return trendsCell
    }
    func registerTrendsCellFor(tableView:UITableView){
        tableView.register(TrendsWithTextCell.self, forCellReuseIdentifier: "TrendsWithTextCell")
        tableView.register(TrendsWithPictureCell.self, forCellReuseIdentifier: "TrendsWithPictureCell")
        tableView.register(TrendsWithTextAndPictrueCell.self, forCellReuseIdentifier: "TrendsWithTextAndPictrueCell")
        tableView.register(TrendsWithVideoCell.self, forCellReuseIdentifier: "TrendsWithVideoCell")
        tableView.register(TrendsWithTextAndVideoCell.self, forCellReuseIdentifier: "TrendsWithTextAndVideoCell")
    }
    
}
