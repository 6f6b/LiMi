//
//  CircleHomeBannerCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import LLCycleScrollView

enum CircleMenuType {
    ///附近的人
    case peopleNearby
    ///周末游
    case weekendTour
    //话题圈
    case topicCircle
}
class CircleHomeBannerCell: UITableViewCell {
    @IBOutlet weak var bannerContainView: UIView!
    
    
    var tapMenuBlock:((CircleMenuType)->Void)?
    var tapBannerBlock:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        let bannerView = LLCycleScrollView.llCycleScrollViewWithFrame(CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 182))
        // 是否自动滚动
        bannerView.autoScroll = true
        // 是否无限循环，此属性修改了就不存在轮播的意义了 😄
        bannerView.infiniteLoop = true
        // 滚动间隔时间(默认为2秒)
        bannerView.autoScrollTimeInterval = 3.0
        // 等待数据状态显示的占位图
        bannerView.placeHolderImage = nil
        // 如果没有数据的时候，使用的封面图
        bannerView.coverImage = nil
        // 设置图片显示方式=UIImageView的ContentMode
        bannerView.imageViewContentMode = .scaleToFill
        // 设置滚动方向（ vertical || horizontal ）
        bannerView.scrollDirection = .vertical
        // 设置当前PageControl的样式 (.none, .system, .fill, .pill, .snake)
        bannerView.customPageControlStyle = .snake
        // 非.system的状态下，设置PageControl的tintColor
        bannerView.customPageControlInActiveTintColor = UIColor.red
        // 设置.system系统的UIPageControl当前显示的颜色
        bannerView.pageControlCurrentPageColor = UIColor.white
        // 非.system的状态下，设置PageControl的间距(默认为8.0)
        bannerView.customPageControlIndicatorPadding = 8.0
        // 设置PageControl的位置 (.left, .right 默认为.center)
        bannerView.pageControlPosition = .center
        // 背景色
//        bannerView.collectionViewBackgroundColor =
        bannerView.imagePaths = ["zhuye_bj"];
        // 添加到view
        self.bannerContainView.addSubview(bannerView)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //Mark: - misc
    @IBAction func dealTapMenuItemWith(_ sender: Any) {
        let btn = sender as! UIButton
        if let _tapMenuBlock = self.tapMenuBlock{
            if btn.tag == 0{
                _tapMenuBlock(.peopleNearby)
            }
            if btn.tag == 1{
                _tapMenuBlock(.weekendTour)
            }
            if btn.tag == 2{
                _tapMenuBlock(.topicCircle)
            }
        }
    }
}
