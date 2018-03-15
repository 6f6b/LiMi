//
//  ViewController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/8.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
//import SVProgressHUD
//import ObjectMapper
//import Moya

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("收到内存警告！！！！！！！！！！！！！！！！！！！！！")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        UIApplication.shared.statusBarStyle = .lightContent
//        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
//        self.navigationController?.navigationBar.tintColor = UIColor.white
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: APP_THEME_COLOR), for: .default)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        self.navigationController?.navigationBar.shadowImage = GetImgWith(size: CGSize.init(width: SCREEN_WIDTH, height: 0.2), color: RGBA(r: 234, g: 234, b: 234, a: 1))

    }
}

