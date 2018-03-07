//
//  TopicListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TopicListContainController: ViewController {
    var slidingMenuBar:SlidingMenuBar!
    var controllersContainScrollView:UIScrollView!
    var newestTopicListController:TopicListController!
    var hottestTopicListController:TopicListController!
    var addTopicBtn:UIButton!
    var topicCircleModel:TopicCircleModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
        self.controllersContainScrollView = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64))
        self.controllersContainScrollView.isPagingEnabled = true
        self.controllersContainScrollView.delegate = self
        self.controllersContainScrollView.showsHorizontalScrollIndicator = false
        self.controllersContainScrollView.contentSize = CGSize.init(width: SCREEN_WIDTH*2, height: 0)
        self.view.addSubview(controllersContainScrollView)
        
        slidingMenuBar = GET_XIB_VIEW(nibName: "SlidingMenuBar") as! SlidingMenuBar
        slidingMenuBar.btnFirst.setTitle("最新", for: .normal)
        slidingMenuBar.btnSecond.setTitle("最热", for: .normal)
        slidingMenuBar.frame = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        self.navigationItem.titleView = slidingMenuBar
        slidingMenuBar.tapBlock = {(index) in
            UIView.animate(withDuration: 0.5, animations: {
                self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(index), y: 0)
            })
        }
        let newestTopicListController = TopicListController()
        newestTopicListController.topicCircleModel = self.topicCircleModel
        self.newestTopicListController = newestTopicListController
        newestTopicListController.topicType = .newest
        self.addChildViewController(newestTopicListController)
        let newestTopicListControllerView = newestTopicListController.view
        newestTopicListControllerView?.frame = self.controllersContainScrollView.bounds
        self.controllersContainScrollView.addSubview(newestTopicListControllerView!)
        
        let  hottestTopicListController = TopicListController()
        hottestTopicListController.topicCircleModel = self.topicCircleModel
        self.hottestTopicListController = hottestTopicListController
        hottestTopicListController.topicType = .hottest
        self.addChildViewController(hottestTopicListController)
        let hottestTopicListControllerView = hottestTopicListController.view
        var tmpFrame = self.controllersContainScrollView.bounds
        tmpFrame.origin.x = tmpFrame.size.width
        hottestTopicListControllerView?.frame = tmpFrame
        self.controllersContainScrollView.addSubview(hottestTopicListControllerView!)
        self.slidingMenuBar.select(index: 0)
        
        self.addTopicBtn = SuitableHotSpaceButton(type: .custom)
        self.addTopicBtn.setImage(UIImage.init(named: "ic_publish_pressed"), for: .normal)
        self.addTopicBtn.sizeToFit()
        self.addTopicBtn.addTarget(self, action: #selector(dealAddTopic), for: .touchUpInside)
        self.view.addSubview(self.addTopicBtn)
        self.addTopicBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-15)
            make.bottom.equalTo(self.view).offset(-44)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(dealPostTopicSuccess), name: POST_TOPIC_SUCCESS_NOTIFICATION, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: POST_TOPIC_SUCCESS_NOTIFICATION, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Mark: - misc
    @objc func dealPostTopicSuccess(){
        self.slidingMenuBar.select(index: 0)
        if let _tapBlock = self.slidingMenuBar.tapBlock{
            _tapBlock(0)
        }
    }
    
    @objc func dealAddTopic(){
        let creatTopicController = CreatTopicController()
        creatTopicController.topicCircleModel = self.topicCircleModel
        let navCreatTopicController = NavigationController(rootViewController: creatTopicController)
        self.present(navCreatTopicController, animated: true, completion: nil)
    }
    
}

extension TopicListContainController:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= 0{self.slidingMenuBar.select(index: 0)}else{
            self.slidingMenuBar.select(index: 1)
        }
    }
}

