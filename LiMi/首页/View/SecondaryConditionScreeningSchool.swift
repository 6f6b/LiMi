//
//  SecondaryConditionScreeningSchool.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/3/23.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class SecondaryConditionScreeningSchool: SecondaryConditionScreeningView {
    var selecteBlock:((CollegeModel?)->Void)?
    var selectedCollegeModel:CollegeModel?
    var dataArray = [CollegeModel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel.text = "学校"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "ScreeningSchoolCell", bundle: nil), forCellReuseIdentifier: "ScreeningSchoolCell")
        self.tableView.estimatedRowHeight = 100
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.loadData()
    }
    
    override func dealOK(){
        if let _selectBlock = self.selecteBlock{
            _selectBlock(self.selectedCollegeModel)
        }
        self.dealPop()
    }
    
    func loadData(){
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let collegeList = CollegeList(college: nil)
        
        _ = moyaProvider.rx.request(.targetWith(target: collegeList)).subscribe(onSuccess: { (response) in
            let collegeContainerModel = Mapper<CollegeContainerModel>().map(jsonData: response.data)
            if let colleges = collegeContainerModel?.colleges{
                self.dataArray = colleges
                self.tableView.reloadData()
            }
            //            self.handle(collegeModels: collegeContainerModel?.colleges)
            Toast.showErrorWith(model: collegeContainerModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

extension SecondaryConditionScreeningSchool:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.dataArray[indexPath.row]
        if let _selectedModel = self.selectedCollegeModel{
            if _selectedModel.coid == model.coid{
                model.isSelected = _selectedModel.isSelected
            }
        }

        let screeningSchoolCell = tableView.dequeueReusableCell(withIdentifier: "ScreeningSchoolCell", for: indexPath) as! ScreeningSchoolCell
        screeningSchoolCell.configWith(model: model)
        return screeningSchoolCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectModel = self.dataArray[indexPath.row]
        let isSelected = selectModel.isSelected
        for model in self.dataArray{
            model.isSelected = false
        }
        selectModel.isSelected = !isSelected
        tableView.reloadData()
        self.selectedCollegeModel = selectModel.isSelected ? selectModel : nil
    }
}
