//
//  TrendsWithTextAndVideoCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import AVKit

class TrendsWithTextAndVideoCell: TrendsWithTextCell {
    var videoContainView:UIView!
    var videoPreimgV:UIImageView!
    var videoPlayBtn:UIButton!
    var videoPlayBlock:(()->Void)?
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
        self.trendsContentContainView.addSubview(self.videoContainView)
        self.videoContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentText.snp.bottom)
            make.left.equalTo(self.trendsContentContainView)
            make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
        }
        
        self.videoPreimgV = UIImageView()
        self.videoContainView.addSubview(videoPreimgV)
        self.videoPreimgV.clipsToBounds = true
        self.videoPreimgV.contentMode = .scaleAspectFill
        self.videoPreimgV.snp.remakeConstraints({ (make) in
            make.top.equalTo(self.videoContainView)
            make.left.equalTo(self.videoContainView)
            make.bottom.equalTo(self.videoContainView)
            make.width.equalTo(SCREEN_WIDTH-24)
            make.height.equalTo((SCREEN_WIDTH-24)*(262/349.0))
        })
        
        self.videoPlayBtn = UIButton.init(type: .custom)
        self.videoPlayBtn.setImage(UIImage.init(named: "video_play_btn"), for: .normal)
        self.videoPlayBtn.addTarget(self, action: #selector(dealPlay), for: .touchUpInside)
        self.videoPlayBtn.contentMode = .center
        self.videoContainView.addSubview(self.videoPlayBtn)
        self.videoPlayBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.videoPreimgV)
            make.left.equalTo(self.videoPreimgV)
            make.bottom.equalTo(self.videoPreimgV)
            make.right.equalTo(self.videoPreimgV)
        }
    }
    
    //MARK: - misc
    override func configWith(model: TrendModel?) {
        super.configWith(model: model)
        self.videoPreimgV.setVideoPreImageWith(videoURL: model?.action_video)
    }
    
   @objc func dealPlay(){
    if let _videoPath = self.model?.action_video{
        if let _videoUrl = URL.init(string: _videoPath){
            let avPlayerController = AVPlayerViewController.init()
            let avPlayer = AVPlayer.init(url: _videoUrl)
            avPlayer.play()
            avPlayerController.player = avPlayer
            avPlayerController.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
//            avPlayerController.
            /*
             可以设置的值及意义如下：
             AVLayerVideoGravityResizeAspect   不进行比例缩放 以宽高中长的一边充满为基准
             AVLayerVideoGravityResizeAspectFill 不进行比例缩放 以宽高中短的一边充满为基准
             AVLayerVideoGravityResize     进行缩放充满屏幕
             */
            UIApplication.shared.keyWindow?.rootViewController?.present(avPlayerController, animated: true, completion: nil)
        }else{
            print("视频链接错误")
        }
    }else{
        print("视频链接为空")
    }
        if let _videoPlayBlock = self.videoPlayBlock{
            _videoPlayBlock()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
