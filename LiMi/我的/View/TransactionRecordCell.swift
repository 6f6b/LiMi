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
        self.desc.text = transactionModel?.des
        self.money.text = transactionModel?.money
        self.time.text = transactionModel?.time
    }
}
