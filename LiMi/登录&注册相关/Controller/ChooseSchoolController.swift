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

class ChooseSchoolController: ViewController {
    var tableView:UITableView!
    var chooseBlock:((CollegeModel?)->Void)?
    var dataArray:[CollegeModel]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择学校"
        var frame = self.view.bounds
        frame.size.height -= 64
        self.tableView = UITableView(frame: frame)
        self.view.addSubview(self.tableView)
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "CollegeCell", bundle: nil), forCellReuseIdentifier: "CollegeCell")
        dataArray = [CollegeModel]()
        self.requestData()
    }
    
    
    deinit {
        print("选择学校销毁")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestData(){
        let moyaProvider = MoyaProvider<LiMiAPI>()
        let collegeList = CollegeList(provinceID: "510000")
        
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
    
    func handle(collegeModels:[CollegeModel]?){
        //创建多维数组
        let dataArray = NSMutableArray()
        for i in 0..<24{
            let sectionDic = NSMutableDictionary()
            let ascllCode = 65 + i
            sectionDic["title"] = Character.init(Unicode.Scalar.init(ascllCode)!)
            sectionDic["colleges"] = NSMutableArray()
            dataArray.add(sectionDic)
        }
        //添加元素
//        NSMutableArray
        if let collegeModels = collegeModels{
            for collegeModel in collegeModels{
                if let collegeName = collegeModel.name{
                    var mutStr = NSMutableString.init(string: collegeName) as CFMutableString
                    if CFStringTransform(mutStr, nil, kCFStringTransformToLatin, false){
                        //首字符转大写
                        let letterStr = mutStr as String
                        let upLetterStr = letterStr.uppercased()
                        //获取首字母
                        if let firstCharacter = upLetterStr.first as? String{
                            //存入字典
                            for sectionDic in dataArray{
                                let mutSectionDic = sectionDic as! NSMutableDictionary
                                if mutSectionDic["title"] as! String == firstCharacter{
                                    let colleges = mutSectionDic["colleges"] as! NSMutableArray
                                    colleges.add(collegeModel)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}

extension ChooseSchoolController:UITableViewDelegate,UITableViewDataSource{
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
        if let chooseBlock = self.chooseBlock{
            chooseBlock(self.dataArray[indexPath.row])
        }
        self.navigationController?.popViewController(animated: true)
    }
}

