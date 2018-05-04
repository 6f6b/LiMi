//
//  UIDeviceExtension.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/3.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
extension UIDevice{
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        return false
    }
}
