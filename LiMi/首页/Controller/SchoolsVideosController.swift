//
//  SchoolsVideosController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/4.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class SchoolsVideosController: VideoListController {
    var collegeModel:CollegeModel?
    override var collegeId: Int?{
        return self.collegeModel?.id
    }
    override var type: Int? {
        get{return 1}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = collegeModel?.name
//        self.topBackGroundView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT))
//        self.topBackGroundView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
//        self.view.addSubview(self.topBackGroundView)
//
        self.collectionView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.dataArray.count <= 0{return}
        let followAndSchoolVideoContainController = FollowAndSchoolVideoContainController.init(type: type, currentVideoTrendIndex: indexPath.row, dataArray: self.dataArray, collegeId: self.collegeModel?.id)
        self.navigationController?.pushViewController(followAndSchoolVideoContainController, animated: true)
    }

}
