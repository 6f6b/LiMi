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
    var isTextAvailable = false
    var isPictureAvailable = false
    var isVideoAvailable = false
    if let content = model?.content{
        if content.lengthOfBytes(using: String.Encoding.utf8) >= 1{
                 isTextAvailable = true
        }
    }
    if let skill = model?.skill{
        if skill.lengthOfBytes(using: String.Encoding.utf8) >= 1{
            isTextAvailable = true
        }
    }
    if let pics = model?.action_pic{
        if pics.count > 0{isPictureAvailable = true}
    }
    if let videoPath = model?.action_video{
        if videoPath.lengthOfBytes(using: String.Encoding.utf8) > 2{
            isVideoAvailable = true
        }
    }
    
    //获取相应类型的cell
    var trendsCell  = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextCell", for: indexPath) as! TrendsCell
    
    //文字
    if isTextAvailable && !isPictureAvailable && !isVideoAvailable{}
    //图片
    if !isTextAvailable && isPictureAvailable && !isVideoAvailable{
        let trendsWithPictureCell = tableView.dequeueReusableCell(withIdentifier: "TrendsWithPictureCell", for: indexPath) as! TrendsWithPictureCell
        trendsCell = trendsWithPictureCell
    }
    //视频
    if !isTextAvailable && !isPictureAvailable && isVideoAvailable{
        let trendsWithVideoCell = tableView.dequeueReusableCell(withIdentifier: "TrendsWithVideoCell", for: indexPath) as! TrendsWithVideoCell
        trendsCell = trendsWithVideoCell
    }
    //文字、图片
    if isTextAvailable && isPictureAvailable && !isVideoAvailable{
        let trendsCellWithTextAndPicture = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextAndPictrueCell", for: indexPath) as! TrendsWithTextAndPictrueCell
        trendsCell = trendsCellWithTextAndPicture
    }
    //文字、视频
    if isTextAvailable && !isPictureAvailable && isVideoAvailable{
        let trendsWithTextAndVideo = tableView.dequeueReusableCell(withIdentifier: "TrendsWithTextAndVideoCell", for: indexPath) as! TrendsWithTextAndVideoCell
        trendsCell = trendsWithTextAndVideo
    }
    //重置cell
//    trendsCell
    //根据风格进行修改
    if TrendsCellStyle.normal == trendsCellStyle{
    }
    if TrendsCellStyle.inPersonCenter == trendsCellStyle{
        trendsCell.trendsTopToolsContainView.moreOperationBtn.isHidden = true
        trendsCell.trendsTopToolsContainView.releaseTime.isHidden = true
    }
    if TrendsCellStyle.inMyTrendList == trendsCellStyle{
//        trendsCell.trendsTopToolsContainView.moreOperationBtn.isHidden = true
    }
    
    //配置
    trendsCell.cellStyle = trendsCellStyle
    trendsCell.configWith(model: model)
    //相关block在对应controller中实现
    print("classNmae:\(object_getClass(trendsCell))---classSize:\(class_getInstanceSize(object_getClass(trendsCell)))")
    return trendsCell
}

func registerTrendsCellFor(tableView:UITableView){
    tableView.register(TrendsWithTextCell.self, forCellReuseIdentifier: "TrendsWithTextCell")
    tableView.register(TrendsWithPictureCell.self, forCellReuseIdentifier: "TrendsWithPictureCell")
    tableView.register(TrendsWithTextAndPictrueCell.self, forCellReuseIdentifier: "TrendsWithTextAndPictrueCell")
    tableView.register(TrendsWithVideoCell.self, forCellReuseIdentifier: "TrendsWithVideoCell")
    tableView.register(TrendsWithTextAndVideoCell.self, forCellReuseIdentifier: "TrendsWithTextAndVideoCell")
}
