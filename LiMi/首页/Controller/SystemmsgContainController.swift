//
//  SystemmsgContainController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/5.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SystemmsgContainController: ViewController {
    var slidingMenuBar:SlidingMenuBar!
    var controllersContainScrollView:UIScrollView!
    var findTrendsListController:TrendsListController!
    var trendsListController:TrendsListController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nil
        
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
//        let filter = NIMSystemNotificationFilter.init()
//        filter.notificationTypes
//        NIMSDK.shared().systemNotificationManager.allUnreadCount(<#T##filter: NIMSystemNotificationFilter?##NIMSystemNotificationFilter?#>)
        
        self.controllersContainScrollView = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64))
        self.controllersContainScrollView.isPagingEnabled = true
        self.controllersContainScrollView.delegate = self
        self.controllersContainScrollView.showsHorizontalScrollIndicator = false
        self.controllersContainScrollView.contentSize = CGSize.init(width: SCREEN_WIDTH*2, height: 0)
        self.view.addSubview(controllersContainScrollView)
        
        slidingMenuBar = GET_XIB_VIEW(nibName: "SlidingMenuBar") as! SlidingMenuBar
        slidingMenuBar.btnFirst.setTitle("评论", for: .normal)
        slidingMenuBar.btnSecond.setTitle("点赞", for: .normal)
        slidingMenuBar.frame = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        slidingMenuBar.btnFirst.setTitleColor(RGBA(r: 51, g: 51, b: 51, a: 1), for: .normal)
        slidingMenuBar.btnSecond.setTitleColor(RGBA(r: 51, g: 51, b: 51, a: 1), for: .normal)
        slidingMenuBar.lineFirst.backgroundColor = RGBA(r: 51, g: 51, b:51 , a: 1)
        slidingMenuBar.lineSecond.backgroundColor = RGBA(r: 51, g: 51, b:51 , a: 1)
        slidingMenuBar.rightTop1.isHidden = false
        slidingMenuBar.rightTop2.isHidden = false
        self.navigationItem.titleView = slidingMenuBar
        slidingMenuBar.tapBlock = {(index) in
            UIView.animate(withDuration: 0.5, animations: {
                self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(index), y: 0)
            })
        }
        
        let commentsMsgListController = CommentsMsgListController()
        self.addChildViewController(commentsMsgListController)
        let commentsMsgListControllerView = commentsMsgListController.view
        commentsMsgListControllerView?.frame = self.controllersContainScrollView.bounds
        self.controllersContainScrollView.addSubview(commentsMsgListControllerView!)
        
        let  thumbUpMsgListController = ThumbUpMsgListController()
        self.addChildViewController(thumbUpMsgListController)
        let thumbUpMsgListControllerView = thumbUpMsgListController.view
        var tmpFrame = self.controllersContainScrollView.bounds
        tmpFrame.origin.x = tmpFrame.size.width
        thumbUpMsgListControllerView?.frame = tmpFrame
        self.controllersContainScrollView.addSubview(thumbUpMsgListControllerView!)
        self.slidingMenuBar.select(index: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension SystemmsgContainController:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= 0{self.slidingMenuBar.select(index: 0)}else{
            self.slidingMenuBar.select(index: 1)
        }
    }
}
