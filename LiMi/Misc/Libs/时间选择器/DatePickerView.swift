//
//  DatePickerView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class DatePickerView: UIView {
    var datePickerBlock:((Date)->Void)?
    @IBOutlet weak var datePicker: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let currentDate = Date()
        let formatter = DateFormatter.init()
        formatter.dateFormat = "YYYY/MM/DD"
        print(formatter.string(from: currentDate))
        var comps = DateComponents.init()
        comps.day = 0
        let minDate = calendar.date(byAdding: comps, to: currentDate)
        comps.year = 1
        let maxDate = calendar.date(byAdding: comps, to: currentDate)
        
        self.datePicker.minimumDate = minDate
//        self.datePicker.maximumDate = maxDate
    }
    
    @IBAction func dealCancel(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func dealOk(_ sender: Any) {
        //
        if let _datePickerBlock = self.datePickerBlock{
            _datePickerBlock(self.datePicker.date)
        }
        self.removeFromSuperview()
    }
}
