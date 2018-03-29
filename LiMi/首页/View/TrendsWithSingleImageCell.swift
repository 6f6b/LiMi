//
//  TrendsWithSingleImageCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/28.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class TrendsWithSingleImageCell: TrendsWithSingleImageAndTextCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentText.snp.remakeConstraints { (make) in
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
 
}
