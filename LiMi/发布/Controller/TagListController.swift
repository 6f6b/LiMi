//
//  TagListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/21.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SnapKit

class TagListController: UIViewController {
    var topConverView:UIView!   //顶部半透明覆盖
    var bottomContainView:UIView!   //底部容器
    var infoLabel:UILabel!
    var collectionView:UICollectionView!    //标签容器
    var cancelBtn:UIButton! //取消按钮
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    deinit {
        print("标签列表界面销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    // MARK: -misc

}
