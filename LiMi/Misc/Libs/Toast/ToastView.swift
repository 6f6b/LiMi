//
//  ToastView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/7.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

enum ToastType {
    case loading
    case successInfo
    case faildInfo
    case info
}

class ToastView: UIView {
    static var shared:ToastView = ToastView()
    var timer:Timer?
    var currentText:String?
    var maxShowTime:Double = 1.0
    var minShowTime:Double = 0.5

    var toastContentView:ToastContentView?
    
    convenience init() {
        self.init(frame: SCREEN_RECT)
        
        self.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - misc
    ///单纯显示文本信息
    func showInfoWith(text:String?){
        self.resestToastViewWith(text: text)
        self.installContentViewWith(type: .info, text: text)
        UIApplication.shared.keyWindow?.addSubview(self)
        //单纯文本居中
    }
    
    ///耗时操作下的显示
    func showStatusWith(text:String?){
        self.resestToastViewWith(text: text)
        self.installContentViewWith(type: .loading, text: text)
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    ///显示错误信息
    func showErrorWith(text:String?){
        self.resestToastViewWith(text: text)
        self.installContentViewWith(type: .faildInfo, text: text)
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    ///显示成功信息
    func showSuccessWith(text:String?){
        self.resestToastViewWith(text: text)
        self.installContentViewWith(type: .successInfo, text: text)
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    ///隐藏
    @objc func dissmiss(){
        self.timer?.invalidate()
        self.timer = nil
        self.toastContentView?.removeFromSuperview()
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
    
    ///根据toast类型以及内容，获取对应的展现视图
    func installContentViewWith(type:ToastType,text:String?){
        var toastContentView:ToastContentView!
        
        if type == .info{
            toastContentView = ToastContentViewWithText()
        }else{
            if text == nil{
                toastContentView = ToastContentViewWithPicture()
            }
            if text != nil{
                toastContentView = ToastContentViewWithPictureAndText()
            }
        }
        toastContentView.showWith(type: type, text: text)
        self.toastContentView = toastContentView
        self.addSubview(toastContentView)
        toastContentView.snp.makeConstraints {[unowned self]    (make) in
            make.center.equalTo(self)
        }
    }
}

class ToastContentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.7)
        
        self.snp.makeConstraints { (make) in
            make.height.equalTo(110)
            make.width.greaterThanOrEqualTo(110)
            make.width.lessThanOrEqualTo(280)
        }
        
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showWith(type:ToastType,text:String?){
        
    }
}

class ToastContentViewWithText: ToastContentView {
    var contentLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentLabel = UILabel()
        self.contentLabel.textAlignment = .center
        self.contentLabel.font = UIFont.systemFont(ofSize: 15)
        self.contentLabel.textColor = UIColor.white
        self.addSubview(self.contentLabel)
        self.contentLabel.snp.makeConstraints { [unowned self]   (make) in
            make.center.equalTo(self)
            make.left.equalTo(self).offset(12)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func showWith(type: ToastType, text: String?) {
        super.showWith(type: type, text: text)
        self.contentLabel.text = text
    }
}

class ToastContentViewWithPictureAndText: ToastContentViewWithText {
    var indicateImg:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.indicateImg = UIImageView()
        var animationImages = [UIImage]()
        for i in 1...8{
            animationImages.append(UIImage.init(named: "loading\(i)")!)
        }
        self.indicateImg.animationImages = animationImages
        self.addSubview(self.indicateImg)
        self.indicateImg.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(20)
        }

        self.contentLabel.snp.remakeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self.indicateImg.snp.bottom).offset(10)
            make.left.equalTo(self).offset(12)
            //make.bottom.equalTo(self).offset(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func showWith(type: ToastType, text: String?) {
        super.showWith(type: type, text: text)
        if type == .loading{
            self.indicateImg.startAnimating()
        }
        if type == .faildInfo{
            self.indicateImg.image = UIImage.init(named: "toast_no")
        }
        if type == .successInfo{
            self.indicateImg.image = UIImage.init(named: "toast_yes")
        }
        if type == .info{}
    }
}


class ToastContentViewWithPicture:  ToastContentViewWithPictureAndText{
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentLabel.isHidden = true
        
        self.indicateImg.snp.remakeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}











