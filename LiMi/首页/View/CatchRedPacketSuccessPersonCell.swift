//
//  CatchRedPacketSuccessPersonCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class CatchRedPacketSuccessPersonCell: UITableViewCell {
    @IBOutlet weak var headImgV: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headImgV.layer.cornerRadius = 15
        self.headImgV.clipsToBounds = true
        
        self.amount.text = nil
        self.userName.text = nil
    }

    func configWith(model:PersonCatchedRedPacketModel?){
        if let headPic = model?.head_pic{
            self.headImgV.kf.setImage(with: URL.init(string: headPic), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.userName.text = model?.nickname
        if let _money = model?.money?.decimalValue(){
            self.amount.text = _money + "元"
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
