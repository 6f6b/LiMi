//
//  CatchRedPacketView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class CatchRedPacketView: UIView {
    @IBOutlet weak var redPacketInfoContainView: UIView!
    @IBOutlet weak var redPacketInfoBackgroundImg: UIImageView!
    @IBOutlet weak var catchFaildContainView: UIView!
    @IBOutlet weak var catchSuccessContainView: UIView!
    @IBOutlet weak var catchAmount: UILabel!
    @IBOutlet weak var catchSuccessedUsersTableView: UITableView!
    
    @IBOutlet weak var openRedPacketContainView: UIView!
    
    //MARK: - misc
    @IBAction func dealCatch(_ sender: Any) {
        self.showWith(isSuccess: false)
    }
    
    @IBAction func dealClose(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    func showWith(isSuccess:Bool){
        openRedPacketContainView.isHidden = true
        redPacketInfoContainView.isHidden = false
        
        self.redPacketInfoBackgroundImg.isHighlighted = !isSuccess
        self.catchFaildContainView.isHidden = isSuccess
        self.catchSuccessContainView.isHidden = !isSuccess
        self.catchAmount.text = "100.00"
    }
}
