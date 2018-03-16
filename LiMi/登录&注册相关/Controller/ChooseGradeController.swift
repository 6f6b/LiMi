//
//  ChooseSchoolController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/9.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import SVProgressHUD

class ChooseGradeController: ViewController {
    var tableView:UITableView!
    var collegeId:Int?
    var chooseGradeBlock:((GradeModel?)->Void)?
    var dataArray:[GradeModel]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择年级"
        var frame = self.view.bounds
        frame.size.height -= 64
        self.tableView = UITableView(frame: frame)
        self.view.addSubview(self.tableView)
        self.tableView.estimatedRowHeight = 1000
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "CollegeCell", bundle: nil), forCellReuseIdentifier: "CollegeCell")
        dataArray = [GradeModel]()
        self.requestData()
    }
    
    
    deinit {
        print("选择年级销毁")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestData(){
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let gradeList = GradeList()
        
        _ = moyaProvider.rx.request(.targetWith(target: gradeList)).subscribe(onSuccess: { (response) in
            let gradeContainerModel = Mapper<GradeContainerModel>().map(jsonData: response.data)
            if let grades = gradeContainerModel?.grades{
                self.dataArray = grades
                self.tableView.reloadData()
            }
            //            self.handle(collegeModels: collegeContainerModel?.colleges)
            Toast.showErrorWith(model: gradeContainerModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }

}

extension ChooseGradeController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollegeCell", for: indexPath) as! CollegeCell
        cell.configWithTitle(title: self.dataArray[indexPath.row].name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let chooseGradeBlock = self.chooseGradeBlock{
            chooseGradeBlock(self.dataArray[indexPath.row])
        }
        self.navigationController?.popViewController(animated: true)
    }
}



