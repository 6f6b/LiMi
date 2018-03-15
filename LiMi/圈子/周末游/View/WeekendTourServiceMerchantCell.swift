//
//  WeekendTourServiceMerchantCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SVProgressHUD

class WeekendTourServiceMerchantCell: UITableViewCell {
    @IBOutlet weak var merchantBackImg: UIImageView!
    @IBOutlet weak var merchantName: UILabel!
    @IBOutlet weak var merchantAddress: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    var weekendTourDetailModel:WeekendTourDetailModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        self.callBtn.layer.cornerRadius = 5
        self.callBtn.clipsToBounds = true
        self.callBtn.layer.borderColor = APP_THEME_COLOR.cgColor
        self.callBtn.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func dealCallMerchant(_ sender: Any) {
        if let _shopPhone = self.weekendTourDetailModel?.shop_phone{
            UIApplication.shared.openURL(URL(string: "tel:\(_shopPhone)")!)
        }else{
            Toast.showInfoWith(text:"商家未提供电话号码")
        }
    }
    
    func configWith(model:WeekendTourDetailModel?){
        self.weekendTourDetailModel = model
        if let _log = model?.logo{
            self.merchantBackImg.kf.setImage(with: URL.init(string: _log), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.merchantName.text = model?.shop_name
        self.merchantAddress.text = model?.shop_address
    }
}
