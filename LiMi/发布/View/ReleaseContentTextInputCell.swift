//
//  ReleaseContentTextInputCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ReleaseContentTextInputCell: UITableViewCell {
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var placeHolder: UILabel!
    var textChangeBlock:((UITextView)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentText.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension ReleaseContentTextInputCell:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.placeHolder.isHidden = !IsEmpty(textView: textView)
        if let _textChangeBlock = self.textChangeBlock{
            _textChangeBlock(textView)
        }
    }
}
