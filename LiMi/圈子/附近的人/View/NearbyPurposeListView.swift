//
//  NearbyPurposeListView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/17.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol NearbyPurposeListViewDelegate : class{
    func nearbyPurposeListView(view:NearbyPurposeListView,selectedWith purposes:String) -> Bool
}

class NearbyPurposeListView: UIView {
    var collectionView: UICollectionView!
    var dataArray = [NearbyPurposeModel]()
    weak var delegate:NearbyPurposeListViewDelegate?
    var maxSelectedNum = 1
    var selectedModels = [NearbyPurposeModel]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        let layOut = UICollectionViewFlowLayout.init()
        self.collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: layOut)
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.backgroundColor = APP_THEME_COLOR_1
        self.addSubview(self.collectionView)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib.init(nibName: "PurposeItemCell", bundle: nil), forCellWithReuseIdentifier: "PurposeItemCell")
        self.backgroundColor = APP_THEME_COLOR_1
    }
    
    convenience init(frame: CGRect,maxSelectedNum:Int=1) {
        self.init(frame: frame)
        self.maxSelectedNum = maxSelectedNum
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func reloadDataWith(models:[NearbyPurposeModel]){
        self.dataArray = models
        for model in models{
            if model.selected == true{
                self.selectedModels.append(model)
            }
        }
        self.collectionView.reloadData()
    }
    
    func clickedItemWith(clickedModel:NearbyPurposeModel?)->String{
        var currentSelectedPurposes = ""
        //先判断在不在数组中
        var isInArray = false
        if selectedModels.count >= 1{
            for i in 0 ..< self.selectedModels.count{
                let model = self.selectedModels[i]
                if model.id == clickedModel?.id{
                    isInArray = true
                    clickedModel?.selected = false
                    self.selectedModels.remove(at: i)
                    break
                }
            }
        }
        if !isInArray && clickedModel != nil{
            //没在数组中
            let errorInfo = "最多只能选择\(maxSelectedNum)个"
            if self.selectedModels.count >= self.maxSelectedNum{
                Toast.showErrorWith(msg: errorInfo)
            }else{
                if let _model = clickedModel{
                    _model.selected = true
                    self.selectedModels.append(_model)
                }
            }
        }
        self.collectionView.reloadData()
        for model in self.selectedModels{
            if let id = model.id{
                currentSelectedPurposes.append("\(id),")
            }
        }
        if currentSelectedPurposes.lengthOfBytes(using: String.Encoding.utf8) > 1{
            let nsCurrentSelectedPurposes = NSString.init(string: currentSelectedPurposes)
             currentSelectedPurposes = nsCurrentSelectedPurposes.substring(to: nsCurrentSelectedPurposes.length-1)
        }
        return currentSelectedPurposes
    }
}

extension NearbyPurposeListView : UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= self.dataArray.count{return }
        let model = self.dataArray[indexPath.row]
        let selectedPurpose = self.clickedItemWith(clickedModel: model)
        _ = self.delegate?.nearbyPurposeListView(view: self, selectedWith: selectedPurpose)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let purposeItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PurposeItemCell", for: indexPath) as! PurposeItemCell
        if indexPath.row >= self.dataArray.count{return purposeItemCell}
        let model = self.dataArray[indexPath.row]
        purposeItemCell.configWith(model: model)
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
