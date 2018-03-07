//
//  CircleHomeBannerCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import LLCycleScrollView
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

        
        cycleScrollView = SDCycleScrollView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 182), delegate: self, placeholderImage: UIImage.init())
        cycleScrollView.imageURLStringsGroup = ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1520232614180&di=05c9b53af3f4a298853ad796abf4894c&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201603%2F01%2F20160301185403_Myn3L.jpeg"]
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
