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
        self.navigationBar.setBackgroundImage(self.getNavBackImg(), for: .default)
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
        super.pushViewController(viewController, animated: true)
    }
    //导航栏返回按钮执行pop事件
    @objc func dealTapBack(){
        self.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - 返回一个渐变色图片
    func getNavBackImg()->UIImage{
        let layer = CAGradientLayer()
        let frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 64)
        layer.frame = frame
        layer.colors = [RGBA(r: 47, g: 196, b: 233, a: 1).cgColor,RGBA(r: 47, g: 196, b: 233, a: 1).cgColor]
        layer.locations = [0.0, 1]
        layer.startPoint = CGPoint.init(x: 0, y: 0)
        layer.endPoint = CGPoint.init(x: 1, y: 1)
        
        let viewForImg = UIView.init(frame: frame)
        viewForImg.layer.addSublayer(layer)
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1)
        viewForImg.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }

}
