//
//  CommentTopToolsContainView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class CommentTopToolsContainView: TrendsTopToolsContainView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configWith(model: TrendModel?, cellStyle: TrendsCellStyle) {
        super.configWith(model: model, cellStyle: .inCommentList)
    }
    
    override func configWith(commentModel: CommentModel?) {
        super.configWith(commentModel: commentModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
