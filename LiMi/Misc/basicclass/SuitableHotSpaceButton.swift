//
//  SuitableHotSpaceButton.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SuitableHotSpaceButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds = self.bounds
        //若原热区小于44则放大热区，否则保持原大小不变
        let widthDelta = MAX(parametersA: Double(44.0-bounds.size.width), parametersB: 0)
        let heightDelta = MAX(parametersA: Double(44.0-bounds.size.height), parametersB: 0)
        bounds = bounds.insetBy(dx: CGFloat(-0.5*widthDelta), dy: CGFloat(-0.5*heightDelta))
        return bounds.contains(point)
    }
}
