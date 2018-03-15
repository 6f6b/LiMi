//
//  NearbyPeopleCollectionCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class NearbyPeopleCollectionCell: UICollectionViewCell {
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var headImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var autograph: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var sexImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containView.layer.cornerRadius = 5
        self.containView.clipsToBounds = true
    }

    func configWith(model:UserInfoModel?){
        if let _url = model?.head_pic{
            self.headImg.kf.setImage(with: URL.init(string: _url), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.userName.text = model?.true_name
        self.autograph.text = model?.content
        self.distance.text = model?.distance
        if model?.numSex == 0{
            self.sexImg.image = UIImage.init(named: "ic_girl")
        }else{
            self.sexImg.image = UIImage.init(named: "ic_boy")
        }
    }
}
