//
//  FileUploadModel.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/20.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
enum UploadWay {
    case phAssest
    case data
    case none
}

class FileUploadModel: NSObject {
    ///上传的key
    var uploadFileKey:String?
    
    ///指定上传方式
    var uploadWay:UploadWay = .none
    
    ///上传的FileModel
    var file:FileModel?
}
