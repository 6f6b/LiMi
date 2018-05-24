//
//  VideoProgressView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/17.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class VideoProgressView: UIView {
    //最长时间
    private var maxTime:Double = 30
    private var timeSlots = [Double]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.purple
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func draw(_ rect: CGRect) {
//
//    }

}
