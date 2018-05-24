//
//  ShotCountDownView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/17.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class ShotCountDownView: UIView {
    var timeLabel:UILabel!
    var timer:Timer!
    var time:Int = 0
    var completeBlock:(()->Void)?
    convenience init() {
        self.init(frame: SCREEN_RECT)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.timeLabel = UILabel.init()
        self.timeLabel.font = UIFont.systemFont(ofSize: 150, weight: .bold)
        self.timeLabel.textColor = UIColor.white
        self.addSubview(self.timeLabel)
        self.timeLabel.snp.makeConstraints {[unowned self] (make) in
            make.center.equalTo(self)
        }
        self.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showWith(time:Int){
        self.time = time
        UIApplication.shared.keyWindow?.addSubview(self)
        self.timeLabel.text = "\(self.time)"
        if #available(iOS 10.0, *) {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[unowned self] (_) in
                self.time -= 1
                if self.time <= 0{
                    self.timer.invalidate()
                    self.removeFromSuperview()
                }else{
                    self.timeLabel.text = "\(self.time)"
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }
}
