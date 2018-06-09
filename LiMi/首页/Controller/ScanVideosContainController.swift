//
//  ScanVideosContainController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/8.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Moya
import ObjectMapper

class ScanVideosContainController: ViewController {
    override var prefersStatusBarHidden: Bool{return true}
    var navigationBarView:UIView!
    var backButton:UIButton!
    var bottomInputBarView:BottomInputBarView?
    private let bottomInputBarViewHeight = CGFloat(50)
    
    /*变量*/
    var _pageIndex:Int = 1
    var _dataArray:[VideoTrendModel] = [VideoTrendModel]()
    var _time:Int? = Int(Date().timeIntervalSince1970)
    var _currentVideoTrendIndex:Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scanVideosController = ScanVideosController()
        scanVideosController.delegate = self
        self.addChildViewController(scanVideosController)
        self.view.addSubview(scanVideosController.view)
        
        self.navigationBarView = UIView.init(frame: CGRect.init(x: 0, y: STATUS_BAR_HEIGHT, width: SCREEN_WIDTH, height: NAVIGATION_BAR_HEIGHT))
        //self.navigationBarView.backgroundColor = UIColor.yellow
        self.view.addSubview(self.navigationBarView)
        
        self.backButton = UIButton.init(frame: CGRect.init(x: 15, y: 0, width: 24, height: 14))
        self.backButton.setImage(UIImage.init(named: "short_video_back"), for: .normal)
        self.backButton.sizeToFit()
        var center = self.backButton.center
        center.y = NAVIGATION_BAR_HEIGHT * 0.5
        self.backButton.center = center
        self.backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        self.navigationBarView.addSubview(self.backButton)
        
        if Defaults[.userId] != nil{
            self.bottomInputBarView = BottomInputBarView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-bottomInputBarViewHeight, width: SCREEN_WIDTH, height: bottomInputBarViewHeight))
            self.bottomInputBarView?.delegate = self
            self.view.addSubview(self.bottomInputBarView!)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func keyboardWillShow(notification:Notification){
        let userInfo = notification.userInfo!
        let  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

        let deltaY = keyBoardBounds.size.height
        let animations:(() -> Void) = {[unowned self] in
            //键盘的偏移量
            if let frame = self.bottomInputBarView?.frame{
                var _frame = frame
                _frame.origin.y = SCREEN_HEIGHT  - deltaY - self.bottomInputBarViewHeight
                self.bottomInputBarView?.frame = _frame
            }
            self.bottomInputBarView?.layoutIfNeeded()
        }

        if duration > 0 {
            UIView.animate(withDuration: duration, animations: animations)
        }else{
            animations()
        }
    }
    
    @objc func keyboardWillHidden(notification:Notification){
    
        let userInfo  = notification.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations:(() -> Void) = {[unowned self] in
            //键盘的偏移量
            if let frame = self.bottomInputBarView?.frame{
                var _frame = frame
                _frame.origin.y = SCREEN_HEIGHT - self.bottomInputBarViewHeight
                self.bottomInputBarView?.frame = _frame
            }
            self.view.layoutIfNeeded()
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    @objc func backButtonClicked(){
        self.navigationController?.popViewController(animated: true)
    }

}

extension ScanVideosContainController : BottomInputBarViewDelegate{
    func sentContentButtonClicked(button: UIButton, textFeild: UITextField?) {
        let videoTrendModel = self.dataArray[currentVideoTrendIndex]
        let videoDiscussAction = VideoDiscussAction.init(video_id: videoTrendModel.id, content: textFeild?.text, parent_id: nil, parent_uid: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: videoDiscussAction)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            Toast.showResultWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
        textFeild?.resignFirstResponder()
        textFeild?.text = nil
        self.bottomInputBarView?.sentContentButton.isEnabled = false
    }
}

extension ScanVideosContainController:ScanVideosControllerDelegate{
    var pageIndex: Int {
        get {
            return _pageIndex
        }
        set {
            _pageIndex = newValue
        }
    }
    
    var dataArray: [VideoTrendModel] {
        get {
            return _dataArray
        }
        set {
            _dataArray = newValue
        }
    }
    
    var time: Int? {
        get {
            return _time
        }
        set {
            _time = newValue
        }
    }
    
    var currentVideoTrendIndex: Int {
        get {
            return _currentVideoTrendIndex
        }
        set {
            _currentVideoTrendIndex = newValue
        }
    }
    
    
    /*函数*/
    @objc func scanVideosControllerRequestDataWith(scanVideosController: ScanVideosController) {

    }
}
