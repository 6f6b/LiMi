//
//  CityListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/3.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class CityListController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var tableView: UITableView!
    var provinceModel:ProvinceModel?
    var selectCityBlock:((CityModel)->Void)?
    var dataArray = [CityModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置地区"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "CityListCell", bundle: nil), forCellReuseIdentifier: "CityListCell")
        self.requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestData(){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let cityList = CityList.init(provinceID: self.provinceModel?.id)
        _ = moyaProvider.rx.request(.targetWith(target: cityList)).subscribe(onSuccess: { (response) in
            let cityListModel = Mapper<CityListModel>().map(jsonData: response.data)
            if let cities = cityListModel?.data{
                for city in cities{
                    self.dataArray.append(city)
                }
                self.tableView.reloadData()
            }
            Toast.showErrorWith(model: cityListModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
}

extension CityListController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cityListCell = tableView.dequeueReusableCell(withIdentifier: "CityListCell", for: indexPath) as! CityListCell
        let cityModel = self.dataArray[indexPath.row]
        cityListCell.configWith(model: cityModel)
        return cityListCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cityModel = self.dataArray[indexPath.row]
        if let _selectBlock = self.selectCityBlock{
            _selectBlock(cityModel)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
