//
//  HomePageController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class HomePageController: ViewController {
    var slidingMenuBar:SlidingMenuBar!
    var controllersContainScrollView:UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screeningBtn = UIButton.init(type: .custom)
        screeningBtn.setImage(UIImage.init(named: "nav_icon_sx"), for: .normal)
        screeningBtn.sizeToFit()
        screeningBtn.addTarget(self, action: #selector(dealScreening), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: screeningBtn)
        
        self.controllersContainScrollView = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64-49))
        self.controllersContainScrollView.isPagingEnabled = true
        self.controllersContainScrollView.delegate = self
        self.controllersContainScrollView.showsHorizontalScrollIndicator = false
        self.controllersContainScrollView.contentSize = CGSize.init(width: SCREEN_WIDTH*2, height: 0)
        self.view.addSubview(controllersContainScrollView)
        
        slidingMenuBar = GET_XIB_VIEW(nibName: "SlidingMenuBar") as! SlidingMenuBar
        slidingMenuBar.frame = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        self.navigationItem.titleView = slidingMenuBar
        slidingMenuBar.tapBlock = {(index) in
            UIView.animate(withDuration: 0.5, animations: {
                self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(index), y: 0)
            })
        }
        
        let trendsListController = TrendsListController()
        self.addChildViewController(trendsListController)
        let trendsListControllerView = trendsListController.view
        trendsListControllerView?.frame = self.controllersContainScrollView.bounds
        self.controllersContainScrollView.addSubview(trendsListControllerView!)
        
        let findTrendsListController = TrendsListController()
        self.addChildViewController(findTrendsListController)
        let findTrendsListControllerView = findTrendsListController.view
        var tmpFrame = self.controllersContainScrollView.bounds
        tmpFrame.origin.x = tmpFrame.size.width
        findTrendsListControllerView?.frame = tmpFrame
        self.controllersContainScrollView.addSubview(findTrendsListControllerView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: -misc
    @objc func dealScreening(){
        let conditionScreeningView = GET_XIB_VIEW(nibName: "ConditionScreeningView") as! ConditionScreeningView
        conditionScreeningView.frame = SCREEN_RECT
        UIApplication.shared.keyWindow?.addSubview(conditionScreeningView)
    }

}

extension HomePageController:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scroll")
        if scrollView.contentOffset.x <= 0{self.slidingMenuBar.select(index: 0)}else{
            self.slidingMenuBar.select(index: 1)
        }
    }
}

