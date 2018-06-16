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
    
    var playCertificateModel:UploadVideoCertificateModel?
    var uploadCertificateModel:UploadVideoCertificateModel?
    
    func requestPlayCertificationWith(completeBlock:((UploadVideoCertificateModel)->Void)?){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let shortVideoCreateUploadCertificate = ShortVideoCreateUploadCertificate.init(type: "play")
        _ = moyaProvider.rx.request(.targetWith(target: shortVideoCreateUploadCertificate)).subscribe(onSuccess: { (response) in
            let playVideoCertificateModel = Mapper<UploadVideoCertificateModel>().map(jsonData: response.data)
            if playVideoCertificateModel?.commonInfoModel?.status == successState{
                self.playCertificateModel = playVideoCertificateModel
                if let _block = completeBlock{
                    _block(playVideoCertificateModel!)
                }
            }else{
                Toast.showErrorWith(model: playVideoCertificateModel)
            }
            
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}
