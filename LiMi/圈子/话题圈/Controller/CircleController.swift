//
//  CircleController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class CircleController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var circleHomeBannerCell:CircleHomeBannerCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        if SYSTEM_VERSION <= 11.0{
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }else{
            self.tableView.contentInset = UIEdgeInsets.init(top: -64, left: 0, bottom: 0, right: 0)
        }

        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.circleHomeBannerCell = GET_XIB_VIEW(nibName: "CircleHomeBannerCell") as! CircleHomeBannerCell
        self.circleHomeBannerCell.tapMenuBlock = {(circleMenuType) in
            if circleMenuType == .peopleNearby{
                let peopleNearbyController = PeopleNearbyController()
                self.navigationController?.pushViewController(peopleNearbyController, animated: true)
            }
            if circleMenuType == .weekendTour{
                print("周末游")
            }
            if circleMenuType == .topicCircle{
                let topicCircleController = TopicCircleController()
                self.navigationController?.pushViewController(topicCircleController, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = nil
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension CircleController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{return 0.001}
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            return self.circleHomeBannerCell
        }
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        return cell
    }
    
}


