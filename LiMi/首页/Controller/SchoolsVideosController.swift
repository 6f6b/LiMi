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
        return self.collegeModel?.coid
    }
    override var type: Int? {
        get{return 1}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let followAndSchoolVideoContainController = FollowAndSchoolVideoContainController.init(type: type, currentVideoTrendIndex: indexPath.row, dataArray: self.dataArray, collegeId: self.collegeModel?.id)
        self.navigationController?.pushViewController(followAndSchoolVideoContainController, animated: true)
    }

}
