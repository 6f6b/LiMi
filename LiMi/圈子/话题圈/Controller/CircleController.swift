//
//  CircleController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import MJRefresh
import Moya
import ObjectMapper
import SVProgressHUD

class CircleController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var tableView: UITableView!
    var dataArray = [ChallengeWithVideosModel]()
    var circleHomeBannerCell:CircleHomeBannerCell!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    var pageIndex:Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = APP_THEME_COLOR_1
        self.tableView.separatorStyle = .none

        let leftTitleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 53, height: 25))
        leftTitleLabel.textAlignment = .left
        leftTitleLabel.text = "圈子"
        leftTitleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        leftTitleLabel.textColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftTitleLabel)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.register(UINib.init(nibName: "ChallengeWithVideosCell", bundle: nil), forCellReuseIdentifier: "ChallengeWithVideosCell")
        self.circleHomeBannerCell = GET_XIB_VIEW(nibName: "CircleHomeBannerCell") as! CircleHomeBannerCell
        self.circleHomeBannerCell.tapMenuBlock = {[unowned self] (circleMenuType) in
            if circleMenuType == .peopleNearby{
                if !AppManager.shared.checkUserStatus(){
                    return
                }
//                let pulishController = PulishViewController()
//                self.navigationController?.pushViewController(pulishController, animated: true)
                
                let peopleNearbyController = PeopleNearbyController()
                self.navigationController?.pushViewController(peopleNearbyController, animated: true)
            }
            if circleMenuType == .weekendTour{
                let weekendTourController = WeekendTourController()
                self.navigationController?.pushViewController(weekendTourController, animated: true)
            }
            if circleMenuType == .topicCircle{
                let topicCircleController = TopicCircleController()
                self.navigationController?.pushViewController(topicCircleController, animated: true)
            }
        }
        
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadData()
        }
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadData()
        }
        self.loadData()
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = nil
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Mark: - misc
    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let circleList = CircleList.init(page:pageIndex)
        _ = moyaProvider.rx.request(.targetWith(target: circleList)).subscribe(onSuccess: { (response) in
            let challengeWithVideosListModel = Mapper<ChallengeWithVideosListModel>().map(jsonData: response.data)
            if self.pageIndex == 1{
                self.dataArray.removeAll()
            }
            if let challengeWithVideosModels = challengeWithVideosListModel?.data{
                for challengeWithVideosModel in challengeWithVideosModels{
                    self.dataArray.append(challengeWithVideosModel)
                }
            }
            print("reload-----data----")
            self.tableView.reloadData()
            if self.pageIndex == 1{
                self.tableView.mj_header.endRefreshing()
            }else{
                self.tableView.mj_footer.endRefreshing()
            }
            Toast.showErrorWith(model: challengeWithVideosListModel)
        }, onError: { (error) in
            if self.pageIndex == 1{
                self.tableView.mj_header.endRefreshing()
            }else{
                self.tableView.mj_footer.endRefreshing()
            }
            Toast.showErrorWith(msg: error.localizedDescription)
        })
        
    }
}

extension CircleController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        if section == 1{return self.dataArray.count}
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            let height = 10 + (SCREEN_WIDTH-30)*194.0/345.0 + 35 + 50 + 20
            return height
        }
        let videoTrendHeight = (SCREEN_WIDTH-15*2-3*2)/3*4/3
        return videoTrendHeight+25+30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            self.circleHomeBannerCell.selectionStyle = .none
            return self.circleHomeBannerCell
        }
        if indexPath.section == 1{
            print("刷新cell-----》\(indexPath.row)")
            let challengeWithVideosCell = tableView.dequeueReusableCell(withIdentifier: "ChallengeWithVideosCell", for: indexPath) as! ChallengeWithVideosCell
            challengeWithVideosCell.delegate = self
            if indexPath.row < self.dataArray.count{
                challengeWithVideosCell.configWith(model: self.dataArray[indexPath.row])
                return challengeWithVideosCell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if 1 == indexPath.section{
            let model = self.dataArray[indexPath.row]
            if let _challengeId = model.challenge?.challenge_id,let _challengeName = model.challenge?.challenge_name{
                let sameChallengeVideoListController = SameChallengeVideoListController()
                sameChallengeVideoListController.challengeId = _challengeId
                sameChallengeVideoListController.challengeName = _challengeName
                self.navigationController?.pushViewController(sameChallengeVideoListController, animated: true)
            }
        }
    }
}

extension CircleController : ChallengeWithVideosCellDelegate {
    func challengeWithVideosCell(cell: ChallengeWithVideosCell, didTapedTopContainViewWith model: ChallengeWithVideosModel?) {
        if let _challengeId = model?.challenge?.challenge_id,let _challengeName = model?.challenge?.challenge_name{
            let sameChallengeVideoListController = SameChallengeVideoListController()
            sameChallengeVideoListController.challengeId = _challengeId
            sameChallengeVideoListController.challengeName = _challengeName
            self.navigationController?.pushViewController(sameChallengeVideoListController, animated: true)
        }
    }
    
    func challengeWithVideosCell(cell: ChallengeWithVideosCell, didSelectItemAt indexPath: IndexPath, with model: ChallengeWithVideosModel?) {
        if let _challengeId = model?.challenge?.challenge_id,let models = model?.videos{
            let sameChallengeScanVideoListController = SameChallengeScanVideoListController.init(challengeId: _challengeId, currentVideoTrendIndex: indexPath.row, dataArray: models,pageIndex:self.pageIndex)
            self.navigationController?.pushViewController(sameChallengeScanVideoListController, animated: true)
        }
    }
}


