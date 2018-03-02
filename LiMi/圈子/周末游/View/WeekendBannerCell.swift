//
//  WeekendBannerCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class WeekendBannerCell: UITableViewCell {
    @IBOutlet weak var iCarouselView: iCarousel!
    var dataArray = [String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //配置icarouselView
        iCarouselView.delegate = self
        iCarouselView.dataSource = self
        iCarouselView.type = .rotary
        iCarouselView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension WeekendBannerCell:iCarouselDelegate{
    func carousel(carousel: iCarousel, shouldSelectItemAtIndex index: Int) -> Bool {
        print(index)
        return true
    }
}

extension WeekendBannerCell:iCarouselDataSource{
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 5
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let imageV = UIImageView.init()
        imageV.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH*(180/375.0))
        imageV.layer.cornerRadius = 20
        imageV.clipsToBounds = true
        imageV.contentMode = .scaleToFill
        imageV.image = UIImage.init(named: "zhuye_bj")
        return imageV
    }
    
    
}
