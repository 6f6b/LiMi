//
//  VideoListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/4.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

class VideoListController: ViewController {
    var topBackGroundView:UIView!
    var collectionView:UICollectionView!
    var bottomBackGroundView:UIView!
    var dataArray = [VideoTrendModel]()
    var pageIndex:Int = 1
    var oldTime:String?
    var newTime:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topBackGroundView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT))
        self.topBackGroundView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.view.addSubview(self.topBackGroundView)
        
        let collectionFrame = CGRect.init(x: 0, y: STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-TAB_BAR_HEIGHT)
        let layOut = UICollectionViewLayout.init()
        self.collectionView = UICollectionView.init(frame: collectionFrame, collectionViewLayout: layOut)
        self.collectionView.backgroundColor = RGBA(r: 255, g: 30, b: 30, a: 1)
        self.view.addSubview(self.collectionView)
        
        self.bottomBackGroundView = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-TAB_BAR_HEIGHT, width: SCREEN_WIDTH, height: TAB_BAR_HEIGHT))
        self.bottomBackGroundView.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        self.view.addSubview(self.bottomBackGroundView)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
