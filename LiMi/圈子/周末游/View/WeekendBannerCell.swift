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
        cycleScrollView.imageURLStringsGroup = ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1520232614180&di=05c9b53af3f4a298853ad796abf4894c&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201603%2F01%2F20160301185403_Myn3L.jpeg"]
        cycleScrollView.reloadInputViews()
        self.bannerContainView.addSubview(self.cycleScrollView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension WeekendBannerCell:SDCycleScrollViewDelegate{

}
