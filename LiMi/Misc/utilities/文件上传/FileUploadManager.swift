//
//  FileUploadManager.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/30.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Qiniu
import QiniuUpload

//successBlock:((UIImage,String)->Void)?,failedBlock:(()->Void)?,completionBlock:(()->Void)?)

class FailedResult{
    var qnResponseInfo:QNResponseInfo?
    var message:String?
}

typealias SuccessBlock = ((Int,FileUploadModel,QNResponseInfo?)->Void)
typealias FailedBlock = ((Int,FileUploadModel,FailedResult)->Void)
/// 进度，index，模型
typealias ProgressBlock = ((Float,Int,FileUploadModel)->Void)
typealias CompletionBock = (()->Void)

struct TokenIDModel {
    var token:String?
    var Id:Int?
}


class FileUploadManager: NSObject {
    static let share = FileUploadManager()
    
    private var tempImages = [UIImage]()
    private var tempPhAssets = [PHAsset]()
    private var qnUploadManager:QNUploadManager?
    private var index = 0
    
    /*FileUploadManager2.0*/
    ///存储需要上传的FileModel
    private var fileUploadModels = [FileUploadModel]()
    ///单张图片最大内存
    private var maxUploadKB:Double = 1000.0
    
    override init() {
        super.init()
        //国内https上传
        let qnConfig = QNConfiguration.build { (builder) in
            builder?.setZone(QNFixedZone.zone0())
        }
        self.qnUploadManager = QNUploadManager(configuration: qnConfig)
    }
    
    ///上传多张图片
    func uploadMultiImageWith(images:[UIImage]?, phAssets:[PHAsset]?,progressBlock:ProgressBlock?,successBlock:SuccessBlock?,failedBlock:FailedBlock?,completionBlock:CompletionBock?,tokenIDModel:TokenIDModel? = nil)->Bool{
        guard let _images = images else {return false}
        var type:MediaType = .picture
        if let _phAsset = phAssets?.last{
            if _phAsset.mediaType == .video{type = .video}
        }
        RequestQiNiuUploadToken(type: type, onSuccess: {[unowned self] (uploadTokenModel) in
            self.fileUploadModels.removeAll()
            self.index = 0
            for i in 0..<_images.count{
                var phAsset:PHAsset?
                if let _phAssets = phAssets{
                    phAsset = _phAssets[i]
                }
                if let fileUploadModel = self.generateFileUploadModelWith(image: _images[i], phAsset: phAsset){
                    self.fileUploadModels.append(fileUploadModel)
                }
            }
            if let token = uploadTokenModel?.token{
                self.uploadFileWith(index: self.index, token: (uploadTokenModel?.token)!, progressBlock: progressBlock, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock)
            }else{
                if let _failedBlock = failedBlock{
                    let failedResult = FailedResult.init()
                    failedResult.message = "token 获取失败"
                    _failedBlock(self.index,self.fileUploadModels[self.index],failedResult)
                }
            }
        }, tokenIDModel: tokenIDModel)
        return true
    }
    ///上传单张图片
    func uploadImageWith(image:UIImage?, phAsset:PHAsset?,progressBlock:ProgressBlock?,successBlock:SuccessBlock?,failedBlock:FailedBlock?,completionBlock:CompletionBock?,tokenIDModel:TokenIDModel? = nil)->Bool{
        if let _image = image{
            var phAssets:[PHAsset]?
            if let _phAsset = phAsset{
                phAssets = [_phAsset]
            }else{
                phAssets = nil
            }
            return self.uploadMultiImageWith(images: [_image], phAssets: phAssets, progressBlock: progressBlock, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock,tokenIDModel: tokenIDModel)
        }else{
            return false
        }
    }
    ///上传多个视频
    func uploadMultiVideoWith(images:[UIImage]?, phAssets:[PHAsset]?,progressBlock:ProgressBlock?,successBlock:SuccessBlock?,failedBlock:FailedBlock?,completionBlock:CompletionBock?,tokenIDModel:TokenIDModel? = nil)->Bool{
        //return self.upl
        return self.uploadMultiImageWith(images: images, phAssets: phAssets, progressBlock: progressBlock, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock,tokenIDModel: tokenIDModel)
    }
    ///上传单个视频
    func uploadVideoWith(image:UIImage?, phAsset:PHAsset?,progressBlock:ProgressBlock?,successBlock:SuccessBlock?,failedBlock:FailedBlock?,completionBlock:CompletionBock?,tokenIDModel:TokenIDModel? = nil)->Bool{
        return self.uploadImageWith(image: image, phAsset: phAsset, progressBlock: progressBlock, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock,tokenIDModel:tokenIDModel)
    }
    
