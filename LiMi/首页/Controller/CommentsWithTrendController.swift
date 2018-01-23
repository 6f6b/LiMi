//
//  CommentsWithTrendController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/20.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class CommentsWithTrendController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "评论"
        
        let backBtn = UIButton.init(type: .custom)
        backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        backBtn.sizeToFit()
        backBtn.addTarget(self, action: #selector(dealBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 100
        self.tableView.register(TrendsWithTextCell.self, forCellReuseIdentifier: "TrendsWithTextCell")
        self.tableView.register(TrendCommentCell.self, forCellReuseIdentifier: "TrendCommentCell")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
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

    // MARK: - misc
    @objc func dealBack(){
        self.navigationController?.popViewController(animated: true)
    }

}

extension CommentsWithTrendController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        else{return 10}
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{return 0.001}
        return 47
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{return 7}
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let commentListHeaderView = CommentListHeaderView()
            return commentListHeaderView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let trendsWithTextCell = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextCell", for: indexPath)
            return trendsWithTextCell
        }
        if indexPath.section == 1{
            let trendCommentCell = tableView.dequeueReusableCell(withIdentifier: "TrendCommentCell", for: indexPath)
            return trendCommentCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
