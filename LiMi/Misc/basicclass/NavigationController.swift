//
//  NavigationController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            //push时隐藏TabBar
            viewController.hidesBottomBarWhenPushed = true
            //替换ViewController的导航栏返回按钮
            let backBtn = UIButton.init(type: .custom)
            backBtn.setImage(UIImage.init(named: "back"), for: .normal)
            backBtn.sizeToFit()
            backBtn.addTarget(self, action: #selector(dealTapBack), for: .touchUpInside)
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
        }
        super.pushViewController(viewController, animated: animated)
    }
    //导航栏返回按钮执行pop事件
    @objc func dealTapBack(){
        self.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
