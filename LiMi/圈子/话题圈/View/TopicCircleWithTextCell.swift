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
        
        self.trendsContainViewMarginToWindow = CGFloat(5)
        self.trendsContentContainViewMarginToTrendsContainView = 15
        self.refreshUI()
        
        self.trendsTopToolsContainView.userName.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        
        self.trendsContainView.layer.cornerRadius = 5
        self.trendsContainView.layer.masksToBounds = true
        
        //隐藏下方工具栏
        self.trendsBottomToolsContainView.isHidden = true
        self.trendsBottomToolsContainView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.trendsBottomToolsContainViewTopDivider.snp.bottom)
            make.left.equalTo(self.trendsContainView).offset(self.bottomToolsContainViewMarginToTrendsContainView)
            make.right.equalTo(self.trendsContainView).offset(-self.bottomToolsContainViewMarginToTrendsContainView)
            make.height.equalTo(0)
        }
        
        self.trendsContainViewBottomDivider.backgroundColor = UIColor.groupTableViewBackground
        self.trendsContainViewBottomDivider.snp.remakeConstraints {[unowned self]   (make) in
            make.top.equalTo(self.trendsContainView.snp.bottom)
            make.left.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(7)
        }
        
        self.trendsBottomToolsContainViewBottomDivider.backgroundColor = UIColor.white
        self.trendsBottomToolsContainViewBottomDivider.snp.remakeConstraints { (make) in
            make.top.equalTo(self.trendsBottomToolsContainView.snp.bottom)
            make.left.equalTo(self.trendsContainView)
            make.right.equalTo(self.trendsContainView)
            make.bottom.equalTo(self.trendsContainView)
            make.height.equalTo(10)
        }
        
        self.contentText.snp.remakeConstraints { (make) in
            make.top.equalTo(self.trendsContentContainView).offset(15)
            make.left.equalTo(self.trendsContentContainView).offset(15)
            make.bottom.equalTo(self.trendsContentContainView).offset(-15)
            make.right.equalTo(self.trendsContentContainView).offset(-12)
        }
        self.contentText.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        
        self.trendsContentContainView.backgroundColor = RGBA(r: 250, g: 250, b: 250, a: 1)
        self.trendsContentContainView.layer.cornerRadius = 5
        self.trendsContentContainView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

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
