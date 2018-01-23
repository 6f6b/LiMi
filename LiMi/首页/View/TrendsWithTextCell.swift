//
//  TrendsWithTextCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import YYText

class TrendsWithTextCell: TrendsCell {
    var contentText:YYLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentText = YYLabel()
        self.trendsContentContainView.addSubview(self.contentText)
        self.contentText.font = UIFont.systemFont(ofSize: 14)
        self.contentText.textColor = RGBA(r: 51, g: 51, b: 51, a: 1)
        self.contentText.numberOfLines = 0
        self.contentText.lineBreakMode = .byWordWrapping
        self.contentText.preferredMaxLayoutWidth = SCREEN_WIDTH-24
        self.contentText.textVerticalAlignment = YYTextVerticalAlignment.top
    
        let tagImg = UIImage.init(named: "dt_bq")!
        let tagFrame = CGRect(x: 0, y: 0, width: tagImg.size.width, height: tagImg.size.height)
        let tagImgView = UIImageView(image: tagImg)
        tagImgView.sizeToFit()
        let tagLabel = UILabel.init(frame: tagFrame)
        tagLabel.textAlignment = .center
        tagLabel.text = "标签啊"
        let tagView = UIView(frame: tagFrame)
        tagView.addSubview(tagImgView)
        tagView.addSubview(tagLabel)
        
        let text = NSMutableAttributedString()
        let attachment = NSMutableAttributedString.yy_attachmentString(withContent: tagView, contentMode: .left, attachmentSize: tagFrame.size, alignTo: UIFont.systemFont(ofSize: 14), alignment: YYTextVerticalAlignment.center)
        text.append(attachment)
        text.append(NSAttributedString.init(string: "hellllhellllhellllhellllhellllhellllhellllhellllhellllhellllhellllhellllhellllhellllvhellllhellllhellllhellllhellllhellllhellllhellllhellllhellllhellllhellllhellllhellllv"))
        self.contentText.attributedText = text
        self.contentText.snp.makeConstraints { (make) in
            make.top.equalTo(self.trendsContentContainView)
            make.left.equalTo(self.trendsContentContainView)
            make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
