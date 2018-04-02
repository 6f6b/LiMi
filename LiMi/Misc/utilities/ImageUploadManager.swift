//
//  ImageUploadManager.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/30.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit


class ImageUploadManager: NSObject {
    private var tempResources = [Any]()
    private var tempImages = [UIImage]()
    private var tempFilePaths = [String]()

    //UIImage
    func uploadImageWith(image:UIImage?){}
    func uploadImageWith(images:[UIImage]?){}
    //filePath
    func uploadImageWith(filePath:String?){}
    func uploadImageWith(filePaths:[String]?){}
    //PHAsset
    func uploadImageWith(phAsset:PHAsset?){
        if phAsset == nil{return}
        self.tempResources.removeAll()
        self.tempResources.append(phAsset!)
        
        GetQiNiuUploadToken(type: .picture, onSuccess: { (tokenModel) in
            
        }, id: nil, token: nil)
    }
    
    func uploadImageWith(phAssets:[PHAsset]?){}
    //Data
    func uploadImageWith(data:Data?){}
    func uploadImageWith(datas:[Data]?){}
    
    //MARK: - misc
//    func uploadImgsWith(imgs:[UIImage?]?){
//        GetQiNiuUploadToken(type: .picture, onSuccess: { (tokenModel) in
//            if let _token = tokenModel?.token{
//                var files = [QiniuFile]()
//                if let  _imgs = imgs{
//                    for img in _imgs{
//                        let filePath = GenerateImgPathlWith(img: img)
//                        let file = QiniuFile.init(path: filePath!)
//                        file?.key = uploadFileName(type: .picture)
//                        files.append(file!)
//                    }
//                    let uploader = QiniuUploader.sharedUploader() as! QiniuUploader
//                    uploader.maxConcurrentNumber = 3
//                    uploader.files = files
//                    Toast.showStatusWith(text: "处理中")
//                    uploader.startUpload(_token, uploadOneFileSucceededHandler: { (index, dic) in
//                        let imgName = dic["key"] as? String
//                        var localMediaModel = LocalMediaModel.init()
//                        localMediaModel.imgName = imgName
//                        localMediaModel.img = imgs![index]
//                        self.imgArr.append(localMediaModel)
//                        print("successIndex\(index)")
//                        print("successDic\(dic)")
//                    }, uploadOneFileFailedHandler: { (index, error) in
//                        print("failedIndex\(index)")
//                        print("error:\(error?.localizedDescription)")
//                    }, uploadOneFileProgressHandler: { (index, bytesSent, totalBytesSent, totalBytesExpectedToSend) in
//                        print("index:\(index),percent:\(Float(totalBytesSent/totalBytesExpectedToSend))")
//                    }, uploadAllFilesComplete: {
//                        print("uploadOver")
//                        Toast.dismiss()
//                        self.imagePickerVc?.dismiss(animated: true, completion: nil)
//                        self.tableView.reloadData()
//                        self.RefreshReleasBtnEnable()
//                    })
//                }
//            }
//        }, id: nil, token: nil)
//    }
    
    //MARK: - 工具方法
    ///根据UIImage返回图片格式
    func imageTypeWith(image:UIImage?)->String?{
        if image == nil {return nil}
        if let data = UIImageJPEGRepresentation(image!, 1){
            return imageTypeWith(data: data)
        }
        if let data = UIImagePNGRepresentation(image!){
            return imageTypeWith(data: data)
        }
        return nil
    }
    ///根据PHAsset返回图片格式
    func imageTypeWith(phAsset:PHAsset?)->String?{
        if phAsset == nil{return nil}
        let resource = PHAssetResource.assetResources(for: phAsset!).first
        return resource?.originalFilename
    }
    ///根据data返回图片格式
    func imageTypeWith(data:Data?)->String?{
        if let _data = data{
            let nsData = NSData.init(data: _data)
            var c = 0x00
            nsData.getBytes(&c, length: 1)
            switch c{
            case 0xFF:
                return "jpeg"
            case 0x89:
                return "png"
            case 0x47:
                return "gif"
            case 0x49:
                return "tiff"
            case 0x4D:
                return "tiff"
            default:
                return nil
            }
        }else{
            return nil
        }
    }
}
