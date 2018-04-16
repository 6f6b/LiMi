//
//  ReleaseContentAddImgCollectionCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ReleaseContentAddImgCollectionCell: UICollectionViewCell {
    var addBlock:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func dealTapAdd(_ sender: Any) {
        if let _addBlock = self.addBlock{
            _addBlock()
        }
    }
}
