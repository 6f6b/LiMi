//
//  ProvinceListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/3.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class ProvinceListController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var tableView: UITableView!
    var selectCityBlock:((CityModel)->Void)?
    var dataArray = [ProvinceModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置地区"

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "ProvinceListCell", bundle: nil), forCellReuseIdentifier: "ProvinceListCell")
        self.requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func requestData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let provinceList = ProvinceList.init()
        _ = moyaProvider.rx.request(.targetWith(target: provinceList)).subscribe(onSuccess: { (response) in
            let provinceListModel = Mapper<ProvinceListModel>().map(jsonData: response.data)
            if let provinces = provinceListModel?.data{
                for province in provinces{
                    self.dataArray.append(province)
                }
                self.tableView.reloadData()
            }
            Toast.showErrorWith(model: provinceListModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}

extension ProvinceListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let provinceListCell = tableView.dequeueReusableCell(withIdentifier: "ProvinceListCell", for: indexPath) as! ProvinceListCell
        let provinceModel = self.dataArray[indexPath.row]
        provinceListCell.configWith(model: provinceModel)
        return provinceListCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cityListController = CityListController()
        let provinceModel = self.dataArray[indexPath.row]
        cityListController.provinceModel = provinceModel
        cityListController.selectCityBlock = {[unowned self] (cityModel) in
            if let _selectCityBlock = self.selectCityBlock{
                _selectCityBlock(cityModel)
            }
        }
        self.navigationController?.pushViewController(cityListController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
