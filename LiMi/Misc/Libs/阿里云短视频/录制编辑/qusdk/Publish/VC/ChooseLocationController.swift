//
//  ChooseLocationController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/24.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import MJRefresh

protocol ChooseLocationControllerDelegate:class {
    func chooseLocationController(controller:ChooseLocationController, selectedLocation model:LocationModel)
}
class ChooseLocationController: PulishNextController {
    var dataArray = [LocationModel]()
    weak var delegate:ChooseLocationControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "地理位置"
        self.searchTextField.placeholder = "搜索位置"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "LocationListCell", bundle: nil), forCellReuseIdentifier: "LocationListCell")
        self.tableView.register(UINib.init(nibName: "LocationInfoCell", bundle: nil), forCellReuseIdentifier: "LocationInfoCell")
        
        self.searchTextField.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: UIControlEvents.editingChanged)
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.loadDataWith(name: self.searchTextField.text)
        }
        self.tableView.mj_footer = mjGifFooterWith {[unowned self]  in
            self.loadDataWith(name: self.searchTextField.text)
        }
        loadDataWith(name: self.searchTextField.text)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadDataWith(name:String?){
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let longitude = LocationManager.shared.location?.coordinate.longitude as? Double
        let latitude = LocationManager.shared.location?.coordinate.latitude as? Double
        let getPoiData = GetPoiData.init(lng: longitude, lat: latitude, address: name)
        _ = moyaProvider.rx.request(.targetWith(target: getPoiData)).subscribe(onSuccess: {[unowned self] (response) in
            let locationListModel = Mapper<LocationListModel>().map(jsonData: response.data)
            self.dataArray.removeAll()
            if let locations = locationListModel?.data{
                for location in locations{
                    self.dataArray.append(location)
                }
            }
            self.tableView.reloadData()
            Toast.showErrorWith(model: locationListModel)
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.beginRefreshing()
            }, onError: { (error) in
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.beginRefreshing()
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

extension ChooseLocationController{
    @objc func textFieldValueChanged(textField:UITextField){
        self.loadDataWith(name: textField.text)
    }
}

extension ChooseLocationController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{return 1}
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            self.delegate?.chooseLocationController(controller: self, selectedLocation: self.dataArray[indexPath.row])
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let locationInfoCell = tableView.dequeueReusableCell(withIdentifier: "LocationInfoCell", for: indexPath) as! LocationInfoCell
            return locationInfoCell
        }
        if indexPath.section == 1{
            let model = self.dataArray[indexPath.row]
            let locationListCell = tableView.dequeueReusableCell(withIdentifier: "LocationListCell", for: indexPath) as! LocationListCell
            locationListCell.configWith(model: model)
            return locationListCell
        }
        return UITableViewCell()
    }
}
