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
        
        self.trendsContainViewBottomDivider.snp.remakeConstraints {[unowned self]   (make) in
            make.top.equalTo(self.trendsContainView.snp.bottom)
            make.left.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(7)
        }
        
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
        
        self.trendsContentContainView.layer.cornerRadius = 5
        self.trendsContentContainView.clipsToBounds = true

            self.trendsTopToolsContainView.userName.textColor = UIColor.purple
            self.trendsTopToolsContainView.releaseTime.textColor = UIColor.red
            self.trendsTopToolsContainView.userInfo.textColor = UIColor.yellow
            self.contentView.backgroundColor = UIColor.orange
            self.trendsContentContainView.backgroundColor = UIColor.yellow
            self.contentText.textColor = UIColor.white
            self.trendsTopToolsContainView.backgroundColor = UIColor.green
            self.trendsContainView.backgroundColor = UIColor.blue
            self.trendsContainViewBottomDivider.backgroundColor = UIColor.brown
            self.trendsBottomToolsContainViewBottomDivider.backgroundColor = UIColor.purple
        
        self.trendsTopToolsContainView.userName.textColor = UIColor.white
        self.trendsTopToolsContainView.releaseTime.textColor = UIColor.red
        self.trendsTopToolsContainView.userInfo.textColor = RGBA(r: 114, g: 114, b: 114, a: 1)
        self.contentView.backgroundColor = APP_THEME_COLOR_1
        self.trendsContentContainView.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
        self.contentText.textColor = UIColor.white
        self.trendsTopToolsContainView.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
        self.trendsContainView.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
        self.trendsContainViewBottomDivider.backgroundColor = APP_THEME_COLOR_1
        self.trendsBottomToolsContainViewBottomDivider.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
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
            text.append(NSMutableAttributedString.init(string: "\(_content)"))
            self.contentText.text = _content
        }
    }
}
