//
//  TrendsWithPictureCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TrendsWithPictureCell: TrendsWithTextAndPictrueCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: nil)
        self.contentText.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsContentContainView)
            make.left.equalTo(self.trendsContentContainView)
            //make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
            make.height.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
