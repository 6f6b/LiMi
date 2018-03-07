//
//  WeekendTourOrderRemarksCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class WeekendTourOrderRemarksCell: UITableViewCell {
    @IBOutlet weak var remarks: UITextField!
    @IBOutlet weak var clearBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        self.clearBtn.isHidden = true
        self.remarks.addTarget(self, action: #selector(remarksChanged), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func remarksChanged(){
        self.clearBtn.isHidden = IsEmpty(textField: remarks)
    }
    
    @IBAction func dealClear(_ sender: Any) {
        self.remarks.text = nil
    }
}
