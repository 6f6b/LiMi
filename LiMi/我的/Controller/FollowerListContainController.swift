//
//  FollowerListContainController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/4.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class FollowerListContainController: ViewController {
    var slidingMenuBar:SlidingMenuBar!
    var controllersContainScrollView:UIScrollView!
    var myFollowsController:FollowerListController!
    var myFollowersController:FollowerListController!
    var initialIndex = 0
    init(initialIndex:Int) {
        super.init(nibName: nil, bundle: nil)
        self.initialIndex = initialIndex
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let addFollowersBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        addFollowersBtn.setImage(UIImage.init(named: "nav_ic_tjgz"), for: .normal)
        addFollowersBtn.addTarget(self, action: #selector(dealToAddFollowers), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: addFollowersBtn)
        
        self.controllersContainScrollView = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64-49))
        self.controllersContainScrollView.isPagingEnabled = true
        self.controllersContainScrollView.delegate = self
        self.controllersContainScrollView.showsHorizontalScrollIndicator = false
        self.controllersContainScrollView.contentSize = CGSize.init(width: SCREEN_WIDTH*2, height: 0)
        self.view.addSubview(controllersContainScrollView)
        
        slidingMenuBar = GET_XIB_VIEW(nibName: "SlidingMenuBar") as! SlidingMenuBar
        slidingMenuBar.btnFirst.setTitle("关注", for: .normal)
        slidingMenuBar.btnSecond.setTitle("粉丝", for: .normal)
        slidingMenuBar.frame = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        self.navigationItem.titleView = slidingMenuBar
        slidingMenuBar.tapBlock = {[unowned self] (index) in
            UIView.animate(withDuration: 0.5, animations: {
                self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(index), y: 0)
            })
        }
        let myFollowsController = FollowerListController.init(followType: .follows)
        self.myFollowsController = myFollowsController
        self.addChildViewController(myFollowsController)
        let myFollowsControllerView = myFollowsController.view
        myFollowsControllerView?.frame = self.controllersContainScrollView.bounds
        self.controllersContainScrollView.addSubview(myFollowsControllerView!)
        
        let myFollowersController = FollowerListController.init(followType: .followers)
        self.myFollowersController = myFollowersController
        self.addChildViewController(myFollowersController)
        let myFollowersControllerView = myFollowersController.view
        var tmpFrame = self.controllersContainScrollView.bounds
        tmpFrame.origin.x = tmpFrame.size.width
        myFollowersControllerView?.frame = tmpFrame
        self.controllersContainScrollView.addSubview(myFollowersControllerView!)
        self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*1, y: 0)
        
        self.slidingMenuBar.select(index: self.initialIndex)
        self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(self.initialIndex), y: 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - misc
    @objc func dealToAddFollowers(){
        let addFollowersController = AddFollowersController()
        self.present(addFollowersController, animated: true, completion: nil)
    }

}

extension FollowerListContainController:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= 0{self.slidingMenuBar.select(index: 0)}else{
            self.slidingMenuBar.select(index: 1)
        }
    }
}
