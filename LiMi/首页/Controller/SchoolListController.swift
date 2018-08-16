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
    @IBOutlet weak var searchTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var recommendSchoolsContainView: UIView!
    lazy var collegeInfoContainView:CollegeInfoContainView = {
        let collegeInfoContainView = GET_XIB_VIEW(nibName: "CollegeInfoContainView") as! CollegeInfoContainView
        collegeInfoContainView.frame = self.recommendSchoolsContainView.bounds
        collegeInfoContainView.delegate = self
        self.recommendSchoolsContainView.addSubview(collegeInfoContainView)
        return collegeInfoContainView
    }()
    var initiaSchoolModel:CollegeModel?
    
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
        
        self.recommendSchoolsContainView.isHidden = initiaSchoolModel == nil ? true : false
        if let _collegeId = initiaSchoolModel?.id{
            self.requestPrimaryCollegesWith(collegeId: _collegeId)
        }else{
            self.refreshUI()
        }
        self.searchText.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func requestPrimaryCollegesWith(collegeId:Int){
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let collegesInfo = CollegesInfo.init(college_id: collegeId)
        _ = moyaProvider.rx.request(.targetWith(target: collegesInfo)).subscribe(onSuccess: { (response) in
            let collegeVideoInfoListModel = Mapper<CollegeVideoInfoListModel>().map(jsonData: response.data)
            var collegeVideoInfoModelsDataArray = [CollegeVideoInfoModel]()
            if let collegeVideoInfoModels = collegeVideoInfoListModel?.data{
                for collegeVideoInfoModel in collegeVideoInfoModels{
                    collegeVideoInfoModelsDataArray.append(collegeVideoInfoModel)
                }
            }
            self.refreshUI()
            self.collegeInfoContainView.configWith(datas: collegeVideoInfoModelsDataArray)
            Toast.showErrorWith(model: collegeVideoInfoListModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func refreshUI(){
        var isRecommendSchoolsContainViewHidden = true
        if self.searchText.isFirstResponder{
            self.recommendSchoolsContainView.isHidden = true
        }else{
            if let _text = self.searchText.text{
                if _text.lengthOfBytes(using: String.Encoding.utf8) <= 0 && self.initiaSchoolModel != nil{
                    isRecommendSchoolsContainViewHidden = false
                }
            }
            self.recommendSchoolsContainView.isHidden = isRecommendSchoolsContainViewHidden
        }
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
        if self.initiaSchoolModel == nil{
            self.delegate?.schoolListControllerChoosedSchoolWith(model: self.dataArray[indexPath.row])
        }else{
            let schoolsVideosController = SchoolsVideosController()
            let model = self.dataArray[indexPath.row]
            schoolsVideosController.collegeModel = model
            self.navigationController?.pushViewController(schoolsVideosController, animated: true)
        }
    }
}

extension SchoolListController{
    @objc func textFieldValueChanged(textField:UITextField){
        let isTextFieldEmpty = IsEmpty(textField: textField)
        self.refreshUI()
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

extension SchoolListController : CollegeInfoContainViewDelegate{
    func collegeInfoContainView(view: CollegeInfoContainView, clickCollegeWith model: CollegeVideoInfoModel?) {
        let schoolsVideosController = SchoolsVideosController()
        schoolsVideosController.collegeModel = model?.college
        self.navigationController?.pushViewController(schoolsVideosController, animated: true)
    }
    
    func collegeInfoContainView(view: CollegeInfoContainView, clickThumbUpWith model: CollegeVideoInfoModel?) {
        //点赞、发通知
        if let _isClick = model?.college?.is_click,let _collegeId = model?.college?.id{
            let moyaProvider = MoyaProvider<LiMiAPI>()
            let clickCollege = ClickCollege.init(college_id: model?.college?.id)
            _ = moyaProvider.rx.request(.targetWith(target: clickCollege)).subscribe(onSuccess: { (response) in
                let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
                if baseModel?.commonInfoModel?.status == successState{
                    model?.college?.is_click = !_isClick
                    if let preClickNum = model?.college?.click_num{
                        let nowClickNum = !_isClick ? (preClickNum+1) : (preClickNum-1)
                        model?.college?.click_num = nowClickNum
                    }
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "CLICK_COLLEGE_NOTIFICATION"), object: nil, userInfo: ["collegeId":_collegeId,"isClick":!_isClick])
                }
                Toast.showErrorWith(model: baseModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }
    }
}

extension SchoolListController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.refreshUI()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.refreshUI()
    }
}
