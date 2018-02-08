//
//  UIImageViewExtension.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/5.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import Dispatch

extension UIImageView{
    func setVideoPreImageWith(videoURL:String?){
        //根据地址判断本地是否存有图片
        if let _videoPreImg = getVideoPreImageFromLocalWith(videoURL: videoURL){
            self.image = _videoPreImg
        }else{
            requestVideoPreImageFromIntelnetWith(videoURL: videoURL, successBlock: { (image) in
                //设置图片
                self.image = image
                //缓存图片
                saveVidoPreImageToLocalWith(videoURL: videoURL, image: image)
            }, faildBlock: {
                print("获取视频出错")
            })
        }
    }
}


/// 从本地缓存获取视频预览图片
///
/// - Parameter videoURL: 视频链接
/// - Returns: 预览图
func getVideoPreImageFromLocalWith(videoURL:String?)->UIImage?{
    if let _videoURL = videoURL{
        let tempDir = NSTemporaryDirectory()
        let imageName = NSString.init(string: _videoURL).md5() + ".jpg"
        let image = UIImage.init(contentsOfFile: tempDir+imageName)
        return image
    }
    return nil
}


/// 缓存视频预览图片到本地
///
/// - Parameters:
///   - videoURL: 视频链接
///   - image: 视频预览图
func saveVidoPreImageToLocalWith(videoURL:String?,image:UIImage?){
    if let _image = image,let _videoURL = videoURL{
        let tempDir = NSTemporaryDirectory()
        let imageName = NSString.init(string: _videoURL).md5() + ".jpg"
        let imagePath = tempDir+imageName
        let fileUrl = URL.init(fileURLWithPath: imagePath)
        do{
            try UIImageJPEGRepresentation(_image, 1)?.write(to: fileUrl)
        }catch{
            return
        }
    }
}

func requestVideoPreImageFromIntelnetWith(videoURL:String?,successBlock:((UIImage)->Void)?,faildBlock:(()->Void)?){
    let myQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
    myQueue.async {
        if let _videoUrl = videoURL{
            let asset = AVURLAsset.init(url: URL.init(string: _videoUrl)!)
            let gen = AVAssetImageGenerator.init(asset: asset)
            gen.appliesPreferredTrackTransform = true
            let time = CMTimeMake(Int64(0.0), 600)
            var actualTime: CMTime = CMTimeMake(0, 0)
            do{
                let image = try gen.copyCGImage(at: time, actualTime: &actualTime)
                let thumImg = UIImage.init(cgImage: image)
                if let _successBlock = successBlock{
                    DispatchQueue.main.sync {
                        _successBlock(thumImg)
                    }
                }
                return
            }catch{
                if let _faildBlock = faildBlock{
                    DispatchQueue.main.sync {
                        _faildBlock()
                    }
                }
                return
            }
            if let _faildBlock = faildBlock{
                DispatchQueue.main.sync {
                    _faildBlock()
                }
            }
            return
        }
        if let _faildBlock = faildBlock{
            DispatchQueue.main.sync {
                _faildBlock()
            }
        }
        return
    }
}


