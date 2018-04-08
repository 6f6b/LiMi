////
////  ImageUploadManager.swift
////  LiMi
////
////  Created by dev.liufeng on 2018/3/30.
////  Copyright © 2018年 dev.liufeng. All rights reserved.
////
//
//import UIKit
//import Qiniu
//import QiniuUpload
//
////struct TokenIDModel {
////    var token:String?
////    var Id:Int?
////}
//
//class ImageUploadManager: NSObject {
//    private var tempResources = [Any]()
//    private var tempImages = [UIImage]()
//    private var tempPhAssets = [PHAsset]()
//    private var qnUploadManager:QNUploadManager?
//    private var index = 0
//    
//    override init() {
//        super.init()
//        //国内https上传
//        let qnConfig = QNConfiguration.build { (builder) in
//            builder?.setZone(QNFixedZone.zone0())
//        }
//        self.qnUploadManager = QNUploadManager(configuration: qnConfig)
//    }
//    
//    func uploadImageWith(index:Int,token:String,successBlock:((UIImage,String)->Void)?,failedBlock:(()->Void)?,completionBlock:(()->Void)?){
//        if index >= self.tempImages.count{
//            if let _completionBlock = completionBlock{_completionBlock()}
//            return
//        }
//        let progressBlock:QNUpProgressHandler = { (str,flo) in
//            //print("key:\(str)-进度：\(flo)")
//        }
//        let option = QNUploadOption(mime: "", progressHandler: progressBlock, params: ["":""], checkCrc: false, cancellationSignal: { () -> Bool in
//            return false
//        })
//        let image = self.tempImages[index]
//        let phAsset = self.tempPhAssets[index]
//        let fileKey = imageNameWith(image: phAsset)
//        self.qnUploadManager?.put(phAsset, key: fileKey!, token: token, complete: { (info, str, dic) in
//            if let _successBlock = successBlock{_successBlock(image, str!)}
//            let _index = index + 1
//            self.uploadImageWith(index: _index, token: token, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock)
//        }, option: option)
//    }
//
//    func uploadImagesWith(images:[UIImage]?,phAssets:[PHAsset]?,successBlock:((UIImage,String)->Void)?,failedBlock:(()->Void)?,completionBlock:(()->Void)?,tokenIDModel:TokenIDModel? = nil){
//        guard let _images = images,let _phAssets = phAssets else {
//            if let _failedBlock = failedBlock{_failedBlock()}
//            return
//        }
//        RequestQiNiuUploadToken(type: .picture, onSuccess: { (uploadTokenModel) in
//            self.tempImages.removeAll()
//            self.tempPhAssets.removeAll()
//            let count = _images.count >= _phAssets.count ? _phAssets.count : _images.count
//            self.index = 0
//            for i in 0..<count{
//                self.tempImages.append(_images[i])
//                self.tempPhAssets.append(_phAssets[i])
//            }
//            self.uploadImageWith(index: self.index, token: (uploadTokenModel?.token)!, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock)
//        }, tokenIDModel: tokenIDModel)
//    }
//    
//    //filePath
//    func uploadImageWith(filePath:String?,tokenIDModel:TokenIDModel? = nil){}
//    func uploadImageWith(filePaths:[String]?,tokenIDModel:TokenIDModel? = nil){}
//    //PHAsset
//    func uploadImageWith(phAsset:PHAsset?,tokenIDModel:TokenIDModel? = nil){}
//    func uploadImageWith(phAssets:[PHAsset]?,tokenIDModel:TokenIDModel? = nil){}
//    //Data
//    func uploadImageWith(data:Data?,tokenIDModel:TokenIDModel? = nil){}
//    func uploadImageWith(datas:[Data]?,tokenIDModel:TokenIDModel? = nil){}
//    
//    //MARK: - 工具方法
//    ///图片名称
//    func imageNameWith(image:AnyObject?)->String?{
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyymmdd"
//        let timeStr = dateFormatter.string(from: Date())
//        // 生成 "0000-9999" 4位验证码
//        let num = arc4random() % 10000
//        let randomNumber = String.init(format: "%.4d", num)
//        let timeStampStr = Date().timeIntervalSince1970.stringValue()
//        //图片格式
//        var imageType:String? = ""
//        if let _image = image as? UIImage{
//            imageType = imageTypeWith(image: _image)
//        }
//        if let _image = image as? PHAsset{
//            imageType = imageTypeWith(phAsset: _image)
//        }
//        if let _image = image as? Data{
//            imageType = imageTypeWith(data: _image)
//        }
//        if let _type = imageType{
//            return "uploads/user/images/\(timeStr)/\(timeStampStr)_i\(randomNumber).\(_type)"
//        }
//        return nil
//    }
//    
//    ///根据UIImage返回图片格式
//    func imageTypeWith(image:UIImage?)->String?{
//        if image == nil {return nil}
//        if let data = UIImageJPEGRepresentation(image!, 1){
//            return imageTypeWith(data: data)
//        }
//        if let data = UIImagePNGRepresentation(image!){
//            return imageTypeWith(data: data)
//        }
//        return nil
//    }
//    ///根据PHAsset返回图片格式
//    func imageTypeWith(phAsset:PHAsset?)->String?{
//        if phAsset == nil{return nil}
//        let resource = PHAssetResource.assetResources(for: phAsset!).first
//        return resource?.originalFilename
//    }
//    ///根据data返回图片格式
//    func imageTypeWith(data:Data?)->String?{
//        if let _data = data{
//            let nsData = NSData.init(data: _data)
//            var c = 0x00
//            nsData.getBytes(&c, length: 1)
//            switch c{
//            case 0xFF:
//                return "jpeg"
//            case 0x89:
//                return "png"
//            case 0x47:
//                return "gif"
//            case 0x49:
//                return "tiff"
//            case 0x4D:
//                return "tiff"
//            default:
//                return nil
//            }
//        }else{
//            return nil
//        }
//    }
//}

