//
//  SchoolListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import SVProgressHUD

protocol SchoolListControllerDelegate : class{
    func schoolListControllerChoosedSchoolWith(model:CollegeModel)
    func schoolListControllerCancelButtonClicked()
}
class SchoolListController: UIViewController {
    override var prefersStatusBarHidden: Bool{return true}

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var placeHolderImage: UIImageView!
    @IBOutlet weak var placeHolderText: UILabel!
//    @IBOutlet weak var clearSearchTextButton: UIButton!
    @IBOutlet weak var searchTopConstraint: NSLayoutConstraint!
    
    weak var delegate:SchoolListControllerDelegate?
    var dataArray:[CollegeModel]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = RGBA(r: 30, g: 30, b: 30, a: 1)
        
        let clearButton = self.searchText.value(forKey: "_clearButton") as! UIButton
        clearButton.setImage(UIImage.init(named: "shanchu"), for: .normal)
        
        self.searchTopConstraint.constant = STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 1000
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "CollegeCell", bundle: nil), forCellReuseIdentifier: "CollegeCell")
        dataArray = [CollegeModel]()
        self.requestData()
        self.searchText.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: UIControlEvents.editingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.schoolListControllerCancelButtonClicked()
    }
    
    func requestData(){
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

extension SchoolListController:UITableViewDelegate,UITableViewDataSource{
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
        cell.configWithTitle(title: self.dataArray[indexPath.row].name,style: .black)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.schoolListControllerChoosedSchoolWith(model: self.dataArray[indexPath.row])
    }
}

extension SchoolListController{
    @objc func textFieldValueChanged(textField:UITextField){
        let isTextFieldEmpty = IsEmpty(textField: textField)
//        self.placeHolderImage.isHidden = !isTextFieldEmpty
        self.placeHolderText.isHidden = !isTextFieldEmpty
//        self.clearSearchTextButton.isHidden = isTextFieldEmpty
        print("开始执行搜索")
        if IsEmpty(textField: self.searchText){return }
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let collegeList = CollegeList(college: textField.text)
        
        _ = moyaProvider.rx.request(.targetWith(target: collegeList)).subscribe(onSuccess: { (response) in
            let collegeContainerModel = Mapper<CollegeContainerModel>().map(jsonData: response.data)
            self.dataArray.removeAll()
            if let colleges = collegeContainerModel?.colleges{
                for college in colleges{
                    self.dataArray.append(college)
                }
                self.tableView.reloadData()
            }
            Toast.showErrorWith(model: collegeContainerModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

