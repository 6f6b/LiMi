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
    var userDetailSelectTrendsTypeCell:UserDetailSelectTrendsTypeCell?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsets.init(top: -64, left: 0, bottom: 0, right: 0)
        self.tableView.estimatedRowHeight = 100
        self.tableView.estimatedSectionFooterHeight = 100
        self.tableView.estimatedSectionHeaderHeight = 100
        self.registerTrendsCellFor(tableView: self.tableView)
        
        let moreBtn = UIButton.init(type: .custom)
        moreBtn.setImage(UIImage.init(named: "nav_btn_jubao"), for: .normal)
        moreBtn.sizeToFit()
        moreBtn.addTarget(self, action: #selector(dealMoreOperation(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: moreBtn)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    @objc func dealMoreOperation(_ sender: Any) {
        
    }
    
}

extension UserDetailsController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        return 10
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{return UITableViewAutomaticDimension}
        return 0.001
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            if let _ = self.userDetailHeadView{}else{
                self.userDetailHeadView = GET_XIB_VIEW(nibName: "UserDetailHeadView") as? UserDetailHeadView
                self.userDetailHeadView?.headImgV?.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 230)
                self.userDetailHeadView?.headImgV?.image = UIImage.init(named: "renzheng")
            }
            return userDetailHeadView
        }
        return nil
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if let _ = self.userDetailSelectTrendsTypeCell{}else{
                self.userDetailSelectTrendsTypeCell = GET_XIB_VIEW(nibName: "UserDetailSelectTrendsTypeCell") as! UserDetailSelectTrendsTypeCell
                self.userDetailSelectTrendsTypeCell?.selectTrendsTypeBlock = {(type) in
                    if type == .demand{print("选择需求")}
                    if type == .trends{print("选择动态")}
                }
            }
            return self.userDetailSelectTrendsTypeCell!
        }
        let trendCell = cellFor(indexPath: indexPath,tableView: tableView)
        trendCell.trendsTopToolsContainView.tapHeadBtnBlock = {
        }
        trendCell.trendsBottomToolsContainView.tapThumbUpBtnBlock = {
            
        }
        trendCell.trendsBottomToolsContainView.tapCommentBtnBlock = {
            let commentsWithTrendController = CommentsWithTrendController()
            self.navigationController?.pushViewController(commentsWithTrendController, animated: true)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y > 230{
//            //导航栏颜色
//            self.navigationController?.navigationBar.backgroundColor = UIColor.white
//            //返回按钮颜色
//            let backBtn = self.navigationItem.leftBarButtonItem?.customView as! UIButton
//            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
//            //title
//            self.title = "个人中心"
//            //更多
//            let moreBtn = self.navigationItem.rightBarButtonItem?.customView as! UIButton
//            moreBtn.setImage(UIImage.init(named: "btn_jubao"), for: .normal)
//        }else{
//            //导航栏颜色
//            self.navigationController?.navigationBar.backgroundColor = UIColor.clear
//            //返回按钮颜色
//            let backBtn = self.navigationItem.leftBarButtonItem?.customView as! UIButton
//            backBtn.setImage(UIImage.init(named: "nav_back"), for: .normal)
//            //title
//            self.title = nil
//            //更多
//            
//            if let moreBtn = self.navigationItem.rightBarButtonItem?.customView as? UIButton{
//                moreBtn.setImage(UIImage.init(named: "nav_btn_jubao"), for: .normal)
//            }
//        }
        return
//        let offsetY = -scrollView.contentOffset.y
//        if offsetY > 0{
//            let tmpX = -(SCREEN_WIDTH/230)*offsetY*0.5
//            let tmpY = -offsetY
//            let tmpW = SCREEN_WIDTH+(SCREEN_WIDTH/230)*offsetY
//            let tmpH = 230 + offsetY
//            self.userDetailHeadView?.headImgV?.frame = CGRect.init(x: tmpX, y: tmpY, width: tmpW, height: tmpH)
//        }else{
//            let frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 230)
//            self.userDetailHeadView?.headImgV?.frame = frame
//        }
    }
}
