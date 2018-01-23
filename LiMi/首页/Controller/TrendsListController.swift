//
//  TrendsListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TrendsListController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的动态"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 100
        self.tableView.register(TrendsWithTextCell.self, forCellReuseIdentifier: "TrendsWithTextCell")
        self.tableView.register(TrendsWithPictureCell.self, forCellReuseIdentifier: "TrendsWithPictureCell")
        self.tableView.register(TrendsWithTextAndPictrueCell.self, forCellReuseIdentifier: "TrendsWithTextAndPictrueCell")
        self.tableView.register(TrendsWithVideoCell.self, forCellReuseIdentifier: "TrendsWithVideoCell")
        self.tableView.register(TrendsWithTextAndVideoCell.self, forCellReuseIdentifier: "TrendsWithTextAndVideoCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension TrendsListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trendCell = cellFor(indexPath: indexPath,tableView: tableView)
        trendCell.trendsTopToolsContainView.tapHeadBtnBlock = {
            let userDetailsController = UserDetailsController()
            self.navigationController?.pushViewController(userDetailsController, animated: true)
        }
        trendCell.trendsBottomToolsContainView.tapThumbUpBtnBlock = {
            
        }
        trendCell.trendsBottomToolsContainView.tapCommentBtnBlock = {
            let commentsWithTrendController = CommentsWithTrendController()
            self.navigationController?.pushViewController(commentsWithTrendController, animated: true)
        }
        trendCell.catchRedPacketBlock = {
            let catchRedPacketView = GET_XIB_VIEW(nibName: "CatchRedPacketView") as! CatchRedPacketView
            catchRedPacketView.frame = SCREEN_RECT
            UIApplication.shared.keyWindow?.addSubview(catchRedPacketView)
        }
        return trendCell
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
