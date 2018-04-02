//
//  TrendsWithSingleImageAndTextCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/28.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import Kingfisher
public let defaultCacheSerializer  = DefaultCacheSerializer.default
class TrendsWithSingleImageAndTextCell: TrendsWithTextCell {
    var singleImageView:UIImageView!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentText.snp.remakeConstraints { (make) in
            make.top.equalTo(self.trendsContentContainView)
            make.left.equalTo(self.trendsContentContainView).offset(textAreaMarginToWindow)
            //make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView).offset(-textAreaMarginToWindow)
        }
        
        self.singleImageView = UIImageView()
        self.singleImageView.contentMode = .scaleAspectFill
        self.singleImageView.clipsToBounds = true
        self.trendsContentContainView.addSubview(self.singleImageView)
        self.singleImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dealTapSingleImage))
        self.singleImageView.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    //MARK: - misc
    //MARK: - misc
    @objc func dealTapSingleImage(){
        var images = [SKPhoto]()
        let imgArr = self.model?.action_pic!
        for url in imgArr!{
            let photo = SKPhoto.photoWithImageURL(url)
            photo.shouldCachePhotoURLImage = true // you can use image cache by true(NSCache)
            images.append(photo)
        }
        let originImg = self.singleImageView.image
        SKPhotoBrowserOptions.displayCounterLabel = false                         // counter label will be hidden
        SKPhotoBrowserOptions.displayBackAndForwardButton = false                 // back / forward button will be hidden
        SKPhotoBrowserOptions.displayAction = true                               // action button will be hidden
        SKPhotoBrowserOptions.displayCloseButton = false
        SKPhotoBrowserOptions.enableSingleTapDismiss = true
        //SKPhotoBrowserOptions.bounceAnimation = true
        let broswer = SKPhotoBrowser(originImage: originImg ?? GetImgWith(size: SCREEN_RECT.size, color: .clear), photos: images, animatedFromView: self.singleImageView)
        broswer.initializePageIndex(0)
        UIApplication.shared.keyWindow?.rootViewController?.present(broswer, animated: true, completion: nil)
        
    }
    
    
    override func configWith(model: TrendModel?, tableView: UITableView?, indexPath: IndexPath?) {
        self.tableView = tableView
        self.indexPath = indexPath
        //查看本地是否缓存
        //缓存则直接配置
        //没缓存则加载，完成并刷新
        if let _url = model?.action_pic?.first{
            if let _ = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: "\(_url)"){
                print("\(_url)：已存储，稍后刷新数据")
                self.configWith(model: model)
            }else{
                print("\(_url)：没存储，稍后加载")
                self.configAndLoadWith(model: model)
            }
        }

    }
    
    func configAndLoadWith(model:TrendModel?){
        super.configWith(model: model)
        self.singleImageView.snp.remakeConstraints {[unowned self] (make) in
            make.top.equalTo(self.contentText.snp.bottom).offset(5)
            make.left.equalTo(self.trendsContentContainView)
            make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
        }
        let url = model?.action_pic?.first
        self.singleImageView.kf.setImage(with: URL.init(string: url!), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
            let imageViewWidth = SCREEN_WIDTH
            var imageViewHeight = CGFloat(0)
            if let size = image?.size{
                if size.height/size.width > 0.75{
                    imageViewHeight = imageViewWidth*4.0/3.0
                }else{
                    imageViewHeight = size.height * SCREEN_WIDTH/size.width
                }
            }
            self.singleImageView.snp.remakeConstraints({[unowned self] (make) in
                make.top.equalTo(self.contentText.snp.bottom).offset(5)
                make.left.equalTo(self.trendsContentContainView)
                make.bottom.equalTo(self.trendsContentContainView)
                make.right.equalTo(self.trendsContentContainView)
                make.height.equalTo(imageViewHeight)
                make.width.equalTo(imageViewWidth)
            })
            
            //保存到磁盘
            if let _image = image,let _url = url{
                KingfisherManager.shared.cache.store(_image, original: nil, forKey: "\(_url)", processorIdentifier: "\(_url)", cacheSerializer: defaultCacheSerializer, toDisk: true, completionHandler: {
                    if let _ = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: "\(_url)"){
                        print("\(_url)：已存储到memory")
                        if let _tableView = self.tableView,let _indexPath = self.indexPath{
//                            _tableView.reloadRows(at: [IndexPath.init(row: 0, section: 1)], with: .none)
                            DispatchQueue.main.async {
//                                _tableView.reloadData()
                                _tableView.reloadRows(at: [_indexPath], with: .none)

                            }
                            print("BLOCK执行刷新")
                        }
                    }else{
                        print("\(_url)：还未存储到memory")
                        
                    }
                    if let _ = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: "\(url!)"){
                        print("\(_url)：已存储到disk")
                        
                    }else{
                        print("\(_url)：还未存储到disk")
                        
                    }
                })
            }
        }
    }
    
    override func configWith(model: TrendModel?) {
        super.configWith(model: model)
        self.singleImageView.snp.remakeConstraints {[unowned self] (make) in
            make.top.equalTo(self.contentText.snp.bottom).offset(5)
            make.left.equalTo(self.trendsContentContainView)
            make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
        }
        let url = model?.action_pic?.first
        self.singleImageView.kf.setImage(with: URL.init(string: url!), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
            let imageViewWidth = SCREEN_WIDTH
            var imageViewHeight = CGFloat(0)
            if let size = image?.size{
                if size.height/size.width > 0.75{
                    imageViewHeight = imageViewWidth*4.0/3.0
                }else{
                    imageViewHeight = size.height * SCREEN_WIDTH/size.width
                }
            }
            self.singleImageView.snp.remakeConstraints({[unowned self] (make) in
                make.top.equalTo(self.contentText.snp.bottom).offset(5)
                make.left.equalTo(self.trendsContentContainView)
                make.bottom.equalTo(self.trendsContentContainView)
                make.right.equalTo(self.trendsContentContainView)
                make.height.equalTo(imageViewHeight)
                make.width.equalTo(imageViewWidth)
            })
        }
    }
    
}

