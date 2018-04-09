//
//  AddFollowersController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/4/4.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class AddFollowersController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var placeHolderImage: UIImageView!
    @IBOutlet weak var placeHolderText: UILabel!
    var defaultDataArray = [UserInfoModel]()
    var dataArray = [UserInfoModel]()
    //var moyaProvider:MoyaProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        self.tableView.register(UINib.init(nibName: "FollowerCell", bundle: nil), forCellReuseIdentifier: "FollowerCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchText.addTarget(self, action: #selector(textFieldValueChanged(textField:)), for: UIControlEvents.editingChanged)
        
        self.loadDefaultData()
        NotificationCenter.default.addObserver(self, selector: #selector(receivedNotificationWith(notification:)), name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func dealCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - misc
    @objc func receivedNotificationWith(notification:Notification?){
        if let info = notification?.userInfo{
            let userId = info[USER_ID_KEY] as? Int
            let relationship = info[RELATIONSHIP_KEY] as? Int
            var tmpDataArray:[UserInfoModel]!
            if self.dataArray.count != 0{
                tmpDataArray = self.dataArray
            }else{
                tmpDataArray = self.defaultDataArray
            }
            for i in 0..<tmpDataArray.count{
                let userModel = tmpDataArray[i]
                if userModel.user_id == userId{
                    userModel.is_attention = relationship
                    //is_attention=0 未关注 1 已关注 2 互关注
                    self.tableView.reloadRows(at: [IndexPath.init(row: i, section: 0)], with: .none)
                }
            }
        }
    }
    
    func loadDefaultData(){
        //TopAttentionList
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let topAttentionList = TopAttentionList()
        _ = moyaProvider.rx.request(.targetWith(target: topAttentionList)).subscribe(onSuccess: { (response) in
            let userInfoList = Mapper<UserInfoListModel>().map(jsonData: response.data)
            self.dataArray.removeAll()
            if let _userInfos = userInfoList?.userInfos{
                for userInfo in _userInfos{
                    self.defaultDataArray.append(userInfo)
                }
            }
            self.tableView.reloadData()
            Toast.showErrorWith(model: userInfoList)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}

extension AddFollowersController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count == 0 ? self.defaultDataArray.count : self.dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.dataArray.count == 0 ? self.defaultDataArray[indexPath.row] : self.dataArray[indexPath.row]
        let followerCell = tableView.dequeueReusableCell(withIdentifier: "FollowerCell", for: indexPath) as! FollowerCell
        followerCell.configWith(model: model)
        return followerCell
    }
}

extension AddFollowersController{
    @objc func textFieldValueChanged(textField:UITextField){
        let isTextFieldEmpty = IsEmpty(textField: textField)
        self.placeHolderImage.isHidden = !isTextFieldEmpty
        self.placeHolderText.isHidden = !isTextFieldEmpty
        print("开始执行搜索")
        if isTextFieldEmpty {return}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let searchUser = SearchUser.init(nickname: textField.text)
        _ = moyaProvider.rx.request(.targetWith(target: searchUser)).subscribe(onSuccess: { (response) in
            let userInfoList = Mapper<UserInfoListModel>().map(jsonData: response.data)
            self.dataArray.removeAll()
            if let _userInfos = userInfoList?.userInfos{
                for userInfo in (userInfoList?.userInfos)!{
                    self.dataArray.append(userInfo)
                }
            }
            self.tableView.reloadData()
            Toast.showErrorWith(model: userInfoList)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
}
