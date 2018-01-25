//
//  UserDetailSelectTrendsTypeCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

enum TrendsType {
    case demand
    case trends
}

class UserDetailSelectTrendsTypeCell: UITableViewCell {
    @IBOutlet weak var demandBtn: UIButton!
    @IBOutlet weak var trendsBtn: UIButton!
    @IBOutlet weak var lineDemande: UIView!
    @IBOutlet weak var lineTrends: UIView!
    
    var selectTrendsTypeBlock:((TrendsType)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lineDemande.layer.cornerRadius = 1.5
        self.lineTrends.layer.cornerRadius = 1.5
        
        self.showWith(trendsType: .demand)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - misc
    func showWith(trendsType:TrendsType){
        let isDemand = trendsType == .demand ? true:false
        
        self.demandBtn.isSelected = isDemand
        self.lineDemande.isHidden = !isDemand
        
        self.trendsBtn.isSelected = !isDemand
        self.lineTrends.isHidden = isDemand
    }
    @IBAction func dealSelectDemand(_ sender: Any) {
        if let _selectTrendsTypeBlock = self.selectTrendsTypeBlock{
            _selectTrendsTypeBlock(.demand)
        }
        self.showWith(trendsType: .demand)
    }
    @IBAction func dealSelectTrends(_ sender: Any) {
        if let _selectTrendsTypeBlock = self.selectTrendsTypeBlock{
            _selectTrendsTypeBlock(.trends)
        }
        self.showWith(trendsType: .trends)
    }
}













