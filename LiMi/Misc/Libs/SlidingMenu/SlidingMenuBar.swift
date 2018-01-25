//
//  SlidingMenuBar.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SlidingMenuBar: UIView {
    @IBOutlet weak var lineFirst: UIView!
    @IBOutlet weak var lineSecond: UIView!
    @IBOutlet weak var btnFirst: UIButton!
    @IBOutlet weak var btnSecond: UIButton!
    var tapBlock:((Int)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineSecond.isHidden = true
        
        self.lineFirst.layer.cornerRadius = 1.5
        self.lineFirst.clipsToBounds = true
        
        self.lineSecond.layer.cornerRadius = 1.5
        self.lineSecond.clipsToBounds = true
    }
    
    func select(index:Int){
        lineFirst.isHidden = index == 0 ? false:true
        lineSecond.isHidden = index == 1 ? false:true
    }
    
    @IBAction func dealTapMenu(_ sender: Any) {
        let btn = sender as! UIButton
        lineFirst.isHidden = btn.tag == 0 ? false:true
        lineSecond.isHidden = btn.tag == 1 ? false:true
        if let _tapBlock = self.tapBlock{
            _tapBlock(btn.tag)
        }
    }
    
}
