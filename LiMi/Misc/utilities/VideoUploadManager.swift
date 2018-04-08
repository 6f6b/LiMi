////
////  VideoUploadManager.swift
////  LiMi
////
////  Created by dev.liufeng on 2018/3/30.
////  Copyright © 2018年 dev.liufeng. All rights reserved.
////
//
//import UIKit
//
//class VideoUploadManager: NSObject {
//    //UIImage
//    func uploadImageWith(image:UIImage?){}
//    func uploadImageWith(images:[UIImage]?){}
//    //filePath
//    func uploadImageWith(filePath:String?){}
//    func uploadImageWith(filePaths:[String]?){}
//    //PHAsset
//    func uploadImageWith(phAsset:PHAsset?){}
//    func uploadImageWith(phAssets:[PHAsset]?){}
//    //Data
//    func uploadImageWith(data:Data?){}
//    func uploadImageWith(datas:[Data]?){}
//    
//    //工具方法
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
//    func imageTypeWith(phAsset:PHAsset?)->String?{return ""}
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

