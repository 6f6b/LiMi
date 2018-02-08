//
//  TagListView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/21.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD
import ObjectMapper
import Moya

class TagListView: UIView {
    var topCoverView:UIView!   //顶部半透明覆盖
    var bottomContainView:UIView!   //底部容器
    var infoLabel:UILabel!
    var collectionView:UICollectionView!    //标签容器
    var cancelBtn:UIButton! //取消按钮
    var topCoverViewHeightConstraint:Constraint?
    var bottomContainViewBottomConstraint:Constraint?
    var dataArray = [SkillModel]()
    var selectTagBlock:((SkillModel?)->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.topCoverView = UIView()
        let tapG = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        self.topCoverView.addGestureRecognizer(tapG)
        self.topCoverView.backgroundColor = RGBA(r: 51, g: 51, b: 51, a: 0.5)
        self.addSubview(self.topCoverView)
        self.topCoverView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            self.topCoverViewHeightConstraint = make.height.equalTo(SCREEN_HEIGHT+10).constraint
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
            make.bottom.equalTo(self)
        }
        
        self.infoLabel = UILabel()
        infoLabel.text = "请选择所需标签（选填）"
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
        self.cancelBtn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        self.cancelBtn.sizeToFit()
        self.bottomContainView.addSubview(self.cancelBtn)
        self.cancelBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.bottomContainView)
            make.top.equalTo(self.collectionView.snp.bottom).offset(40)
            make.bottom.equalTo(self.bottomContainView).offset(-15)
        }
        
        self.loadData()
    }
    
    static func shareTagListView()->TagListView{
        return TagListView.init(frame: SCREEN_RECT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -  misc
    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let skillList = SkillList()
        _ = moyaProvider.rx.request(.targetWith(target: skillList)).subscribe(onSuccess: { (response) in
            let skillListModel = Mapper<SkillListModel>().map(jsonData: response.data)
            HandleResultWith(model: skillListModel)
            if let skillModels = skillListModel?.skills{
                for skillModel in skillModels{
                    self.dataArray.append(skillModel)
                }
            }
            self.collectionView.reloadData()
            self.show()
            SVProgressHUD.showErrorWith(model: skillListModel)
        }, onError: { (error) in
            SVProgressHUD.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func show(animation:Bool = true){
        self.frame = SCREEN_RECT
        UIApplication.shared.keyWindow?.addSubview(self)
        if animation{
            let delayTime = DispatchTime(uptimeNanoseconds: UInt64(0.1))
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                self.collectionView.snp.makeConstraints { (make) in
                    make.height.equalTo(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
                }
                UIView.animate(withDuration: 0.2, animations: {
                    //animation
                    self.topCoverViewHeightConstraint?.deactivate()
                    self.bottomContainView.snp.makeConstraints({ (make) in
                        self.bottomContainViewBottomConstraint = make.bottom.equalTo(self).constraint
                    })
                    self.layoutIfNeeded()
                })
            })
        }
    }
    
    @objc func dismiss(animation:Bool = true){
//        if animation{
            let delayTime = DispatchTime(uptimeNanoseconds: UInt64(0.1))
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                UIView.animate(withDuration: 0.2, animations: {
                    //animation
                    self.bottomContainViewBottomConstraint?.deactivate()
                    self.topCoverView.snp.makeConstraints({ (make) in
                        self.topCoverViewHeightConstraint = make.height.equalTo(SCREEN_HEIGHT+10).constraint
                    })
                    self.layoutIfNeeded()
                }, completion: { (_) in
                    self.removeFromSuperview()
                })
            })
//        }
    }
    
}

extension TagListView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionCell", for: indexPath) as! TagCollectionCell
        tagCell.configWith(skillModel: self.dataArray[indexPath.row])
        return tagCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _selectTagBlock = self.selectTagBlock{
            _selectTagBlock(self.dataArray[indexPath.row])
        }
        self.dismiss()
    }
}
