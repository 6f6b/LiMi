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
    @IBOutlet weak var rightTop1: UILabel!
    @IBOutlet weak var rightTop2: UILabel!
    
    let selectedTitleColor = UIColor.white
    let bottomLineColor = UIColor.white
    let desSelectedTitleColor = RGBA(r: 114, g: 114, b: 114, a: 1)
    
    var tapBlock:((Int)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lineFirst.backgroundColor = bottomLineColor
        self.lineSecond.backgroundColor = bottomLineColor
        
        lineSecond.isHidden = true
        
        self.lineFirst.layer.cornerRadius = 1.5
        self.lineFirst.clipsToBounds = true
        
        self.lineSecond.layer.cornerRadius = 1.5
        self.lineSecond.clipsToBounds = true
        
        self.rightTop1.layer.cornerRadius = 7
        self.rightTop1.clipsToBounds = true
        
        self.rightTop2.layer.cornerRadius = 7
        self.rightTop2.clipsToBounds = true
    }
    
    func select(index:Int){
        lineFirst.isHidden = index == 0 ? false:true
        lineSecond.isHidden = index == 1 ? false:true
        let btnFirstTitleColor = index == 0 ? selectedTitleColor : desSelectedTitleColor
        let btnSecondTitleColor = index == 1 ? selectedTitleColor  : desSelectedTitleColor
        self.btnFirst.setTitleColor(btnFirstTitleColor, for: .normal)
        self.btnSecond.setTitleColor(btnSecondTitleColor, for: .normal)
        
    }
    
    @IBAction func dealTapMenu(_ sender: Any) {
        let btn = sender as! UIButton
        self.select(index: btn.tag)
        if let _tapBlock = self.tapBlock{
            _tapBlock(btn.tag)
        }
    }
    
}
