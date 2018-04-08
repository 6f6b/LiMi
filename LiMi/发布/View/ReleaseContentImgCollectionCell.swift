//
//  ReleaseContentImgCollectionCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ReleaseContentImgCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    var deleteBlock:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgV.layer.cornerRadius = 5
        self.imgV.clipsToBounds = true
    }

    func configWith(mediaModel:LocalMediaModel?){
        self.imgV.image = nil
        self.imgV.image = mediaModel?.image
    }
    
    @IBAction func dealDeleteBtn(_ sender: Any) {
        if let _deleteBlock = self.deleteBlock{
            _deleteBlock()
        }
    }
    
}
