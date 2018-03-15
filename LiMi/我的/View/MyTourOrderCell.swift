//
//  MyTourOrderCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class MyTourOrderCell: UITableViewCell {
    @IBOutlet weak var backImgV: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var payStateBtn: UIButton!
    var weekendTourOrderModel:WeekendTourOrderModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.payStateBtn.layer.cornerRadius = 5
        self.payStateBtn.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configWith(model:WeekendTourOrderModel?){
        self.weekendTourOrderModel = model
        if let _backImg = model?.pic{
            self.backImgV.kf.setImage(with: URL.init(string: _backImg), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.name.text = model?.name
        if let _time = model?.time{
            self.time.text = "时间：\(_time)"
        }
        if let _num = model?.num{
            self.num.text = "数量：\(_num)"
        }
        if let _money = model?.money{
            self.totalAmount.text = "总价：\(_money)"
        }
        
        self.refreshPayStateBtnWith(orderStatus: model?.order_status)
    }
    
    func refreshPayStateBtnWith(orderStatus:Int?){
        var title = ""
        if orderStatus == 0{
            title = "未支付"
        }
        if orderStatus == 1{
            title = "已支付"
        }
        if orderStatus == 2{
            title = "交易完成"
        }
        if orderStatus == 3{
            title = "交易关闭"
        }
        if orderStatus == 4{
            title = "已经退款"
        }
        self.payStateBtn.setTitle(title, for: .normal)

    }
    
    
    @IBAction func dealTapPayBtn(_ sender: Any) {
        if self.weekendTourOrderModel?.order_status == 1 || self.weekendTourOrderModel?.order_status == 2{
            let weekendTourOrderStatusView = GET_XIB_VIEW(nibName: "WeekendTourOrderStatusView") as! WeekendTourOrderStatusView
            weekendTourOrderStatusView.frame = SCREEN_RECT
            weekendTourOrderStatusView.refreshUIWith(model: self.weekendTourOrderModel)
            UIApplication.shared.keyWindow?.addSubview(weekendTourOrderStatusView)
        }
    }
}
