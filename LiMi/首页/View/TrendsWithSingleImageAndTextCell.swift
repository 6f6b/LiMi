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
        self.contentTextBottomeConstraint?.deactivate()
        
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
    

    
    override func configWith(model: TrendModel?) {
        super.configWith(model: model)
        let imageViewWidth = SCREEN_WIDTH
        var imageViewHeight = CGFloat(0)
        if let _imageWidth = model?.pic?.w,let _imageHeight = model?.pic?.h{
            if CGFloat(_imageHeight)/CGFloat(_imageWidth) > 0.75{
                imageViewHeight = imageViewWidth*4.0/3.0
            }else{
                imageViewHeight = CGFloat(_imageHeight) * SCREEN_WIDTH/CGFloat(_imageWidth)
            }
        }else{
            imageViewHeight = imageViewWidth*0.75
        }

        self.singleImageView.snp.remakeConstraints {[unowned self] (make) in
            make.top.equalTo(self.contentText.snp.bottom).offset(5)
            make.left.equalTo(self.trendsContentContainView)
            make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
            make.height.equalTo(imageViewHeight)
            make.width.equalTo(imageViewWidth)
        }
        let url = model?.action_pic?.first
        self.singleImageView.kf.setImage(with: URL.init(string: url!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
    }
    
}

