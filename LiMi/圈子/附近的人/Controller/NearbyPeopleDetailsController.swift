//
//  NearbyPeopleDetailsController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/21.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class NearbyPeopleDetailsController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    override var prefersStatusBarHidden: Bool{return true}
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var purposeCollectionView: UICollectionView!
    @IBOutlet weak var addressInfo: UILabel!
    @IBOutlet weak var ageInfo: UILabel!
    @IBOutlet weak var signature: UILabel!
    var userInfoModel:FoolishUserInfoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.purposeCollectionView.delegate = self
        self.purposeCollectionView.dataSource = self
        self.purposeCollectionView.register(UINib.init(nibName: "PurposeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PurposeCollectionViewCell")
        self.configWith(model: self.userInfoModel)
        
        self.photo.isUserInteractionEnabled = true
        let swipe = UISwipeGestureRecognizer.init(target: self, action: #selector(dealSwipe))
        swipe.direction = .down
        self.photo.addGestureRecognizer(swipe)
//        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(dealSwipe))
//        self.photo.addGestureRecognizer(pan)
    }
    
    @objc func dealSwipe(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickChatButton(_ sender: Any) {
        ChatWith(toUserId: userInfoModel?.user_id, navigationController: self.navigationController)
    }
    
    
    func configWith(model:FoolishUserInfoModel?){
        self.userInfoModel = model
        if let _photo = model?.photo{
            self.photo.kf.setImage(with: URL.init(string: _photo))
        }
        self.nickName.text = model?.nickname
        var addressInfo = ""
        if let distance = model?.distance{
            addressInfo.append("\(distance)  ")
        }
        if let city = model?.city{
            addressInfo.append("\(city)  ")
        }
        if let college = model?.college{
            addressInfo.append("\(college)")
        }
        self.addressInfo.text = addressInfo
        var ageInfo = ""
        if model?.sex == 0{
            ageInfo.append("女/")
        }else{
            ageInfo.append("男/")
        }
        if let age = model?.age{
            ageInfo.append("\(age)/")
        }
        if let constellation = model?.constellation{
            ageInfo.append("\(constellation)")
        }
        self.ageInfo.text = ageInfo
        var signatrueText = "暂无签名"
        if let _signature = model?.signature{
            signatrueText = _signature
        }
        self.signature.text = "个性签名：\(signatrueText)"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension NearbyPeopleDetailsController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let targets = self.userInfoModel?.target{
            return targets.count
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let purposeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PurposeCollectionViewCell", for: indexPath) as! PurposeCollectionViewCell
        let name = self.userInfoModel?.target![indexPath.row]
        purposeCollectionViewCell.configWith(name: name!)
        return purposeCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let name = self.userInfoModel?.target![indexPath.row]{
            var size = NSString.init(string: name).boundingRect(with: CGSize.init(width: 1000, height: 22), options: .usesFontLeading, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12, weight: .medium)], context: nil).size
            size.width += 10
            size.height = 22
            return size
        }
        return CGSize.zero
    }
}
