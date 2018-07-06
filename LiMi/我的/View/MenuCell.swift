//
//  MenuCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/28.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    var leftInfoLabel:UILabel!
    var rightArrowIcon:UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = APP_THEME_COLOR_1
        self.leftInfoLabel = UILabel()
        self.leftInfoLabel.textColor = UIColor.white
        self.leftInfoLabel.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(self.leftInfoLabel)
        self.leftInfoLabel.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(16)
        }
        
        self.rightArrowIcon = UIImageView()
        self.rightArrowIcon.image = UIImage.init(named: "menu_ic_rightbar")
        self.contentView.addSubview(self.rightArrowIcon)
        self.rightArrowIcon.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configWith(title:String){
        self.leftInfoLabel.text = title
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
