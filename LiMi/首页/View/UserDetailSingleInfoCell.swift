//
//  UserDetailSingleInfoCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/7.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class UserDetailSingleInfoCell: UITableViewCell {
    var infoLabel:UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.infoLabel = UILabel()
        self.infoLabel.font = UIFont.systemFont(ofSize: 17)
        self.infoLabel.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
        self.contentView.addSubview(self.infoLabel)
        self.infoLabel.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self.contentView).offset(15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.red
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
