//
//  SuspensionMenuItemCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/13.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class SuspensionMenuItemCell: UITableViewCell {
    var itemTitle: UILabel!
    var separateView:UIView!
    var actionModel:SuspensionMenuAction?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.itemTitle = UILabel()
        self.itemTitle.textAlignment = .center
        self.contentView.addSubview(self.itemTitle)
        self.itemTitle.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.contentView).offset(15)
            make.center.equalTo(self.contentView)
        }
        
        self.separateView = UIView()
        self.separateView.backgroundColor = RGBA(r: 239, g: 239, b: 239, a: 1)
        self.contentView.addSubview(self.separateView)
        self.separateView.snp.makeConstraints {[unowned self] (make) in
            make.height.equalTo(1)
            make.left.equalTo(self.contentView).offset(10)
            make.right.equalTo(self.contentView).offset(-10)
            make.bottom.equalTo(self.contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - misc
//    @IBAction func dealTap(_ sender: Any) {
//        if let _block = self.actionModel?.actionBlock{
//            _block()
//        }
//    }
    func configWith(model:SuspensionMenuAction?){
        self.actionModel = model
        self.itemTitle.text = model?.title
        self.itemTitle.textColor = model?.textColor
    }
}
