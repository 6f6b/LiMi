//
//  VideoCertificateManager.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/11.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class VideoCertificateManager: NSObject {
    static let shared = VideoCertificateManager.init()
    var isRequesting:Bool = false
    var playCertificateModel:UploadVideoCertificateModel?
    var uploadCertificateModel:UploadVideoCertificateModel?
    var completeBlock:((UploadVideoCertificateModel)->Void)?
    
    func requestPlayCertificationWith(completeBlock:@escaping ((UploadVideoCertificateModel?)->Void)){
        if isRequesting{return}
        isRequesting = true
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let shortVideoCreateUploadCertificate = ShortVideoCreateUploadCertificate.init(type: "play")
        _ = moyaProvider.rx.request(.targetWith(target: shortVideoCreateUploadCertificate)).subscribe(onSuccess: {[unowned self] (response) in
            let playVideoCertificateModel = Mapper<UploadVideoCertificateModel>().map(jsonData: response.data)
            if playVideoCertificateModel?.commonInfoModel?.status == successState{
                self.playCertificateModel = playVideoCertificateModel
                completeBlock(playVideoCertificateModel!)
            }else{
                completeBlock(nil)
                Toast.showErrorWith(model: playVideoCertificateModel)
            }
            self.isRequesting = false
        }, onError: {[unowned self] (error) in
            self.isRequesting = false
            completeBlock(nil)
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}
