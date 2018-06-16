//
//  MoreOperationController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/6.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
protocol MoreOperationControllerDelegate {
    func moreOperationReportClicked()
    func moreOperationBlackClicked()
    func moreOperationDeleteClicked()
}
class MoreOperationController: ViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var deleteContainVIew: UIView!
    
    @IBOutlet weak var bottomTopView: UIView!
    @IBOutlet weak var topView: UIView!
    var statusBarHidden:Bool = false
    override var prefersStatusBarHidden: Bool{
        return self.statusBarHidden
    }
    var videoTrendModel:VideoTrendModel?
    
    var delegate:MoreOperationControllerDelegate?
    
//    var reportButton:UIButton!
//    var blackButton:UIButton!
//    var deleteButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        let tapTopView = UITapGestureRecognizer.init(target: self, action: #selector(clickedCancelButton(_:)))
        self.topView.addGestureRecognizer(tapTopView)
        if self.videoTrendModel?.user_id != Defaults[.userId] || Defaults[.userId] == nil{
            self.deleteContainVIew.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction @objc func clickedCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func reportButtonClicked(_ sender: Any) {
        self.delegate?.moreOperationReportClicked()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func blackButtonClicked(_ sender: Any) {
        self.delegate?.moreOperationBlackClicked()
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func deleteButtonClicked(_ sender: Any) {
        self.delegate?.moreOperationDeleteClicked()
        self.dismiss(animated: true, completion: nil)

    }
}
