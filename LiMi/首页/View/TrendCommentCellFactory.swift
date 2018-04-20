//
//  TrendCommentCellFactory.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/17.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TrendCommentCellFactory: NSObject {
    static let shared = TrendCommentCellFactory()
    
    func registerTrendCommentCellWith(tableView:UITableView){
        tableView.register(TrendCommentCell.self, forCellReuseIdentifier: "TrendCommentCell")
        tableView.register(TrendCommentWithSubCommentCell.self, forCellReuseIdentifier: "TrendCommentWithSubCommentCell")
    }
    
    func trendCommentCellWith(indexPath:IndexPath,tableView:UITableView,commentModel:CommentModel?) -> TrendCommentCell{
        if let child = commentModel?.child{
            if child.count > 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrendCommentWithSubCommentCell", for: indexPath) as! TrendCommentWithSubCommentCell
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrendCommentCell", for: indexPath) as! TrendCommentCell
        return cell
    }
}
