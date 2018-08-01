//
//  MakeChallengeController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/24.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import MJRefresh

protocol MakeChallengeControllerDelegate : class{
    func makeChallengeController(controller:MakeChallengeController, selectedChallenge model:ChallengeModel)
}
class MakeChallengeController: PulishNextController {
    var dataArray = [ChallengeModel]()
    var pageIndex:Int = 1
    weak var delegate:MakeChallengeControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "发起挑战"
        self.searchTextField.placeholder = "输入挑战内容"
        self.searchTextField.setValue(RGBA(r: 114, g: 114, b: 114, a: 1), forKeyPath: "_placeholderLabel.textColor")

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "ChallengeListCell", bundle: nil), forCellReuseIdentifier: "ChallengeListCell")
        self.tableView.register(UINib.init(nibName: "ChallengeInfoCell", bundle: nil), forCellReuseIdentifier: "ChallengeInfoCell")

        
        self.searchTextField.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: UIControlEvents.editingChanged)
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadDataWith(name: self.searchTextField.text)
        }
        self.tableView.mj_footer = mjGifFooterWith {[unowned self]  in
            self.pageIndex += 1
            self.loadDataWith(name: self.searchTextField.text)
        }
        loadDataWith(name: self.searchTextField.text)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func loadDataWith(name:String?){
        if name == nil || name == ""{self.pageIndex = 1}
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let challengeList = ChallengeList.init(page: self.pageIndex, name: name)
        
        _ = moyaProvider.rx.request(.targetWith(target: challengeList)).subscribe(onSuccess: {[unowned self] (response) in
            let challengeListModel = Mapper<ChallengeListModel>().map(jsonData: response.data)
            if self.pageIndex == 1{
                self.dataArray.removeAll()
            }
            if let challenges = challengeListModel?.data{
                for challenge in challenges{
                    self.dataArray.append(challenge)
                }
            }
            self.tableView.reloadData()
            Toast.showErrorWith(model: challengeListModel)
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
        }, onError: { (error) in
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

extension MakeChallengeController{
    @objc func textFieldValueChanged(textField:UITextField){
        self.pageIndex = 1
        self.loadDataWith(name: textField.text)
    }
}

extension MakeChallengeController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return IsEmpty(textField: self.searchTextField) ? 1 : 0
        }
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let model = self.dataArray[indexPath.row]
            self.delegate?.makeChallengeController(controller: self, selectedChallenge: model)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let challengeInfoCell = tableView.dequeueReusableCell(withIdentifier: "ChallengeInfoCell", for: indexPath) as! ChallengeInfoCell
            return challengeInfoCell
        }
        if indexPath.section == 1{
            let model = self.dataArray[indexPath.row]
            let challengeListCell = tableView.dequeueReusableCell(withIdentifier: "ChallengeListCell", for: indexPath) as! ChallengeListCell
            challengeListCell.configWith(model: model)
            return challengeListCell
        }
        return UITableViewCell()
    }
}
