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
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default

        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        self.navigationController?.navigationBar.shadowImage = GetImgWith(size: CGSize.init(width: SCREEN_WIDTH, height: NAVIGATION_BAR_SEPARATE_LINE_HEIGHT), color: NAVIGATION_BAR_SEPARATE_COLOR)
    }
}

