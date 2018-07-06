//
//  TopSlideMenu.swift
//  TopSlideMenuDemo
//
//  Created by dev.liufeng on 2018/7/4.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
protocol TopSlideMenuDelegate {
    func topSlideMenuSelectedWith(index:Int)
}

class TopSlideMenu: UIView {
    var childViews = [UIView]()
    var titles = [String]()
    var selectedIndex:Int = 0
    var menuView:UICollectionView!
    var contentView: UIScrollView!
    var delegate:TopSlideMenuDelegate?
    
    convenience init(frame:CGRect,titles:[String],childViews:[UIView],delegate:TopSlideMenuDelegate?){
        self.init(frame: frame)
        
        let layOut = UICollectionViewFlowLayout.init()
        layOut.scrollDirection = .horizontal
        self.menuView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: 40), collectionViewLayout: layOut)
        self.menuView.showsHorizontalScrollIndicator = false
//        self.menuView.backgroundColor = UIColor.red
        self.menuView.register(UINib.init(nibName: "MenuItemCell", bundle: nil), forCellWithReuseIdentifier: "MenuItemCell")
        self.menuView.contentInset = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 15)
        self.menuView.backgroundColor = RGBA(r: 21, g: 21, b: 21, a: 1)
        self.menuView.delegate = self
        self.menuView.dataSource = self
        self.addSubview(self.menuView)
        
        self.contentView = UIScrollView.init(frame: CGRect.init(x: 0, y: 40, width: frame.size.width, height: frame.size.height-40))
        self.contentView.showsHorizontalScrollIndicator = false
        self.contentView.isPagingEnabled = true
        self.contentView.delegate = self
        self.contentView.contentSize = CGSize.init(width: CGFloat(childViews.count)*self.frame.size.width, height: 0)
        self.addSubview(self.contentView)
        
        for title in titles{
            self.titles.append(title)
        }
        for i in 0..<childViews.count{
            let childView = childViews[i]
            childView.frame = CGRect.init(x: CGFloat(i)*frame.size.width, y: 0, width: frame.size.width, height: frame.size.height-40)
            self.childViews.append(childView)
            self.contentView.addSubview(childView)
        }
        self.delegate = delegate
        self.menuView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setSelected(index:Int){
        self.selectedIndex = index
        self.delegate?.topSlideMenuSelectedWith(index: index)
        self.menuView.reloadData()
        let scrollViewIndex = Int(self.contentView.contentOffset.x/self.contentView.frame.size.width)
        if scrollViewIndex == index{return}else{
            self.contentView.contentOffset = CGPoint.init(x: CGFloat(index)*self.contentView.frame.size.width, y: 0)
        }
    }
}

extension TopSlideMenu:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let menuItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
        let isSelected = indexPath.row == self.selectedIndex ? true : false
        let title = self.titles[indexPath.row]
        menuItemCell.configWith(title: title, isSelected: isSelected)
        return menuItemCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.setSelected(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 50, height: 40)
    }
}

extension TopSlideMenu : UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.menuView{return}
        let index = Int(scrollView.contentOffset.x/scrollView.frame.size.width)
        self.setSelected(index: index)
    }
}