    private func uploadFileWith(index:Int,token:String,progressBlock:ProgressBlock?,successBlock:SuccessBlock?,failedBlock:FailedBlock?,completionBlock:CompletionBock?){
        //如果index >= fileUploadModels.count 返回
        if index >= self.fileUploadModels.count{
            if let _completionBlock = completionBlock{
                _completionBlock()
                return
            }
        }
        let fileUploadModel = self.fileUploadModels[index]
        let progressHandler:QNUpProgressHandler =  {[unowned self] (key,progress) in
            if let _progressBlock = progressBlock{
                DispatchQueue.main.async {
                    _progressBlock(progress, index, fileUploadModel)
                }
            }
        }
        let option = QNUploadOption(mime: "", progressHandler: progressHandler, params: ["":""], checkCrc: false) { () -> Bool in
            return false
        }
        //判断类型
        if fileUploadModel.uploadWay == .data{
            if let data = fileUploadModel.file?.data,let key = fileUploadModel.uploadFileKey{
                self.qnUploadManager?.put(data, key: key, token: token, complete: { (info, key, dic) in
                    if info?.isOK == true{
                        if let _successBlock = successBlock{
                            _successBlock(index, fileUploadModel, info)
                        }
                    }
                    if info?.isOK == false{
                        if let _failedBlock = failedBlock{
                            let failedResult = FailedResult()
                            failedResult.qnResponseInfo = info
                            _failedBlock(index, fileUploadModel, failedResult)
                        }
                    }
                    let _index =  index + 1
                    self.uploadFileWith(index: _index, token: token, progressBlock: progressBlock, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock)
                }, option: option)
            }else{
                let failedResult = FailedResult()
                failedResult.message = "上传data为空"
                if let _failedBlock = failedBlock{
                    _failedBlock(index, fileUploadModel, failedResult)
                }
                let _index =  index + 1
                self.uploadFileWith(index: _index, token: token, progressBlock: progressBlock, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock)
            }
        }
        if fileUploadModel.uploadWay == .phAssest{
            if let phAsset = fileUploadModel.file?.phAsset,let key = fileUploadModel.uploadFileKey{
                self.qnUploadManager?.put(phAsset, key: key, token: token, complete: { (info, key, dic) in
                    if info?.isOK == true{
                        if let _successBlock = successBlock{
                            _successBlock(index, fileUploadModel, info)
                        }
                    }
                    if info?.isOK == false{
                        if let _failedBlock = failedBlock{
                            let failedResult = FailedResult()
                            failedResult.qnResponseInfo = info
                            _failedBlock(index, fileUploadModel, failedResult)
                        }
                    }
                    let _index =  index + 1
                    self.uploadFileWith(index: _index, token: token, progressBlock: progressBlock, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock)
                }, option: option)
            }else{
                let failedResult = FailedResult()
                failedResult.message = "上传data为空"
                if let _failedBlock = failedBlock{
                    _failedBlock(index, fileUploadModel, failedResult)
                }
                let _index =  index + 1
                self.uploadFileWith(index: _index, token: token, progressBlock: progressBlock, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock)
            }
        }
        if fileUploadModel.uploadWay == .none{}
    }
    
    ///压缩图片并转为Data,默认压缩为JPEG格式
    func compressImgDataWith(img:UIImage?,maxKB:Double)->Data?{
        if let originalImg = img{
            //计算零压缩条件下的大小
            let tempData = UIImageJPEGRepresentation(originalImg, 1)
            //压缩率
            var compRatio = 1.0
            if maxKB*1024/Double((tempData?.count)!)<1.0{
                compRatio = maxKB*1024/Double((tempData?.count)!)
            }
            //将Image图片转为JPEG格式的二进制数据
            let data = UIImageJPEGRepresentation(originalImg, CGFloat(compRatio))
            return data
        }else{
            return nil
        }
    }
    ///生成上传key
    func generateUploadFileKeyWith(file:AnyObject?)->String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyymmdd"
        let timeStr = dateFormatter.string(from: Date())
        // 生成 "0000-9999" 4位验证码
        let num = arc4random() % 10000
        let randomNumber = String.init(format: "%.4d", num)
        let timeStampStr = Int(Date().timeIntervalSince1970).stringValue()
        var isVideo = false
        var mediaType:String? = ""
        if let _image = file as? UIImage{
            mediaType = imageTypeWith(image: _image)
        }
        if let _phassest = file as? PHAsset{
            mediaType = fileFormatWith(phAsset: _phassest)
            if _phassest.mediaType == .video{isVideo = true}
        }
        if let _data = file as? Data{
            mediaType = imageFormatWith(data: _data)
        }
        
