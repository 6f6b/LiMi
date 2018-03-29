//
//  CatchRedPacketView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/22.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import ObjectMapper

//用户的性别
enum SexStatus {
    case male   //男性
    case female     //女性
    case notLogIn   //未登录
}

//红包显示状态
enum RedPacketStatus {
    case beOverdue  //超过24小时未领取，已过期
    case forMale    //男性专属
    case forFemale  //女性专属
    
    case catchFailed    //未抢到，显示列表
    case catchSucceed   //抢到了，显示列表
    
    case waitToBeCatch  //等待拆开
    
    case lootAll    //第一次点进来，抢光了
}

class CatchRedPacketView: UIView {
    @IBOutlet weak var noAuthToCatchContainView: UIView!    //没有权限去抢,容器
    @IBOutlet weak var noAuthInfo: UILabel!     //信息
    @IBOutlet weak var noAthuUserInfo: UILabel!
    @IBOutlet weak var noauthHeadImg: UIImageView!
    
    @IBOutlet weak var redPacketInfoContainView: UIView!    //打开红包后的信息，容器
    @IBOutlet weak var redPacketInfoBackgroundImg: UIImageView! //
    @IBOutlet weak var catchFaildContainView: UIView!   //失败信息，容器
    @IBOutlet weak var catchSuccessContainView: UIView! //抢成功信息，容器
    @IBOutlet weak var catchAmount: UILabel!    //金额信息
    @IBOutlet weak var catchSuccessedUsersTableView: UITableView!   //抢到的用户列表

    @IBOutlet weak var openRedPacketContainView: UIView!    //拆红包，容器
    @IBOutlet weak var headImgV: UIImageView!   //发红包人头像
    @IBOutlet weak var userInfo: UILabel!   //谁发的红包
    
    //抢光了容器
    @IBOutlet weak var lootAllContainView: UIView!
    
    var redPacketResultModel:RedPacketResultModel?
    var trendModel:TrendModel?
    var closeBlock:(()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.catchSuccessedUsersTableView.register(UINib.init(nibName: "CatchRedPacketSuccessPersonCell", bundle: nil), forCellReuseIdentifier: "CatchRedPacketSuccessPersonCell")
        self.catchSuccessedUsersTableView.delegate = self
        self.catchSuccessedUsersTableView.dataSource = self
        
        self.headImgV.layer.cornerRadius = 30
        self.headImgV.clipsToBounds = true
        self.noauthHeadImg.cornerRadius = 30
        self.noauthHeadImg.clipsToBounds = true
        self.catchAmount.text = nil
        self.userInfo.text = nil
        
        self.noAuthInfo.layer.cornerRadius = 5
        self.noAuthInfo.clipsToBounds = true
        self.reset()
    }
    
    //MARK: - misc
    @IBAction func dealCatch(_ sender: Any) {
        self.openRedPacket()
    }
    
