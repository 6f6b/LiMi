//
//  ChallengeWithVideosCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/3.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol ChallengeWithVideosCellDelegate : class{
    func challengeWithVideosCell(cell:ChallengeWithVideosCell,didSelectItemAt indexPath: IndexPath,with model:ChallengeWithVideosModel?)
    func challengeWithVideosCell(cell:ChallengeWithVideosCell,didTapedTopContainViewWith model: ChallengeWithVideosModel?)
}

class ChallengeWithVideosCell: UITableViewCell {
    @IBOutlet weak var contentContainView: UIView!
    @IBOutlet weak var topContentContainView: UIView!
    @IBOutlet weak var challengeName: UILabel!
    @IBOutlet weak var challengeUseNum: UILabel!
    var collectionView:UICollectionView!
    var challengeWithVideosModel:ChallengeWithVideosModel?
    weak var delegate:ChallengeWithVideosCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        let collectionViewHeight = (SCREEN_WIDTH-15*2-3*2)/3*4/3
        let collectionViewWidth = SCREEN_WIDTH-30
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 3
        layout.itemSize = CGSize.init(width: collectionViewHeight*0.75, height: collectionViewHeight)
        self.collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 30, width: collectionViewWidth, height: collectionViewHeight), collectionViewLayout: layout)
        self.collectionView.backgroundColor = APP_THEME_COLOR_1
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib.init(nibName: "VideoInChallengeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "VideoInChallengeCollectionCell")
        self.contentContainView.addSubview(self.collectionView)
        
        let tapTopContainViewGes = UITapGestureRecognizer.init(target: self, action: #selector(tapedTopContainView))
        self.topContentContainView.addGestureRecognizer(tapTopContainViewGes)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func tapedTopContainView(){
        self.delegate?.challengeWithVideosCell(cell: self, didTapedTopContainViewWith: self.challengeWithVideosModel)
    }
    
    func configWith(model:ChallengeWithVideosModel?){
        self.challengeWithVideosModel = model
        self.challengeName.text = model?.challenge?.challenge_name
        if let _useNum = model?.challenge?.use_num{
            self.challengeUseNum.text = "\(_useNum)"
        }
        self.collectionView.reloadData()
    }
    
}

extension ChallengeWithVideosCell : UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let videos = self.challengeWithVideosModel?.videos{
            return videos.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let videoInChallengeCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoInChallengeCollectionCell", for: indexPath) as! VideoInChallengeCollectionCell
        let model = self.challengeWithVideosModel?.videos![indexPath.row]
        videoInChallengeCollectionCell.configWith(model: model)
        return videoInChallengeCollectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.challengeWithVideosCell(cell: self, didSelectItemAt: indexPath, with: self.challengeWithVideosModel)
    }
}
