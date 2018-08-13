//
//  CircleHomeBannerCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SDCycleScrollView

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
    var cycleScrollView:SDCycleScrollView!
    
    var tapMenuBlock:((CircleMenuType)->Void)?
    var tapBannerBlock:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        let cycleScrollViewWidth = SCREEN_WIDTH - 30
        let cycleScrollViewHeight = cycleScrollViewWidth*194.0/345.0
        cycleScrollView = SDCycleScrollView(frame: CGRect.init(x: 0, y: 0, width: cycleScrollViewWidth, height: cycleScrollViewHeight), delegate: self, placeholderImage: UIImage.init())
        cycleScrollView.backgroundColor = APP_THEME_COLOR_1
        cycleScrollView.localizationImageNamesGroup = ["banner1","banner2","banner3"]
        cycleScrollView.pageControlBottomOffset = -30*SCREEN_WIDTH/375.0
        cycleScrollView.pageDotImage = UIImage.init(named: "qz_ic_lunboqinor")
        cycleScrollView.currentPageDotImage = UIImage.init(named: "qz_ic_lunboqipre")
        self.bannerContainView.addSubview(self.cycleScrollView)
        
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

extension CircleHomeBannerCell:SDCycleScrollViewDelegate{
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        
    }
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didScrollTo index: Int) {

    }
}
