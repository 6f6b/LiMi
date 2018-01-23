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
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentText.snp.remakeConstraints { (make) in
            make.top.equalTo(self.trendsContentContainView)
            make.left.equalTo(self.trendsContentContainView)
            //make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
        }
        
        let collectionFrame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH-24, height: 0)
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (SCREEN_WIDTH-12*4)/3
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.itemSize = itemSize
        layout.minimumInteritemSpacing = 10
        self.collectionView = UICollectionView.init(frame: collectionFrame, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.register(UINib(nibName: "TrendsImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "TrendsImageCollectionCell")
        self.trendsContentContainView.addSubview(collectionView)
        self.collectionView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.contentText.snp.bottom)
            make.left.equalTo(self.trendsContentContainView)
            make.bottom.equalTo(self.trendsContentContainView)
            make.right.equalTo(self.trendsContentContainView)
        }
        
        self.collectionView.reloadData()
        self.collectionView.snp.makeConstraints { (make) in
            make.height.equalTo(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension TrendsWithTextAndPictrueCell:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendsImageCollectionCell", for: indexPath) as! TrendsImageCollectionCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}


