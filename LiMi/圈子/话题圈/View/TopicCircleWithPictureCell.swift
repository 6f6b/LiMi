//
//  TopicCircleWithPictureCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SnapKit

class TopicCircleWithPictureCell: TrendsWithPictureCell {
    var topicCircelModel:TopicCircleModel?
    var collectionViewMarginToTrendsContainView = CGFloat(8)
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.trendsContainViewMarginToWindow = CGFloat(5)
        self.refreshUI()
        
        self.trendsTopToolsContainView.userName.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        
        self.collectionView.isUserInteractionEnabled = false
        self.collectionView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH-CGFloat(mediaContainViewMarginToWindow*2 + self.trendsContainViewMarginToWindow*2), height: 0)
        
        self.trendsContainView.layer.cornerRadius = 5
        self.trendsContainView.clipsToBounds = true

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
        
        self.collectionView.contentInset = UIEdgeInsets.init(top: 0, left: collectionViewMarginToTrendsContainView, bottom: 0, right: collectionViewMarginToTrendsContainView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //Mark: - 重写collectionview代理方法
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let pics = self.topicCircelModel?.pics{
            return pics.count > 3 ? 3:pics.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendsImageCollectionCell", for: indexPath) as! TrendsImageCollectionCell
        if let pics = self.topicCircelModel?.pics{
            cell.configWith(picUrl: pics[indexPath.row])
            cell.imgV.layer.cornerRadius = 5
            cell.imgV.clipsToBounds = true
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let imgArr = self.model?.action_pic{
//            let photoBroswer = XLPhotoBrowser.show(withCurrentImageIndex: indexPath.row, imageCount: UInt(imgArr.count), datasource: self)
//            photoBroswer?.browserStyle = .indexLabel
//            photoBroswer?.setActionSheeWith(self)
//        }
//        if let _tapPictureBlock = self.tapPictureBlock{
//            _tapPictureBlock(indexPath.row)
//        }-
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (SCREEN_WIDTH-collectionViewMarginToTrendsContainView*2 - 5.0*2 - self.trendsContainViewMarginToWindow*2-1)/3.0
        let itemSize = CGSize(width: itemWidth, height: itemWidth)

        return itemSize
    }
    
//    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return CGFloat(multiPictureSpacing - 0.1)
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return CGFloat(multiPictureSpacing - 0.1)
//    }

}

//func configWith(model:TrendModel?,cellStyle:TrendsCellStyle = .normal){
//
//    //        var headImgBtn:UIButton!    //头像按钮
//    //        var userName:UILabel!   //用户名称
//    //        var sexImg:UIImageView! //用户性别图标
//    //        var userInfo:UILabel! //用户基本信息
//    //        var moreOperationBtn:UIButton!   //更多操作按钮
//    //        var releaseTime:UILabel!    //发布时间
//    //头像
//    if let headImgUrl = model?.head_pic{
//        self.headImgBtn.kf.setImage(with: URL.init(string: headImgUrl), for: .normal)
//    }
//    //姓名
//    self.userName.text = model?.true_name
//    //性别
//    if cellStyle == .inMyTrendList{self.sexImg.isHidden = true}
//    if model?.sex == "男"{
//        self.sexImg.image = UIImage.init(named: "boy")
//    }else{
//        self.sexImg.image = UIImage.init(named: "girl")
//    }
//    //个人资料
//    if cellStyle == .inMyTrendList{
//        self.userInfo.text = model?.create_time
//    }
//    if cellStyle == .inPersonCenter{
//        self.userInfo.text = model?.create_time
//    }
//    if cellStyle == .normal{
//        if let college = model?.college,let academy = model?.school{
//            self.userInfo.text = "\(college)|\(academy)"
//        }else{self.userInfo.text = "个人资料待认证"}
//    }
//    //发布时间
//    if cellStyle == .inMyTrendList{self.releaseTime.isHidden = true}
//    self.releaseTime.text = model?.create_time
//    //更多操作
//}

extension TopicCircleWithPictureCell:TopicCircleCellProtocol{
    func configWith(topicCircleModel: TopicCircleModel?) {
        self.topicCircelModel = topicCircleModel
        self.trendsTopToolsContainView.configWith(topicCircleModel: topicCircleModel)
        
        self.collectionView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.contentText.snp.bottom).offset(5)
            make.left.equalTo(self.trendsContentContainView)
            make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
        }
        self.collectionView.reloadData()
        self.collectionView.snp.makeConstraints { (make) in
            make.height.equalTo(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
        }
    }
}
