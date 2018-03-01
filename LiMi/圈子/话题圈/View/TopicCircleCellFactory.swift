//
//  TopicCircleCellFactory.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation

protocol TopicCircleCellProtocol {
    func configWith(topicCircleModel:TopicCircleModel?)
}

class TopicCircleCellFactory {
    static func cellFor(indexPath:IndexPath,tableView:UITableView,model:TopicCircleModel?,trendsCellStyle:TrendsCellStyle = .normal)->TopicCircleCellProtocol{
        let topicCircleCell:TopicCircleCellProtocol!
        if model?.pics?.count == 0{
            topicCircleCell = tableView.dequeueReusableCell(withIdentifier: "TopicCircleWithTextCell", for: indexPath) as! TopicCircleCellProtocol
        }else{
            topicCircleCell = tableView.dequeueReusableCell(withIdentifier: "TopicCircleWithPictureCell", for: indexPath) as! TopicCircleCellProtocol
        }
        topicCircleCell.configWith(topicCircleModel: model)
        return topicCircleCell
    }
    
    static func registerTrendsCellFor(tableView:UITableView){
        tableView.register(TopicCircleWithTextCell.self, forCellReuseIdentifier: "TopicCircleWithTextCell")
        tableView.register(TopicCircleWithPictureCell.self, forCellReuseIdentifier: "TopicCircleWithPictureCell")
    }
}