        if let _type = mediaType{
            if isVideo{
                return "uploads/user/videos/\(timeStr)/\(timeStampStr)_i\(randomNumber).\(_type)"
            }
            if !isVideo{
                return "uploads/user/images/\(timeStr)/\(timeStampStr)_i\(randomNumber).\(_type)"
            }
        }
        return nil
    }
    ///根据UIImage、PHAsset生成FileUploadModel
    func generateFileUploadModelWith(image:UIImage?,phAsset:PHAsset?)->FileUploadModel?{
        if image == nil{return nil}
        if image != nil && phAsset != nil{
            let _image = image!
            let _phAsset = phAsset!
            if _phAsset.mediaType == .image{
                let imageFormat = self.fileFormatWith(phAsset: _phAsset)
                if imageFormat == "gif" || imageFormat == "GIF"{
                    return self.generateGIFFileUploadModelWith(image: _image, phAsset: _phAsset)
                }else{
                    return self.generateImageFileUploadModelWith(image: _image)
                }
            }
            if _phAsset.mediaType == .video{
                return self.generateVideoFileUploadModelWith(image: _image, phAsset: _phAsset)
            }
        }
        if image != nil && phAsset == nil{
            let _image = image!
            return self.generateImageFileUploadModelWith(image: _image)
        }
        return nil
    }
    //根据Image、PHAsset（视频）生成FileUploadModel
    func generateVideoFileUploadModelWith(image:UIImage,phAsset:PHAsset)->FileUploadModel{
        let fileUploadModel = FileUploadModel()
        let compressedImageData = compressImgDataWith(img: image, maxKB: self.maxUploadKB)
        fileUploadModel.uploadFileKey = generateUploadFileKeyWith(file: phAsset)
        fileUploadModel.uploadWay = .phAssest
        let videoModel = VideoModel()
        videoModel.coverImage = ImageModel()
        videoModel.phAsset = phAsset
        if let _data = compressedImageData{
            let compressedImage = UIImage.init(data: _data)
            videoModel.size = compressedImage?.size
            videoModel.coverImage?.image = compressedImage
            videoModel.coverImage?.data = _data
        }
        fileUploadModel.file = videoModel
        return fileUploadModel
    }
    //根据Image、PHAsset（GIF）生成FileUploadModel
    func generateGIFFileUploadModelWith(image:UIImage,phAsset:PHAsset)->FileUploadModel{
        let fileUploadModel = FileUploadModel()
        fileUploadModel.uploadFileKey = self.generateUploadFileKeyWith(file: phAsset)
        fileUploadModel.uploadWay = .phAssest
        let imageModel = ImageModel()
        imageModel.size = image.size
        imageModel.phAsset = phAsset
        fileUploadModel.file = imageModel
        return fileUploadModel
    }
    //根据Image生成FileUploadModel
    func generateImageFileUploadModelWith(image:UIImage)->FileUploadModel{
        let fileUploadModel = FileUploadModel()
        let compressedImageData = compressImgDataWith(img: image, maxKB: self.maxUploadKB)
        let fileKey = generateUploadFileKeyWith(file: compressedImageData as AnyObject)
        fileUploadModel.uploadFileKey = fileKey
        fileUploadModel.uploadWay = .data
        let imageModel = ImageModel()
        if let _data = compressedImageData{
            let compressedImage = UIImage.init(data: _data)
            imageModel.image = compressedImage
            imageModel.size = compressedImage?.size
            imageModel.data = _data
        }
        fileUploadModel.file = imageModel
        return fileUploadModel
    }
    ///根据Data生成FileUploadModel
    
    ///
    
    private func uploadImageWith(index:Int,token:String,successBlock:((UIImage,String)->Void)?,failedBlock:(()->Void)?,completionBlock:(()->Void)?){
        let progressBlock:QNUpProgressHandler = { (str,flo) in
            print("key:\(str)-进度：\(flo)")
        }
        let option = QNUploadOption(mime: "", progressHandler: progressBlock, params: ["":""], checkCrc: false, cancellationSignal: { () -> Bool in
            return false
        })
        let image = self.tempImages[index]
        var fileKey:String? = ""
        //根据PHAsset上传
        if index < self.tempPhAssets.count{
            let phAsset = self.tempPhAssets[index]
            fileKey = generateUploadFileKeyWith(file: phAsset)
            self.qnUploadManager?.put(phAsset, key: fileKey!, token: token, complete: { (info, str, dic) in
                if (info?.isOK)!{
                    if let _successBlock = successBlock{_successBlock(image, str!)}
                }
                if !(info?.isOK)!{
                    if let _failedBlock = failedBlock{
                        _failedBlock()
                    }
                }
                let _index = index + 1
                if _index >= self.tempImages.count{
                    if let _completionBlock = completionBlock{
                        _completionBlock()
                    }
                    return
                }
                self.uploadImageWith(index: _index, token: token, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock)
            }, option: option)
        }
        //根据UIImage上传
        else{
            fileKey = generateUploadFileKeyWith(file: image)
            self.qnUploadManager?.put(UIImagePNGRepresentation(image)!, key: fileKey, token: token, complete: { (info, str, dic) in
                if let _successBlock = successBlock{_successBlock(image, str!)}
                let _index = index + 1
                if _index >= self.tempImages.count{
                    if let _completionBlock = completionBlock{
                        _completionBlock()
                    }
                    return
                }
                self.uploadImageWith(index: _index, token: token, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock)
            }, option: option)
        }
    }
    
    ///根据UIImage上传图片，单张
    ///根据UIImage和PHAsset上传图片，单张

    ///根据UIImage上传图片，多张
    func uploadImagesWith(images:[UIImage]?,successBlock:((UIImage,String)->Void)?,failedBlock:(()->Void)?,completionBlock:(()->Void)?,tokenIDModel:TokenIDModel? = nil){
        self.uploadImagesWith(images: images, phAssets: nil, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock, tokenIDModel: tokenIDModel)
    }
    
    ///根据UIImage和PHAsset上传图片，多张
    func uploadImagesWith(images:[UIImage]?,phAssets:[PHAsset]?,successBlock:((UIImage,String)->Void)?,failedBlock:(()->Void)?,completionBlock:(()->Void)?,tokenIDModel:TokenIDModel? = nil){
        guard let _images = images else {
            if let _failedBlock = failedBlock{_failedBlock()}
            return
        }
        var type:MediaType = .picture
        if let _phAsset = phAssets?.last{
            if _phAsset.mediaType == .video{type = .video}
        }
        RequestQiNiuUploadToken(type: type, onSuccess: { (uploadTokenModel) in
            self.tempImages.removeAll()
            self.tempPhAssets.removeAll()
            let count = _images.count
            self.index = 0
            if let _phAssets = phAssets{
                for phAssest in _phAssets{
                    self.tempPhAssets.append(phAssest)
                }
            }
            for i in 0..<count{
                self.tempImages.append(_images[i])
            }
            self.uploadImageWith(index: self.index, token: (uploadTokenModel?.token)!, successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock)
        }, tokenIDModel: tokenIDModel)
    }

    //上传视频
    func uploadVideoWith(preImage:UIImage?,phAsset:PHAsset?,successBlock:((UIImage,String)->Void)?,failedBlock:(()->Void)?,completionBlock:(()->Void)?,tokenIDModel:TokenIDModel? = nil){
        guard let _image = preImage,let _phAsset = phAsset else {
            if let _failedBlock = failedBlock{_failedBlock()}
            return
        }
        self.uploadImagesWith(images: [_image], phAssets: [_phAsset], successBlock: successBlock, failedBlock: failedBlock, completionBlock: completionBlock, tokenIDModel: tokenIDModel)
    }
    
    //MARK: - 工具方法
    ///根据UIImage返回图片格式
    func imageTypeWith(image:UIImage?)->String?{
        if image == nil {return nil}
        if let data = UIImageJPEGRepresentation(image!, 1){
            return imageFormatWith(data: data)
        }
        if let data = UIImagePNGRepresentation(image!){
            return imageFormatWith(data: data)
        }
        return nil
    }
    
    ///返回多媒体文件的格式
    func fileFormatWith(phAsset:PHAsset?)->String?{
        if phAsset == nil{return nil}
        let resource = PHAssetResource.assetResources(for: phAsset!).first
        let type = resource?.originalFilename.components(separatedBy: ".").last
        return type
    }

    ///根据data返回图片格式
    func imageFormatWith(data:Data?)->String?{
        if let _data = data{
            let nsData = NSData.init(data: _data)
            var c = 0x00
            nsData.getBytes(&c, length: 1)
            switch c{
            case 0xFF:
                return "JPEG"
            case 0x89:
                return "PNG"
            case 0x47:
                return "GIF"
            case 0x49:
                return "TIFF"
            case 0x4D:
                return "TIFF"
            default:
                return nil
            }
        }else{
            return nil
        }
    }
}
