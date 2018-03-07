//
//  ToastView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/7.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ToastView: UIView {
    static var shared:ToastView = ToastView()
    var timer:Timer?
    var currentText:String?
    var maxShowTime:Double = 2.0
    var minShowTime:Double = 1.0

    var toastContentContainView:UIView!
    var indicateImg:UIImageView!
    var contentLabel:UILabel!
    
    convenience init() {
        self.init(frame: SCREEN_RECT)
        
        self.backgroundColor = RGBA(r: 200, g: 200, b: 200, a: 0.1)
        
        self.toastContentContainView = UIView()
        self.toastContentContainView.backgroundColor = UIColor.white
        self.toastContentContainView.layer.cornerRadius = 5
        self.toastContentContainView.clipsToBounds = true
        self.addSubview(self.toastContentContainView)
        self.toastContentContainView.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.width.equalTo(200)
            make.center.equalTo(self)
        }
        
        self.indicateImg = UIImageView()
        self.toastContentContainView.addSubview(self.indicateImg)
        self.indicateImg.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.toastContentContainView)
            make.top.equalTo(self.toastContentContainView).offset(20)
        }
        
        self.contentLabel = UILabel()
        self.contentLabel.font = UIFont.systemFont(ofSize: 17)
        self.contentLabel.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
        self.toastContentContainView.addSubview(self.contentLabel)
        self.contentLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.toastContentContainView)
            make.left.equalTo(self.toastContentContainView).offset(15)
            make.bottom.equalTo(self.toastContentContainView).offset(-20)
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - misc
    
    ///显示错误信息
    func showErrorWith(text:String?){
        print("ERROR:\(text!)")
        self.resestToastViewWith(text: text)
        self.indicateImg.image = UIImage.init(named: "toast_no")
        self.contentLabel.text = text
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    ///显示成功信息
    func showSuccessWith(text:String?){
        self.resestToastViewWith(text: text)
        self.indicateImg.image = UIImage.init(named: "toast_yes")
        self.contentLabel.text = text
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    ///隐藏
    @objc func dissmiss(){
        self.timer?.invalidate()
        self.timer = nil
        self.removeFromSuperview()
        print("DISMISSSSSSSSSSSSSSSSSs")
    }
    
    ///充值计时器，且将之前显示的删除掉
    func resestToastViewWith(text:String?){
        self.dissmiss()
        let showTime = self.suitableShowTimeWith(text: text)
        self.timer = Timer.scheduledTimer(timeInterval: showTime, target: self, selector: #selector(dissmiss), userInfo: nil, repeats: false)
    }
    
    ///根据字符串长度评估显示时间
    func estimateShowTimeWith(text:String?)->Double{
        if let _text = text{
            return Double(_text.lengthOfBytes(using: String.Encoding.utf8))/4.0
        }
        return 1.0
    }
    
    ///根据评估时间以及设定时间，返回合理显示时间
    func suitableShowTimeWith(text:String?)->Double{
        let esimateShowTime = self.estimateShowTimeWith(text: text)
        let minimalTime = esimateShowTime >= self.maxShowTime ? self.maxShowTime : esimateShowTime
        let suitableShowTime = minimalTime <= self.minShowTime ? self.minShowTime : minimalTime
        return suitableShowTime
    }
}
