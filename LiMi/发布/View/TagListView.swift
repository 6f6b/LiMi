//
//  TagListView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/21.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SnapKit

class TagListView: UIView {
    var topCoverView:UIView!   //顶部半透明覆盖
    var bottomContainView:UIView!   //底部容器
    var infoLabel:UILabel!
    var collectionView:UICollectionView!    //标签容器
    var cancelBtn:UIButton! //取消按钮
    var topCoverViewHeightConstraint:Constraint?
    //var collectionViewBottomConstraint:Constraint?
    var bottomContainViewBottomConstraint:Constraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.topCoverView = UIView()
        let tapG = UITapGestureRecognizer(target: self, action: #selector(hiddenTagList))
        self.topCoverView.addGestureRecognizer(tapG)
        self.topCoverView.backgroundColor = RGBA(r: 51, g: 51, b: 51, a: 0.5)
        self.addSubview(self.topCoverView)
        self.topCoverView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            self.topCoverViewHeightConstraint = make.height.equalTo(SCREEN_HEIGHT).constraint
        }
        
        self.bottomContainView = UIView()
        self.bottomContainView.backgroundColor = UIColor.white
        self.bottomContainView.layer.cornerRadius = 10
        self.bottomContainView.clipsToBounds = true
        self.addSubview(self.bottomContainView)
        self.bottomContainView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topCoverView.snp.bottom).offset(-10)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        
        self.infoLabel = UILabel()
        infoLabel.text = "请选择所需标签（必选）"
        infoLabel.textColor = RGBA(r: 153, g: 153, b: 153, a: 1)
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        self.bottomContainView.addSubview(self.infoLabel)
        self.infoLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.bottomContainView)
            make.top.equalTo(self.bottomContainView).offset(20)
        }
        
        let collectionViewFrame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 0)
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (SCREEN_WIDTH-30*4)/3
        let itemHeight = CGFloat(26)
        let itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.itemSize = itemSize
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 30
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 30, bottom: 0, right: 30)
        self.collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(UINib.init(nibName: "TagCollectionCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.bottomContainView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.infoLabel.snp.bottom).offset(20)
            make.left.equalTo(self.bottomContainView)
            make.right.equalTo(self.bottomContainView)
        }
        
        self.cancelBtn = UIButton()
        self.cancelBtn.setImage(UIImage.init(named: "mm_btn_close"), for: .normal)
        self.cancelBtn.addTarget(self, action: #selector(hiddenTagList), for: .touchUpInside)
        self.cancelBtn.sizeToFit()
        self.bottomContainView.addSubview(self.cancelBtn)
        self.cancelBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.bottomContainView)
            make.top.equalTo(self.collectionView.snp.bottom).offset(40)
            make.bottom.equalTo(self.bottomContainView).offset(-15)
        }
        
        self.showTagList()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        self.showTagList()
//    }
    
    //MARK: -  misc
    @objc func hiddenTagList(){
        UIView.animate(withDuration: 1, animations: {
            self.bottomContainViewBottomConstraint?.deactivate()
            self.topCoverView.snp.makeConstraints { (make) in
                self.topCoverViewHeightConstraint = make.height.equalTo(SCREEN_HEIGHT).constraint
            }
            self.allSubViewsLayOutWith(superV: self)
        }) { (isCompleted) in
            if isCompleted{
                self.removeFromSuperview()
            }
        }
    }
    
    @objc func showTagList(){
        self.collectionView.reloadData()
        self.collectionView.snp.makeConstraints { (make) in
            make.height.equalTo(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
        }
        
        UIView.animate(withDuration: 1) {
            self.topCoverViewHeightConstraint?.deactivate()
            self.bottomContainView.snp.makeConstraints({ (make) in
                self.bottomContainViewBottomConstraint = make.bottom.equalTo(self).constraint
            })
            self.allSubViewsLayOutWith(superV: self)
        }
    }
    
    func allSubViewsLayOutWith(superV:UIView?){
        if let subVs = superV?.subviews{
            if subVs.count != 0{
                for subV in subVs{
                    subV.layoutIfNeeded()
                    allSubViewsLayOutWith(superV: subV)
                }
            }else{return}
        }else{return}
    }
}

extension TagListView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionCell", for: indexPath) as! TagCollectionCell
        return tagCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
