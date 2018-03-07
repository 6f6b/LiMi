//
//  WeekendTourOrderNumCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class WeekendTourOrderNumCell: UITableViewCell {
    @IBOutlet weak var orderNumInfo: UILabel!
    var numChangedBlock:((Int)->Void)?
    var orderNum:Int = 1
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func dealReduce(_ sender: Any) {
        if self.orderNum <= 1{return}
        self.orderNum -= 1
        self.showWith(orderNum: self.orderNum)
        if let _numChangedBlock = self.numChangedBlock{
            _numChangedBlock(self.orderNum)
        }
    }
    
    @IBAction func dealAdd(_ sender: Any) {
        self.orderNum += 1
        self.showWith(orderNum: self.orderNum)
        if let _numChangedBlock = self.numChangedBlock{
            _numChangedBlock(self.orderNum)
        }
    }
    
    func showWith(orderNum:Int){
        self.orderNumInfo.text = "\(orderNum)"
    }
}
