//
//  FeedBackQuestionCategoryCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SnapKit

class FeedBackQuestionCategoryCell: UITableViewCell {
    var collectionView:UICollectionView!
    var heightConstraint:Constraint?
    var dataArray = [FeedBackQuestionModel]()
    var tapBlock:((FeedBackQuestionModel)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)

        let collectionFrame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 0)
        let layout = UICollectionViewFlowLayout()
        let itemWidth = 74
        let itemSize = CGSize(width: itemWidth, height: 38)
        layout.itemSize = itemSize
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 0, bottom: 10, right: 0)
        self.collectionView = UICollectionView.init(frame: collectionFrame, collectionViewLayout: layout)
        self.collectionView.backgroundColor = RGBA(r: 43, g: 43, b: 43, a: 1)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.register(UINib(nibName: "FeedBackQuestionCategoryCollectionCell", bundle: nil), forCellWithReuseIdentifier: "FeedBackQuestionCategoryCollectionCell")
        self.contentView.addSubview(collectionView)
        self.collectionView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(16)
            make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-16)
            self.heightConstraint = make.height.equalTo(0).constraint
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func congfigWith(models:[FeedBackQuestionModel]){
        self.dataArray = models
        self.collectionView.reloadData()
        self.collectionView.snp.updateConstraints { (make) in
            make.height.equalTo(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
        }
        self.collectionView.reloadData()
    }
}

extension FeedBackQuestionCategoryCell:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedBackQuestionCategoryCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedBackQuestionCategoryCollectionCell", for: indexPath) as! FeedBackQuestionCategoryCollectionCell
        feedBackQuestionCategoryCollectionCell.configWith(model: self.dataArray[indexPath.row])
        return feedBackQuestionCategoryCollectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0..<self.dataArray.count{
            self.dataArray[i].isSelect = false
        }
        self.dataArray[indexPath.row].isSelect = true
        self.collectionView.reloadData()
        if let _tapBlock = self.tapBlock{
            _tapBlock(self.dataArray[indexPath.row])
        }
    }
}
