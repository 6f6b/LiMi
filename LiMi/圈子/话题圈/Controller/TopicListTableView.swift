//
//  TopicListTableView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/29.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TopicListTableView: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func reloadData() {
        super.reloadData()
        print("刷新整个")
    }
    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        super.reloadRows(at: indexPaths, with: animation)
        print("刷新单行")
    }
}
