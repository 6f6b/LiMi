//
//  NearbyPurposeListView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/17.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol NearbyPurposeListViewDelegate : class{
    func nearbyPurposeListView(view:NearbyPurposeListView,selectedWith model:NearbyPurposeModel) -> Bool
}

class NearbyPurposeListView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    var dataArray = [NearbyPurposeModel]()
    weak var delegate:NearbyPurposeListViewDelegate?
    var selectedIndex:Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib.init(nibName: "PurposeItemCell", bundle: nil), forCellWithReuseIdentifier: "PurposeItemCell")
    }
}

extension NearbyPurposeListView : UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= self.dataArray.count{return }
        let model = self.dataArray[indexPath.row]
        let isSelected = self.delegate?.nearbyPurposeListView(view: self, selectedWith: model)

        if isSelected == true{
            self.selectedIndex = indexPath.row
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let purposeItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PurposeItemCell", for: indexPath) as! PurposeItemCell
        if indexPath.row >= self.dataArray.count{return purposeItemCell}
        let model = self.dataArray[indexPath.row]
        let isSelected = indexPath.row == self.selectedIndex ? true : false
        purposeItemCell.configWith(model: model, isSelected: isSelected)
        return purposeItemCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 50, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return (frame.size.width-50*4-1)/4.0
    }
}