    @IBAction func dealClose(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    //查看详情
    @IBAction func dealToSeeDetail(_ sender: Any) {
        self.takeRedPacket()
    }
    
    /// 领取红包
    func takeRedPacket(){
        Toast.showStatusWith(text: nil)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let takeRdPacket = GetRedPacked(red_token: self.trendModel?.red_token)
        _ = moyaProvider.rx.request(.targetWith(target: takeRdPacket)).subscribe(onSuccess: { (response) in
            let redPacketResultModel = Mapper<RedPacketResultModel>().map(jsonData: response.data)
            self.showWith(redPacketResultModel: redPacketResultModel)
            Toast.dismiss()
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    
    /// 打开红包
    func openRedPacket(){
        Toast.showStatusWith(text: "正在打开..")
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let openRedPacket = OpenRedPacked(red_token: self.trendModel?.red_token)
        _ = moyaProvider.rx.request(.targetWith(target: openRedPacket)).subscribe(onSuccess: { (response) in
            let redPacketResultModel = Mapper<RedPacketResultModel>().map(jsonData: response.data)
            self.showWith(redPacketResultModel: redPacketResultModel)
            self.trendModel?.red_type = "3"
            NotificationCenter.default.post(name: CATCHED_RED_PACKET_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:self.trendModel])
            Toast.dismiss()
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    
    /// 根据发的 动态 模型里的红包状态判断后续红包操作是直接显示静态界面还是请求数据
    ///
    /// - Parameter trendModel: 动态模型
    func showWith(trendModel:TrendModel?){
        self.trendModel = trendModel
        if let personName = trendModel?.true_name{
            self.userInfo.text = "\(personName)的打赏红包"
            self.noAthuUserInfo.text = "\(personName)的打赏红包"
        }
        if let _url = trendModel?.head_pic{
            self.headImgV.kf.setImage(with: URL.init(string: _url), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
            self.noauthHeadImg.kf.setImage(with: URL.init(string: _url), placeholder: UIImage.init(named: "touxiang"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        if let _redType = trendModel?.red_type{
            let sexStatus = self.checkSex()
            //女性专属
            if _redType == "0"{
                if sexStatus == .female{self.showWith(status: .waitToBeCatch)}
                if sexStatus == .male{self.showWith(status: .forFemale)}
                if sexStatus == .notLogIn{PostLogOutNotificationWith(msg: "登录过后才能领取红包！")}
            }
            //男性专属
            if _redType == "1"{
                if sexStatus == .female{self.showWith(status: .forMale)}
                if sexStatus == .male{self.showWith(status: .waitToBeCatch)}
                if sexStatus == .notLogIn{PostLogOutNotificationWith(msg: "登录过后才能领取红包！")}
            }
            //所有人都可领
            if _redType == "2"{
                if sexStatus == .notLogIn{PostLogOutNotificationWith(msg: "登录过后才能领取红包哦！")}else{
                    self.showWith(status: .waitToBeCatch)
                }
            }
            //已经领过了
            if _redType == "3"{
                //网络请求
                self.takeRedPacket()
            }
            if _redType == "4"{self.showWith(status: .beOverdue)}  //过期
            if _redType == "5"{self.showWith(status: .lootAll)}    //抢光了
        }else{
        }
    }
    
    /// 红包当前显示哪种状态
    ///
    /// - Parameter status: 状态码
    func showWith(status:RedPacketStatus){
        self.reset()
        self.frame = SCREEN_RECT
        UIApplication.shared.keyWindow?.addSubview(self)
        if status == .beOverdue{
            self.noAuthToCatchContainView.isHidden = false
            self.noAuthInfo.isHidden = false
//            self.noauthHeadImg.isHidden = false
//            self.noAthuUserInfo.isHidden = false
            self.noAuthInfo.text = "红包已经过期啦"
            return
        }
        if status == .forMale{
            self.noAuthToCatchContainView.isHidden = false
            self.noAuthInfo.isHidden = false
//            self.noauthHeadImg.isHidden = false
//            self.noAthuUserInfo.isHidden = false
            self.noAuthInfo.text = "男神的红包，腐女走开"
            return
        }
        if status == .forFemale{
            self.noAuthToCatchContainView.isHidden = false
            self.noAuthInfo.isHidden = false
//            self.noauthHeadImg.isHidden = false
//            self.noAthuUserInfo.isHidden = false
            self.noAuthInfo.text = "女神的红包，宅男走开"
            return
        }
        if status == .catchFailed{
            self.redPacketInfoContainView.isHidden = false
            self.redPacketInfoBackgroundImg.isHidden = false
            self.catchFaildContainView.isHidden = false
            self.catchSuccessedUsersTableView.isHidden = false
            return
        }
        if status == .catchSucceed{
            self.redPacketInfoContainView.isHidden = false
            self.redPacketInfoBackgroundImg.isHidden = false
            self.catchSuccessContainView.isHidden = false
            self.catchSuccessedUsersTableView.isHidden = false
            return
        }
        if status == .waitToBeCatch{
            self.openRedPacketContainView.isHidden = false
            self.userInfo.isHidden = false
            self.headImgV.isHidden = false
            return
        }
        if status == .lootAll{
            self.lootAllContainView.isHidden = false
        }
        
    }
    
    
    /// 根据请求的结果显示红包界面
    ///
    /// - Parameter redPacketResultModel: 请求的结果模型
    func showWith(redPacketResultModel:RedPacketResultModel?){
        self.redPacketResultModel = redPacketResultModel
        if 100 == redPacketResultModel?.commonInfoModel?.code{
            self.showWith(status: .forFemale)   //女性专属
            return
        }
        if 101 == redPacketResultModel?.commonInfoModel?.code{
            self.showWith(status: .forMale)   //男性专属
            return
        }
        if 203 == redPacketResultModel?.commonInfoModel?.code{
            self.showWith(status: .catchSucceed)   //已经领过了
            if let _money = redPacketResultModel?.my_self?.money?.decimalValue(){
                self.catchAmount.text = _money
            }
            self.catchSuccessedUsersTableView.reloadData()
            return
        }
        if 202 == redPacketResultModel?.commonInfoModel?.code{
            self.showWith(status: .catchSucceed)   //恭喜获得红包
            if let _money = redPacketResultModel?.my_self?.money?.decimalValue(){
                self.catchAmount.text = _money
            }
            self.catchSuccessedUsersTableView.reloadData()
            return
        }
        if 201 == redPacketResultModel?.commonInfoModel?.code{
            self.showWith(status: .catchFailed)   //红包抢光
            self.catchSuccessedUsersTableView.reloadData()
            return
        }
        if 200 == redPacketResultModel?.commonInfoModel?.code{
            self.showWith(status: .beOverdue)   //红包已经过期
        }else{
            self.showWith(status: .catchSucceed)
            if let _money = redPacketResultModel?.my_self?.money?.decimalValue(){
                self.catchAmount.text = _money
            }
            self.catchSuccessedUsersTableView.reloadData()
        }
    }
    
    func reset(){
        self.redPacketInfoContainView.isHidden = true
        self.redPacketInfoBackgroundImg.isHidden = true
        self.catchFaildContainView.isHidden = true
        self.catchSuccessContainView.isHidden = true
        self.catchSuccessedUsersTableView.isHidden = true
        
        self.openRedPacketContainView.isHidden = true
        self.userInfo.isHidden = true
        self.headImgV.isHidden = true
        
        self.noAuthToCatchContainView.isHidden = true
        self.noauthHeadImg.isHidden = true
        self.noAthuUserInfo.isHidden = true
        self.noAuthInfo.isHidden = true
        
        self.lootAllContainView.isHidden = true
    }
    
    func checkSex()->SexStatus{
        if let _sex = Defaults[.userSex]{
            return _sex == "男" ? .male : .female
        }else{
            return .notLogIn
        }
    }
}

extension CatchRedPacketView:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data_list = self.redPacketResultModel?.data_list{
            return data_list.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatchRedPacketSuccessPersonCell", for: indexPath) as! CatchRedPacketSuccessPersonCell
        if let models = self.redPacketResultModel?.data_list{
            cell.configWith(model: models[indexPath.row])
        }
        return cell
    }
}
