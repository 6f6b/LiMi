//
//  TrendsCellFactory.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation

enum TrendsCellStyle {
    case normal //正常
    case inPersonCenter   //用户主页中
    case inMyTrendList   //我的动态列表中
}

func cellFor(indexPath:IndexPath,tableView:UITableView,model:TrendModel?,trendsCellStyle:TrendsCellStyle = .normal)->TrendsCell{
    //获取相应类型的cell
    var trendsCell  = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextCell", for: indexPath) as! TrendsCell
    if let  trendModel = model{
        if let pics = trendModel.action_pic{
            if pics.count > 0{
                let trendsCellWithTextAndPicture = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextAndPictrueCell", for: indexPath) as! TrendsWithTextAndPictrueCell
                trendsCell = trendsCellWithTextAndPicture
            }
        }
        if let videoPath = model?.action_video{
            if videoPath.lengthOfBytes(using: String.Encoding.utf8) >= 2{
                let trendsWithTextAndVideo = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextAndVideoCell", for: indexPath) as! TrendsWithTextAndVideoCell
                trendsCell = trendsWithTextAndVideo
            }
        }
    }
    //重置cell
//    trendsCell
    //根据风格进行修改
    if TrendsCellStyle.normal == trendsCellStyle{
    }
    if TrendsCellStyle.inPersonCenter == trendsCellStyle{
        trendsCell.trendsTopToolsContainView.moreOperationBtn.isHidden = true
    }
    if TrendsCellStyle.inMyTrendList == trendsCellStyle{
//        trendsCell.trendsTopToolsContainView.moreOperationBtn.isHidden = true
    }
    
    //配置
    trendsCell.configWith(model: model)
    //相关block在对应controller中实现
    return trendsCell
}

func registerTrendsCellFor(tableView:UITableView){
    tableView.register(TrendsWithTextCell.self, forCellReuseIdentifier: "TrendsWithTextCell")
    tableView.register(TrendsWithPictureCell.self, forCellReuseIdentifier: "TrendsWithPictureCell")
    tableView.register(TrendsWithTextAndPictrueCell.self, forCellReuseIdentifier: "TrendsWithTextAndPictrueCell")
    tableView.register(TrendsWithVideoCell.self, forCellReuseIdentifier: "TrendsWithVideoCell")
    tableView.register(TrendsWithTextAndVideoCell.self, forCellReuseIdentifier: "TrendsWithTextAndVideoCell")
}
