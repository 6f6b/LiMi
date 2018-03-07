//
//  TrendsWithTextAndPictrueCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/18.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TrendsWithTextAndPictrueCell: TrendsWithTextCell {
    var collectionView:UICollectionView!
    var tapPictureBlock:((Int)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentText.snp.remakeConstraints { (make) in
            make.top.equalTo(self.trendsContentContainView)
            make.left.equalTo(self.trendsContentContainView).offset(textAreaMarginToWindow)
            //make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView).offset(-textAreaMarginToWindow)
        }
        
        let collectionFrame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH-CGFloat(mediaContainViewMarginToWindow*2), height: 0)
        let layout = UICollectionViewFlowLayout()
        let blankSpace = (mediaContainViewMarginToWindow + multiPictureSpacing)*2
         let itemWidth = CGFloat(SCREEN_WIDTH - CGFloat(blankSpace))/3.0
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.itemSize = itemSize
        layout.minimumInteritemSpacing = CGFloat(multiPictureSpacing - 0.1)
        layout.minimumLineSpacing = CGFloat(multiPictureSpacing - 0.1)
        self.collectionView = UICollectionView.init(frame: collectionFrame, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.register(UINib(nibName: "TrendsImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "TrendsImageCollectionCell")
        self.trendsContentContainView.addSubview(collectionView)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    //MARK: - misc
    override func configWith(model: TrendModel?) {
        super.configWith(model: model)
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

extension TrendsWithTextAndPictrueCell:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let pics = self.model?.action_pic{
            return pics.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendsImageCollectionCell", for: indexPath) as! TrendsImageCollectionCell
        if let pics = self.model?.action_pic{
            cell.configWith(picUrl: pics[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let imgArr = self.model?.action_pic{
            let photoBroswer = XLPhotoBrowser.show(withCurrentImageIndex: indexPath.row, imageCount: UInt(imgArr.count), datasource: self)
            photoBroswer?.browserStyle = .indexLabel
            photoBroswer?.setActionSheeWith(self)
        }
        if let _tapPictureBlock = self.tapPictureBlock{
            _tapPictureBlock(indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let blankSpace = (mediaContainViewMarginToWindow + multiPictureSpacing)*2
        let itemWidth = CGFloat(SCREEN_WIDTH - CGFloat(blankSpace))/3.0
        var itemSize = CGSize(width: itemWidth, height: itemWidth)
        if let pics = self.model?.action_pic{
            if pics.count == 1{
                itemSize.width = SCREEN_WIDTH-CGFloat(mediaContainViewMarginToWindow*2)
                itemSize.height = itemSize.width*CGFloat(singlePictureHeightAndWidthRatio)
            }
            if pics.count == 2 || pics.count == 4{
                itemSize.width = (SCREEN_WIDTH-CGFloat(mediaContainViewMarginToWindow*2) - CGFloat(multiPictureSpacing))/2.0
                itemSize.height = itemSize.width
            }
        }
        return itemSize
    }
}

extension TrendsWithTextAndPictrueCell:XLPhotoBrowserDelegate,XLPhotoBrowserDatasource{
    func photoBrowser(_ browser: XLPhotoBrowser!, clickActionSheetIndex actionSheetindex: Int, currentImageIndex: Int) {
        browser.saveCurrentShowImage()
    }
    
    func photoBrowser(_ browser: XLPhotoBrowser!, placeholderImageFor index: Int) -> UIImage! {
        let trendsImageCollectionCell = self.collectionView.cellForItem(at: IndexPath.init(row: index, section: 0)) as! TrendsImageCollectionCell
        return trendsImageCollectionCell.imgV.image == nil ? UIImage.init(named: "guanyu_icon") : trendsImageCollectionCell.imgV.image
    }
    
    func photoBrowser(_ browser: XLPhotoBrowser!, sourceImageViewFor index: Int) -> UIImageView! {
        let trendsImageCollectionCell = self.collectionView.cellForItem(at: IndexPath.init(row: index, section: 0)) as! TrendsImageCollectionCell
        return trendsImageCollectionCell.imgV
    }
    
    func photoBrowser(_ browser: XLPhotoBrowser!, highQualityImageURLFor index: Int) -> URL! {
        let actionPics = self.model?.action_pic!
        let url = URL.init(string: actionPics![index])
        return url!
    }
}

