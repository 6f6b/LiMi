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
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.collectionView.isUserInteractionEnabled = false
        
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
//        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (SCREEN_WIDTH-12*2 - 5*2)/3
        var itemSize = CGSize(width: itemWidth, height: itemWidth)
//        if let pics = self.model?.action_pic{
//            if pics.count == 1{
//                itemSize.width = SCREEN_WIDTH-12*2
//                itemSize.height = itemSize.width*(262/349.0)
//            }
//            if pics.count == 2 || pics.count == 4{
//                itemSize.width = (SCREEN_WIDTH-12*2 - 5)/2
//                itemSize.height = itemSize.width
//            }
//        }
        return itemSize
    }
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
