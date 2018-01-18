//
//  HomePageController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class HomePageController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let trendsListController = TrendsListController()
        self.addChildViewController(trendsListController)
        let trendsListControllerView = trendsListController.view
        trendsListControllerView?.frame = self.view.bounds
        self.view.addSubview(trendsListControllerView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
