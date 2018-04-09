
//
//  SuspensionMenuItemWithImageCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SuspensionMenuItemWithImageCell: SuspensionMenuItemCell {
    var leftImageView:UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.leftImageView = UIImageView()
        self.leftImageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(self.leftImageView)
        self.leftImageView.snp.makeConstraints {[unowned self] (make) in
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(15)
        }
        
        self.itemTitle.snp.remakeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.contentView)
            make.top.equalTo(self.contentView).offset(15)
            make.left.equalTo(self.leftImageView.snp.right).offset(10)
            make.right.equalTo(self.contentView).offset(-15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    override func configWith(model:SuspensionMenuAction?){
        super.configWith(model: model)
        if let _image = model?.image{
            self.leftImageView.image = UIImage.init(named: _image)
        }
    }
}
