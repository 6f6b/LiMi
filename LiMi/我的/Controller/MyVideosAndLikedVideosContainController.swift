//
//  MyVideosAndLikedVideosContainController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/7.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class MyVideosAndLikedVideosContainController: ViewController {
    var slidingMenuBar:SlidingMenuBar!
    var controllersContainScrollView:UIScrollView!
    var videoListMyVideo:VideoListInMyCenterController!
    var videoListILikedVideo:VideoListInMyCenterController!
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
        
        self.controllersContainScrollView = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64))
        self.controllersContainScrollView.isPagingEnabled = true
        self.controllersContainScrollView.delegate = self
        self.controllersContainScrollView.showsHorizontalScrollIndicator = false
        self.controllersContainScrollView.contentSize = CGSize.init(width: SCREEN_WIDTH*2, height: 0)
        self.view.addSubview(controllersContainScrollView)
        
        slidingMenuBar = GET_XIB_VIEW(nibName: "SlidingMenuBar") as! SlidingMenuBar
        slidingMenuBar.btnFirst.setTitle("作品", for: .normal)
        slidingMenuBar.btnSecond.setTitle("喜欢", for: .normal)
        slidingMenuBar.frame = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        self.navigationItem.titleView = slidingMenuBar
        slidingMenuBar.tapBlock = {[unowned self] (index) in
            UIView.animate(withDuration: 0.5, animations: {
                self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(index), y: 0)
            })
        }
        let videoListMyVideo = VideoListInMyCenterController.init(type: .myVideo)
        self.videoListMyVideo = videoListMyVideo
        self.addChildViewController(videoListMyVideo)
        let videoListMyVideoView = videoListMyVideo.view
        videoListMyVideoView?.frame = self.controllersContainScrollView.bounds
        self.controllersContainScrollView.addSubview(videoListMyVideoView!)
        
        let videoListILikedVideo = VideoListInMyCenterController.init(type: .iLikedVideo)
        self.videoListILikedVideo = videoListILikedVideo
        self.addChildViewController(videoListILikedVideo)
        let videoListILikedVideoView = videoListILikedVideo.view
        var tmpFrame = self.controllersContainScrollView.bounds
        tmpFrame.origin.x = tmpFrame.size.width
        videoListILikedVideoView?.frame = tmpFrame
        self.controllersContainScrollView.addSubview(videoListILikedVideoView!)
        self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*1, y: 0)
        
        self.slidingMenuBar.select(index: self.initialIndex)
        self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(self.initialIndex), y: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

extension MyVideosAndLikedVideosContainController:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= 0{self.slidingMenuBar.select(index: 0)}else{
            self.slidingMenuBar.select(index: 1)
        }
    }
}
