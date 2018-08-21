//
//  MenuWithSwitchCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/28.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

class MenuWithSwitchCell: MenuCell {
    var switchView:UISwitch!
    var clickSwitchViewBlock:((UISwitch,IndexPath?)->Void)?
    var indexPath:IndexPath?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.rightArrowIcon.isHidden = true
        
        self.switchView = UISwitch.init()
        self.switchView.backgroundColor = RGBA(r: 62, g: 62, b: 62, a: 1)
        self.switchView.onTintColor = APP_THEME_COLOR_2
        self.switchView.layer.cornerRadius = self.switchView.frame.size.height*0.5
        self.switchView.clipsToBounds = true
        self.switchView.isOn = false
        self.switchView.addTarget(self, action: #selector(clickedSwitchView(switchView:)), for: .touchUpInside)
        self.contentView.addSubview(self.switchView)
        self.switchView.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-16)
        }
    }
    
    @objc func clickedSwitchView(switchView:UISwitch){
        if let _clickSwitchViewBlock = self.clickSwitchViewBlock{
            _clickSwitchViewBlock(switchView,self.indexPath)
        }
    }
    
    func configWith(title: String,isOn:Int?,indexPath:IndexPath) {
        super.configWith(title: title)
        self.indexPath = indexPath
        if isOn == 1{
            self.switchView.isOn = true
        }else{
            self.switchView.isOn = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
