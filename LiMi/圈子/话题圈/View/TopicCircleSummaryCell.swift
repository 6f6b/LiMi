//
//  TopicCircleSummaryCell.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/26.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class TopicCircleSummaryCell: UITableViewCell {
    @IBOutlet weak var topicCircleTitle: UILabel!
    @IBOutlet weak var topicSummary: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configWith(model:TopicsContainModel?){
        self.topicCircleTitle.text = model?.topicCircleModel?.title
        self.topicSummary.text = model?.topicCircleModel?.content
    }
}
