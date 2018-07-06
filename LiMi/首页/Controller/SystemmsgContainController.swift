//
//  SystemmsgContainController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/5.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class SystemmsgContainController: UIViewController {
    var slidingMenuBar:SlidingMenuBar!
    var controllersContainScrollView:UIScrollView!
    var findTrendsListController:TrendsListController!
    var trendsListController:TrendsListController!
    
    var isNavigationBarHidden:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nil
        
        if let backBtn = self.navigationItem.leftBarButtonItem?.customView as?  UIButton{
            backBtn.setImage(UIImage.init(named: "btn_back_hei"), for: .normal)
        }
        
        let sumbitBtn = UIButton.init(type: .custom)
        let sumBitAttributeTitle = NSAttributedString.init(string: "清空", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)])
        sumbitBtn.setAttributedTitle(sumBitAttributeTitle, for: .normal)
        sumbitBtn.sizeToFit()
        sumbitBtn.addTarget(self, action: #selector(dealClear), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sumbitBtn)
        
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
        slidingMenuBar.rightTop1.isHidden = false
        slidingMenuBar.rightTop2.isHidden = false
        self.navigationItem.titleView = slidingMenuBar
        slidingMenuBar.tapBlock = {[unowned self] (index) in
            UIView.animate(withDuration: 0.5, animations: {
                self.controllersContainScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH*CGFloat(index), y: 0)
            })
            //0 标记所有评论为已读
            if index == 0{
                AppManager.shared.customSystemMessageManager.markAllCommentMessageRead()
            }
            //1 标记所有点赞为已读
            if index == 1{
                AppManager.shared.customSystemMessageManager.markAllThumbUpMessageRead()
            }
        }
        
        let commentsMsgListController = SystemMsgListController()
        commentsMsgListController.type = .comment
        self.addChildViewController(commentsMsgListController)
        let commentsMsgListControllerView = commentsMsgListController.view
        commentsMsgListControllerView?.frame = self.controllersContainScrollView.bounds
        self.controllersContainScrollView.addSubview(commentsMsgListControllerView!)
        
        let  thumbUpMsgListController = SystemMsgListController()
        thumbUpMsgListController.type = .thumbUp
        self.addChildViewController(thumbUpMsgListController)
        let thumbUpMsgListControllerView = thumbUpMsgListController.view
        var tmpFrame = self.controllersContainScrollView.bounds
        tmpFrame.origin.x = tmpFrame.size.width
        thumbUpMsgListControllerView?.frame = tmpFrame
        self.controllersContainScrollView.addSubview(thumbUpMsgListControllerView!)
        self.slidingMenuBar.select(index: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(customMessageUnreadCountChanged), name: customSystemMessageUnreadCountChanged, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: customSystemMessageUnreadCountChanged, object: nil)
        print("系统消息容器界面销毁")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = (self.navigationController?.navigationBar.isHidden)!
        self.navigationController?.navigationBar.isHidden = false
        
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = RGBA(r: 242, g: 242, b: 242, a: 1)
        self.navigationController?.navigationBar.setBackgroundImage(GetNavBackImg(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)]
        
        //标记评论为已读
        AppManager.shared.customSystemMessageManager.markAllCommentMessageRead()
        self.refreshNum()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = self.isNavigationBarHidden
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    @objc func dealClear(){
//        ClearMessage
        let alertController = UIAlertController(title: "确认清空所有评论和点赞通知", message: nil, preferredStyle: .alert)
        let actionCancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let actionOK = UIAlertAction.init(title: "确定", style: .default) { _ in
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            let clearMessage = ClearMessage()
            _ = moyaProvider.rx.request(.targetWith(target: clearMessage)).subscribe(onSuccess: { (response) in
                let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
                if baseModel?.commonInfoModel?.status == successState{
                    AppManager.shared.customSystemMessageManager.markAllCustomSystemMessageRead()
                    NotificationCenter.default.post(name: CLEAR_COMMENTS_AND_THUMBUP_MESSAGE_SUCCESS, object: nil)
                }
                Toast.showErrorWith(model: baseModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionOK)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func refreshNum(){
        let commentUnreadCount = AppManager.shared.customSystemMessageManager.allCommentMessageUnreadCount()
        let thumbUpUnreadCount = AppManager.shared.customSystemMessageManager.allThumbUpMessageUnreadCount()
        self.slidingMenuBar.rightTop1.isHidden = commentUnreadCount == 0 ? true : false
        self.slidingMenuBar.rightTop2.isHidden = thumbUpUnreadCount == 0 ? true : false

        self.slidingMenuBar.rightTop1.text = "\(commentUnreadCount)"
        self.slidingMenuBar.rightTop2.text = "\(thumbUpUnreadCount)"
    }
}

extension SystemmsgContainController:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= 0{self.slidingMenuBar.select(index: 0)}else{
            self.slidingMenuBar.select(index: 1)
        }
    }
}

//MARK: - Notification  通知
extension SystemmsgContainController{
    //自定义系统消息未读数改变
    @objc func  customMessageUnreadCountChanged(){
        self.refreshNum()
        if let systemMessageNumView = self.navigationItem.leftBarButtonItem?.customView as? SystemMessageNumView{
            let num = AppManager.shared.customSystemMessageManager.allCommentMessageUnreadCount() + AppManager.shared.customSystemMessageManager.allThumbUpMessageUnreadCount()
            systemMessageNumView.showWith(unreadSystemMsgNum: num)
        }
    }
}
