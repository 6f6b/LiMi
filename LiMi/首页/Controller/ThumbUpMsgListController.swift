//
//  ThumbUpMsgListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/5.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ThumbUpMsgListController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "SystemMsgWithThumUpOrCommentsCell", bundle: nil), forCellReuseIdentifier: "SystemMsgWithThumUpOrCommentsCell")
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
        // Dispose of any resources that can be recreated.
    }


}

extension ThumbUpMsgListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let systemMsgWithThumUpOrCommentsCell = tableView.dequeueReusableCell(withIdentifier: "SystemMsgWithThumUpOrCommentsCell", for: indexPath) as! SystemMsgWithThumUpOrCommentsCell
        return systemMsgWithThumUpOrCommentsCell
    }
}
