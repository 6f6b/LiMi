//
//  FileModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/20.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class FileModel: NSObject {
    ///文件尺寸
    var size:CGSize?
    ///文件占据内存大小
    var memorySize:Int?
    ///data数据
    var data:Data?
    ///PHAsset数据
    var phAsset:PHAsset?
}
