//
//  PulishNextController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/24.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class PulishNextController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    
    var searchTextField:UITextField!
    var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = APP_THEME_COLOR_1
        
        let searchBarContainView = UIView.init(frame: CGRect.init(x: 15, y: 0, width: SCREEN_WIDTH-30, height: 36))
        searchBarContainView.layer.cornerRadius = 18
        searchBarContainView.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
        self.view.addSubview(searchBarContainView)
        
        self.searchTextField = UITextField.init(frame: CGRect.init(x: 18, y: 0, width: SCREEN_WIDTH-30-36, height: 36))
        self.searchTextField.borderStyle = .none
        self.searchTextField.setValue(RGBA(r: 114, g: 114, b: 114, a: 1), forKeyPath: "_placeholderLabel.textColor")
        self.searchTextField.textColor = UIColor.white
        searchBarContainView.addSubview(self.searchTextField)
        
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: searchBarContainView.frame.maxY, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-searchBarContainView.frame.maxY), style: .plain)
        self.tableView.backgroundColor = APP_THEME_COLOR_1
        self.view.addSubview(self.tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
