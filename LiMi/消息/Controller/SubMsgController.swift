
//
//  SubMsgController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/26.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MJRefresh

class SubMsgController: UIViewController {
    var tableView:UITableView!
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    var pageIndex:Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT), style: .plain)
        self.tableView.backgroundColor = APP_THEME_COLOR_1
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        
        self.navigationController?.navigationBar.barTintColor = RGBA(r: 43, g: 43, b: 43, a: 1)
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex  = 1
            self.loadData()
        }
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        self.loadData()
    }

    func loadData(){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension SubMsgController : DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "qsy")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "空空如也~"
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16),NSAttributedStringKey.foregroundColor:RGBA(r: 255, g: 255, b: 255, a: 1)]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
}
