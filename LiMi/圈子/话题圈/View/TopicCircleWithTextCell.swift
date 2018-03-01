//
//  TopicCircleWithTextCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import YYText

class TopicCircleWithTextCell: TrendsWithTextCell {
    var topicCircelModel:TopicCircleModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //隐藏下方工具栏
        self.trendsBottomToolsContainView.isHidden = true
        self.trendsBottomToolsContainView.snp.remakeConstraints { (make) in
            make.bottom.equalTo(self.grayBar.snp.top)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.height.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension TopicCircleWithTextCell:TopicCircleCellProtocol{
    func configWith(topicCircleModel: TopicCircleModel?) {
        self.topicCircelModel = topicCircleModel
        self.trendsTopToolsContainView.configWith(topicCircleModel: topicCircleModel)
        let text = NSMutableAttributedString()
//        if let tag = model?.skill{
//            let tagImg = UIImage.init(named: "dt_bq")!
//            let tagFrame = CGRect(x: 0, y: 0, width: tagImg.size.width, height: tagImg.size.height)
//            let tagImgView = UIImageView(image: tagImg)
//            tagImgView.sizeToFit()
//            let tagLabel = UILabel.init(frame: tagFrame)
//            tagLabel.textAlignment = .center
//            tagLabel.text = tag
//            tagLabel.font = UIFont.systemFont(ofSize: 12)
//            tagLabel.textColor = UIColor.white
//            let tagView = UIView(frame: tagFrame)
//            tagView.addSubview(tagImgView)
//            tagView.addSubview(tagLabel)
//
//            let attachment = NSMutableAttributedString.yy_attachmentString(withContent: tagView, contentMode: .left, attachmentSize: tagFrame.size, alignTo: UIFont.systemFont(ofSize: 14), alignment: YYTextVerticalAlignment.center)
//            text.append(attachment)
//        }
        if let _content = topicCircleModel?.content{
            text.append(NSMutableAttributedString.init(string: "  \(_content)"))
        }
        self.contentText.attributedText = text
    }
}
