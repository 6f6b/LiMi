//
//  WeekendBannerCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SDCycleScrollView

class WeekendBannerCell: UITableViewCell {
    @IBOutlet weak var bannerContainView: UIView!
    var cycleScrollView:SDCycleScrollView!

    var dataArray = [String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        let cycleScrollViewHeight = (SCREEN_WIDTH-30)*194/345.0
        //配置icarouselView
        cycleScrollView = SDCycleScrollView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH-30, height: cycleScrollViewHeight), delegate: self, placeholderImage: UIImage())
        cycleScrollView.backgroundColor = APP_THEME_COLOR_1
        cycleScrollView.localizationImageNamesGroup = ["banner1","banner2","banner3"]
        cycleScrollView.pageControlBottomOffset = -30*SCREEN_WIDTH/375.0
        cycleScrollView.pageDotImage = UIImage.init(named: "qz_ic_lunboqinor")
        cycleScrollView.currentPageDotImage = UIImage.init(named: "qz_ic_lunboqipre")
        
        cycleScrollView.reloadInputViews()
        self.bannerContainView.addSubview(self.cycleScrollView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension WeekendBannerCell:SDCycleScrollViewDelegate{

}
