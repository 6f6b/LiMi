//
//  TransactionRecordCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TransactionRecordCell: UITableViewCell {
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var money: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configWith(transactionModel:TransactionModel?){
//        var des:String?
//        var money:String?
//        var time:String?
        if let _money = transactionModel?.money?.doubleValue(){
            if _money < 0{
                self.money.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
            }else{
                self.money.textColor = APP_THEME_COLOR
            }
        }
        self.desc.text = transactionModel?.des
        self.money.text = transactionModel?.money
        self.time.text = transactionModel?.time
    }
}
