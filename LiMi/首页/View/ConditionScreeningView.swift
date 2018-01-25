//
//  ConditionScreeningView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/25.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ConditionScreeningView: UIView {
    @IBOutlet weak var conditionContainView: UIView!
    @IBOutlet weak var leftTapView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapG = UITapGestureRecognizer.init(target: self, action: #selector(dealCancel))
        self.leftTapView.addGestureRecognizer(tapG)
        
        let collectionFrame = CGRect.init(x: 0, y: 20, width: SCREEN_WIDTH*(600/750.0), height: SCREEN_HEIGHT-49-20)
        self.collectionView.frame = collectionFrame
        self.collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        self.collectionView.register(UINib.init(nibName: "ConditionScreeningCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ConditionScreeningCollectionCell")
        self.collectionView.register(ConditionScreeningHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ConditionScreeningHeaderView")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    //MARK: - misc
    @objc func dealCancel(){
        self.removeFromSuperview()
    }

    @IBAction func dealReset(_ sender: Any) {
    }
    
    @IBAction func dealOK(_ sender: Any) {
        
    }
    
}

extension ConditionScreeningView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConditionScreeningCollectionCell", for: indexPath) as! ConditionScreeningCollectionCell
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            let size = CGSize.init(width: (SCREEN_WIDTH*(600.0/750)-31)/3.0, height: 44)
            return size
        }
        let size = CGSize.init(width: (SCREEN_WIDTH*(600.0/750)-31)/3.0, height: 33)
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerSize = CGSize(width: SCREEN_WIDTH, height: 50)
        return headerSize
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ConditionScreeningHeaderView", for: indexPath) as! ConditionScreeningHeaderView
            headerView.headImgV.image = UIImage.init(named: "sx_icon_xingbie")
            headerView.info.text = "性别"
            return headerView
    }
}
