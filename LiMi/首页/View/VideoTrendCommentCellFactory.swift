//
//  VideoTrendCommentCellFactory.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/6.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class VideoTrendCommentCellFactory: NSObject {
    static let shared = VideoTrendCommentCellFactory()
    
    func registerTrendCommentCellWith(tableView:UITableView){
        tableView.register(VideoTrendCommentCell.self, forCellReuseIdentifier: "VideoTrendCommentCell")
        tableView.register(VideoTrendCommentWithSubCommentCell.self, forCellReuseIdentifier: "VideoTrendCommentWithSubCommentCell")
    }
    
    func trendCommentCellWith(indexPath:IndexPath,tableView:UITableView,commentModel:CommentModel?) -> VideoTrendCommentCell{
        if let child = commentModel?.child{
            if child.count > 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTrendCommentWithSubCommentCell", for: indexPath) as! VideoTrendCommentWithSubCommentCell
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTrendCommentCell", for: indexPath) as! VideoTrendCommentCell
        return cell
    }
}

