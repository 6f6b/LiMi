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

        //配置icarouselView
        cycleScrollView = SDCycleScrollView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH*180/375.0), delegate: self, placeholderImage: UIImage())
        cycleScrollView.localizationImageNamesGroup = ["banner1","banner2","banner3"]

        cycleScrollView.reloadInputViews()
        self.bannerContainView.addSubview(self.cycleScrollView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension WeekendBannerCell:SDCycleScrollViewDelegate{

}
