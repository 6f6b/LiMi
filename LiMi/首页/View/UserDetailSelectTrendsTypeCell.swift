//
//  UserDetailSelectTrendsTypeCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

enum TrendsType {
    case demand
    case trends
}

class UserDetailSelectTrendsTypeCell: UITableViewCell {
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    
    var selectTrendsBlock:((Int)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.v1.layer.cornerRadius = 1.5
        self.v2.layer.cornerRadius = 1.5
        self.showWith(index: 0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - misc
    func showWith(index:Int){
        
        if 0 == index{
            self.btn1.isSelected = true
            self.btn2.isSelected = false
            self.v1.isHidden = false
            self.v2.isHidden = true
        }else{
            self.btn1.isSelected = false
            self.btn2.isSelected = true
            self.v1.isHidden = true
            self.v2.isHidden = false
        }
    }
    
    @IBAction func dealSelectTrendsWith(_ sender: Any) {
        let btn = sender as! UIButton
        self.showWith(index: btn.tag)
        if let _selectTrendsTypeBlock = self.selectTrendsBlock{
            _selectTrendsTypeBlock(btn.tag)
        }
    }
}













