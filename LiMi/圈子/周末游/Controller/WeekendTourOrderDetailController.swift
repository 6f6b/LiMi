//
//  WeekendTourOrderDetailController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/2.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import SVProgressHUD

class WeekendTourOrderDetailController: ViewController {
    var weekendTourId:Int?
    //简介
    var weekendTourASimpleInfoInOrderCell:WeekendTourASimpleInfoInOrderCell!
    //数量
    var weekendTourOrderNumCell:WeekendTourOrderNumCell!
    //单价
    var weekendTourUnitPriceCell:WeekendTourUnitPriceCell!
    //联系方式
    var weekendTourOrderContactWayCell:WeekendTourOrderContactWayCell!
    //预定时间
    var weekendTourOrderReserveTimeCell:WeekendTourOrderReserveTimeCell!
    //备注
    var weekendTourOrderRemarksCell:WeekendTourOrderRemarksCell!
    //支付方式
    var weekendTourOrderPayWayCell:WeekendTourOrderPayWayCell!
    var weekendTourModel:WeekendTourModel?
    
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "提交订单"
        
        self.weekendTourASimpleInfoInOrderCell = GET_XIB_VIEW(nibName: "WeekendTourASimpleInfoInOrderCell") as! WeekendTourASimpleInfoInOrderCell
        self.weekendTourOrderNumCell = GET_XIB_VIEW(nibName: "WeekendTourOrderNumCell") as! WeekendTourOrderNumCell
        self.weekendTourOrderNumCell.numChangedBlock = {[unowned self] num in
            self.refreshWith(model: self.weekendTourModel)
        }
        self.weekendTourUnitPriceCell = GET_XIB_VIEW(nibName: "WeekendTourUnitPriceCell") as! WeekendTourUnitPriceCell
        self.weekendTourOrderContactWayCell = GET_XIB_VIEW(nibName: "WeekendTourOrderContactWayCell") as! WeekendTourOrderContactWayCell
        self.weekendTourOrderReserveTimeCell = GET_XIB_VIEW(nibName: "WeekendTourOrderReserveTimeCell") as! WeekendTourOrderReserveTimeCell
        self.weekendTourOrderRemarksCell = GET_XIB_VIEW(nibName: "WeekendTourOrderRemarksCell") as! WeekendTourOrderRemarksCell
        self.weekendTourOrderPayWayCell = GET_XIB_VIEW(nibName: "WeekendTourOrderPayWayCell") as! WeekendTourOrderPayWayCell

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(handleAlipayResultWith(notification:)), name: FINISHED_ALIPAY_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWXPayResultWith(notificaton:)), name: FINISHED_WXPAY_NOTIFICATION, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: FINISHED_ALIPAY_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name: FINISHED_WXPAY_NOTIFICATION, object: nil)
        print("周末游订单界面销毁")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //Mark: - misc
    @IBAction func dealToPay(_ sender: Any) {
        //OrderAction
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        if IsEmpty(textField: self.weekendTourOrderContactWayCell.phoneNum){
            Toast.showInfoWith(text:"请输入电话号码")
            return
        }
        if self.weekendTourOrderReserveTimeCell.timeLabel.text == nil{
            Toast.showInfoWith(text:"请选择预定时间")
            return
        }
        var payWay = 1
        if self.weekendTourOrderPayWayCell.payWay == .alipay{
            payWay = 1
        }else{
            payWay = 2
        }
        let orderAction = OrderAction(goods_id: self.weekendTourId, goods_num: self.weekendTourOrderNumCell.orderNum, text: self.weekendTourOrderRemarksCell.remarks.text, time: self.weekendTourOrderReserveTimeCell.timeText, mobile: self.weekendTourOrderContactWayCell.phoneNum.text, pay_type: payWay)
        _ = moyaProvider.rx.request(.targetWith(target: orderAction)).subscribe(onSuccess: { (response) in
            let signedResultModel = Mapper<SignedResultModel>().map(jsonData: response.data)
            PayManager.shared.rechageWith(signedResultModel: signedResultModel, payWay: self.weekendTourOrderPayWayCell.payWay)
            Toast.showErrorWith(model: signedResultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
        
    }
    
    @objc func handleAlipayResultWith(notification: Notification){
        let alipayResultContainModel = Mapper<AlipayResultContainModel>().map(JSONObject: notification.userInfo)
        if alipayResultContainModel?.resultStatus == "9000"{
            self.callServerPayStateWith(tradeNumber: alipayResultContainModel?.result?.alipay_trade_app_pay_response?.out_trade_no, type: "1")
        }else{
            self.showAliPayErrorWith(code: alipayResultContainModel?.resultStatus)
        }
    }
    
    @objc func handleWXPayResultWith(notificaton:Notification){
        let resp = notificaton.userInfo![WXPAY_RESULT_KEY] as! BaseResp
        if resp.errCode == WXSuccess.rawValue{
            self.callServerPayStateWith(tradeNumber: PayManager.shared.signedResultModel?.out_trade_no, type: "2")
        }else{
            Toast.showErrorWith(msg: resp.errStr)
        }
    }
    
    /// 向服务器查询支付结果信息
    ///
    /// - Parameters:
    ///   - tradeNumber: 交易流水号
    ///   - type: 支付类型
    func callServerPayStateWith(tradeNumber:String?,type:String?){
        let getOnlinePayStaus = GetOnlinePayStaus(order_no: tradeNumber)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: getOnlinePayStaus)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            //Toast.showResultWith(model: resultModel)
            let payResultController = PayResultController()
            payResultController.baseModel = resultModel
            self.navigationController?.pushViewController(payResultController, animated: true)
//            if resultModel?.commonInfoModel?.status == successState{
//                let delayTime : TimeInterval = 1.0
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: {
//                    self.dismiss(animated: true, completion: {
//                        Toast.dismiss()
//                        self.navigationController?.popViewController(animated: true)
//                    })
//                })
//            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func showAliPayErrorWith(code:String?){
        //        9000    订单支付成功
        //        8000    正在处理中
        //        4000    订单支付失败
        //        6001    用户中途取消
        //        6002    网络连接出错
        //        99    用户点击忘记密码导致快捷界面退出(only iOS)
        if code == "8000"{Toast.showStatusWith(text: "正在处理中")}
        if code == "4000"{Toast.showErrorWith(msg: "订单支付失败")}
        if code == "6001"{Toast.showErrorWith(msg: "取消支付")}
        if code == "6002"{Toast.showErrorWith(msg: "网络连接错误")}
        if code == "99"{Toast.showErrorWith(msg: "支付失败")}
        
    }
    
    func refreshWith(model:WeekendTourModel?){
        if let _price = model?.price{
            let totalPrice = _price*Double(self.weekendTourOrderNumCell.orderNum)
            self.totalAmount.text = "¥\(totalPrice)"
        }
    }
    
    func loadData(){
//        WeekendOrder
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let weekendOrder = WeekendOrder(weekend_id: self.weekendTourId)
        _ = moyaProvider.rx.request(.targetWith(target: weekendOrder)).subscribe(onSuccess: { (response) in
            let weekendTourModel = Mapper<WeekendTourModel>().map(jsonData: response.data)
            self.weekendTourModel = weekendTourModel
            self.refreshWith(model: weekendTourModel)
            self.tableView.reloadData()
            Toast.showErrorWith(model: weekendTourModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

extension WeekendTourOrderDetailController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.weekendTourModel == nil{return 0}
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        if section == 1{
            return 2
        }
        if section == 2{
            return 3
        }
        if section == 3{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{return UITableViewAutomaticDimension}
        if indexPath.section == 1{return 45}
        if indexPath.section == 2{return 45}
        if indexPath.section == 3{return UITableViewAutomaticDimension}
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{return 0.001}
        return 7
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            self.weekendTourASimpleInfoInOrderCell.configWith(model: self.weekendTourModel)
            return self.weekendTourASimpleInfoInOrderCell
        }
        if indexPath.section == 1{
            if indexPath.row == 0{
                return self.weekendTourOrderNumCell
            }
            if indexPath.row == 1{
                self.weekendTourUnitPriceCell.configWith(model: self.weekendTourModel)
                return self.weekendTourUnitPriceCell
            }
        }
        if indexPath.section == 2{
            if indexPath.row == 0{
                return self.weekendTourOrderContactWayCell
            }
            if indexPath.row == 1{
                return self.weekendTourOrderReserveTimeCell
            }
            if indexPath.row == 2{
                return self.weekendTourOrderRemarksCell
            }
        }
        if indexPath.section == 3{
            return self.weekendTourOrderPayWayCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2{
            if indexPath.row == 1{
                let datePickerView = GET_XIB_VIEW(nibName: "DatePickerView") as! DatePickerView
                datePickerView.frame = SCREEN_RECT
                datePickerView.datePicker.minimumDate = Date()
                datePickerView.datePickerBlock = {[unowned self] (date) in
                    let dateForMatter = DateFormatter()
                    dateForMatter.dateFormat = "yyyy-MM-dd"
                    self.weekendTourOrderReserveTimeCell.timeLabel.text = dateForMatter.string(from: date)
                    self.weekendTourOrderReserveTimeCell.timeText = "\(dateForMatter.string(from: date)) 00:00:00"
                }
                UIApplication.shared.keyWindow?.addSubview(datePickerView)
            }
        }
    }
}
