//
//  TrendsWithTextAndVideoCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TrendsWithTextAndVideoCell: TrendsWithTextCell {
    var videoContainView:UIView!
    var videoPreimgV:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentText.snp.remakeConstraints { (make) in
            make.top.equalTo(self.trendsContentContainView)
            make.left.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
        }
        
        self.videoContainView = UIView()
        self.videoContainView.backgroundColor = UIColor.green
        self.trendsContentContainView.addSubview(self.videoContainView)
        self.videoContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsContentContainView)
            make.left.equalTo(self.trendsContentContainView)
            make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
        }
        
        self.videoPreimgV = UIImageView()
        self.videoContainView.addSubview(videoPreimgV)
        self.videoContainView.contentMode = .scaleAspectFill
        self.videoPreimgV.snp.remakeConstraints({ (make) in
            make.top.equalTo(self.videoContainView)
            make.left.equalTo(self.videoContainView)
            make.bottom.equalTo(self.videoContainView)
            make.width.equalTo(SCREEN_WIDTH-24)
            make.height.equalTo((SCREEN_WIDTH-24)*(262/349.0))
        })
    }
    
    //MARK: - misc
    override func configWith(model: TrendModel?) {
        super.configWith(model: model)
//        if let image = getThumnailImageWith(videoUrl: model?.action_video){
//            let imageSize = image.size
//            self.videoPreimgV.image = image
//            self.videoPreimgV.snp.remakeConstraints({ (make) in
//                make.top.equalTo(self.videoContainView)
//                make.left.equalTo(self.videoContainView)
//                make.bottom.equalTo(self.videoContainView)
//                let width = imageSize.width < SCREEN_WIDTH*0.3 ? imageSize.width : SCREEN_WIDTH*0.3
//                let height = width*(imageSize.height/imageSize.width) < SCREEN_HEIGHT*0.3 ? width*(imageSize.height/imageSize.width) : SCREEN_HEIGHT*0.3
//                make.width.equalTo(SCREEN_WIDTH*0.3)
//                make.height.equalTo(SCREEN_HEIGHT*0.3)
//            })
//        }
        self.videoPreimgV.kf.setImage(with: URL.init(string: (model?.action_video!)!))
//        self.videoPreimgV.image = getThumnailImageWith(videoUrl: model?.action_video)
//        self.videoPreimgV.snp.remakeConstraints { (make) in
//            
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
