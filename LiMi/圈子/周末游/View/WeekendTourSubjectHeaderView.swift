//
//  WeekendTourSubjectHeaderView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SDCycleScrollView

class WeekendTourSubjectHeaderView: UIView {
    var weekendTourDetailModel:WeekendTourDetailModel?
    var cycleScrollView:SDCycleScrollView!
    
    @IBOutlet weak var bannerContainView: UIView!
    @IBOutlet weak var bannerIndexContainView: UIView!
    @IBOutlet weak var infoContainView: UIView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var startAddress: UILabel!
    @IBOutlet weak var endAddress: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.infoContainView.layer.cornerRadius = 20
        self.infoContainView.clipsToBounds = true
        
        cycleScrollView = SDCycleScrollView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 220), delegate: self, placeholderImage: UIImage())
        self.bannerContainView.addSubview(cycleScrollView)
    }
    
    func configWith(model:WeekendTourDetailModel?){
        self.weekendTourDetailModel = model
        if let _pics = model?.pic{
            cycleScrollView?.imageURLStringsGroup = _pics
            if _pics.count <= 1{self.bannerIndexContainView.isHidden = true}else{
                self.bannerIndexContainView.isHidden = false
                self.indexLabel.text = "\(1)/\(_pics.count)"
            }
        }
        var nameText = ""
        if let _name = model?.name{
            nameText = _name
        }
        if let _feature = model?.feature{
            nameText = nameText + "|\(_feature)"
        }
        self.name.text = nameText
        if let _price = model?.price{
            self.price.text = "¥\(_price.decimalValue())"
        }
        //self.price.text = model?.price?.decimalValue()
        self.time.text = model?.time
        if let _from = model?.from{
            self.startAddress.text = "起始地：\(_from)"
        }
        if let _to = model?.to{
            self.endAddress.text = "目的地：\(_to)"
        }
    }
}

extension WeekendTourSubjectHeaderView:SDCycleScrollViewDelegate{
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        
    }
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didScrollTo index: Int) {
        if let _pics = self.weekendTourDetailModel?.pic{
            self.indexLabel.text = "\(index+1)/\(_pics.count)"
        }
    }
}
