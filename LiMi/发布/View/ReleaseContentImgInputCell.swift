//
//  ReleaseContentImgInputCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SnapKit

class ReleaseContentImgInputCell: UITableViewCell {
    var collectionView:UICollectionView!
    var imgArry = [LocalMediaModel]()
    var addImgBlock:(()->Void)?    //添加图片
    var deleteImgBlock:((Int)->Void)?   //删除图片
    var heightConstraint:Constraint?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let collectionFrame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH-16*2, height: 0)
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (SCREEN_WIDTH-16*2-5*2)/3
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.itemSize = itemSize
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 0, bottom: 10, right: 0)
        self.collectionView = UICollectionView.init(frame: collectionFrame, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ReleaseContentImgCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ReleaseContentImgCollectionCell")
        collectionView.register(UINib(nibName: "ReleaseContentAddImgCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ReleaseContentAddImgCollectionCell")
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - misc
    func configWith(imgArry:[LocalMediaModel]){
        self.imgArry = imgArry
        self.collectionView.reloadData()
        self.collectionView.snp.updateConstraints { (make) in
            make.height.equalTo(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
        }
//        self.collectionView.snp.makeConstraints { (make) in
//            make.height.equalTo(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
//        }
    }
}

extension ReleaseContentImgInputCell:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemsCount = self.imgArry.count < 9 ? self.imgArry.count + 1 : self.imgArry.count
        return itemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == self.imgArry.count{
            let addImgCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseContentAddImgCollectionCell", for: indexPath) as! ReleaseContentAddImgCollectionCell
            addImgCollectionCell.addBlock = {
                if let _addImgBlock = self.addImgBlock{
                    _addImgBlock()
                }
            }
            return addImgCollectionCell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseContentImgCollectionCell", for: indexPath) as! ReleaseContentImgCollectionCell
        cell.configWith(mediaModel: self.imgArry[indexPath.row])
        cell.deleteBlock = {
            if let _deleteImgBlock = self.deleteImgBlock{
                _deleteImgBlock(indexPath.row)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

