//
//  MusicListController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/7/5.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import ObjectMapper
import Moya

protocol MusicListControllerDelegate :NSObjectProtocol{
    func musicListController(_ musicListController: MusicListController, didSelectModel musicModel: MusicModel, rowIndex: Int?,controllerIndex:Int?)
    func musicListController(_ musicListController: MusicListController, didClickPickMusic musicModel: MusicModel, rowIndex: Int?,controllerIndex:Int?)
    func musicListController(_ musicListController: MusicListController, didClickCutMusic musicModel: MusicModel, rowIndex: Int?,controllerIndex:Int?)
    
    func currentSelectedMusicListControllerIndex()->Int?
    func currentSelectedRowIndex()->Int?
    func selectedMusicStatus()->PlayerStatus?
    func musicKeyWord()->String?
}
class MusicListController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var dataArray = [MusicModel]()
    
    var index:Int? //自身index
    weak var delegate:MusicListControllerDelegate?
    var musicTypeModel:MusicTypeModel?
    var autoLoadData:Bool = false
    var pageIndex:Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "MusicListCell", bundle: nil), forCellReuseIdentifier: "MusicListCell")
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadDataWith(keyWord: self.delegate?.musicKeyWord())
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadDataWith(keyWord: self.delegate?.musicKeyWord())
        }
        if self.autoLoadData{
            self.loadInitialDataWith(keyWord: self.delegate?.musicKeyWord())
        }
        NotificationCenter.default.addObserver(self, selector: #selector(collectSuccessWith(notification:)), name: COLLECT_MUSIC_SUCCESS_NOTIFICATION, object: nil)
    }
    
    @objc func collectSuccessWith(notification:Notification){
        if let musicID = notification.userInfo!["MUSIC_ID"] as? Int,let musicType = notification.userInfo!["MUSIC_TYPE"] as? Int{
            for _musicModel in self.dataArray{
                if _musicModel.music_id == musicID && _musicModel.music_type == musicType{
                    if let _isCollect = _musicModel.is_collect{
                        _musicModel.is_collect = !_isCollect
                    }
                }
            }
        }
        self.tableView.reloadData()
    }

    deinit {
        print("MusicListController\(self.index)销毁")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //
    func loadInitialDataWith(keyWord:String?){
        self.pageIndex = 1
        self.loadDataWith(keyWord: keyWord)
    }
    
    func loadDataWith(keyWord:String?){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let musicList = MusicList.init(page: pageIndex, m_id: self.musicTypeModel?.m_id, type: self.musicTypeModel?.type, name: keyWord)
        
        _ = moyaProvider.rx.request(.targetWith(target: musicList)).subscribe(onSuccess: {[unowned self] (response) in
            let musicListModel = Mapper<MusicListModel>().map(jsonData: response.data)
            if self.pageIndex == 1{self.dataArray.removeAll()}
            if let data = musicListModel?.data{
                for musicModel in data{
                    self.dataArray.append(musicModel)
                }
            }
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            Toast.showErrorWith(model: musicListModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
        })

    }
    
}

extension MusicListController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let musicListCell = tableView.dequeueReusableCell(withIdentifier: "MusicListCell", for: indexPath) as! MusicListCell
        let controllerIndex = self.delegate?.currentSelectedMusicListControllerIndex()
        let rowIndex = self.delegate?.currentSelectedRowIndex()
        let selectedMusicStatus = self.delegate?.selectedMusicStatus()
        
        var isSelected = false
        if controllerIndex == self.index && rowIndex == indexPath.row{
            isSelected = true
        }
        //print("SelectControllerIndex--\(controllerIndex)----SelectRowIndex\(rowIndex)-----isSelected--\(isSelected)")
        let musicModel = self.dataArray[indexPath.row]
        musicListCell.delegate = self
        musicListCell.configWith(model: musicModel, indexPath: indexPath,beSeleted:isSelected,status:selectedMusicStatus)
        return musicListCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let controllerIndex = self.delegate?.currentSelectedMusicListControllerIndex()
        let rowIndex = self.delegate?.currentSelectedRowIndex()
        var height = CGFloat(25+72)
        
        if indexPath.row == rowIndex && controllerIndex == self.index{
            height = height + 14 + 44
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let musicModel = self.dataArray[indexPath.row]
        self.delegate?.musicListController(self, didSelectModel: musicModel, rowIndex: indexPath.row, controllerIndex: self.index)
        //print("点击了ControllerIndex-----\(self.index)----RowIndex:\(indexPath.row)")
    }
}

extension MusicListController:MusicListCellDelegate{
    func musicListCell(_ musicListCell:MusicListCell,indexPath:IndexPath,clickedPickMusicButton pickMusicButton:UIButton){
        let musicModel = self.dataArray[indexPath.row]
        self.delegate?.musicListController(self, didClickPickMusic: musicModel, rowIndex: indexPath.row, controllerIndex: self.index)
    }
    
    func musicListCell(_ musicListCell:MusicListCell,indexPath:IndexPath,clickedCutButton cutButton:UIButton){
        let musicModel = self.dataArray[indexPath.row]
        self.delegate?.musicListController(self, didClickCutMusic: musicModel, rowIndex: indexPath.row, controllerIndex: self.index)
    }
    
    func musicListCell(_ musicListCell:MusicListCell,indexPath:IndexPath,clickedCollectButton collectButton:UIButton){
        let musicModel = self.dataArray[indexPath.row]
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let musicCollect = MusicCollect.init(music_id: musicModel.music_id, music_type: musicModel.music_type)
        
        _ = moyaProvider.rx.request(.targetWith(target: musicCollect)).subscribe(onSuccess: {[unowned self] (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
                NotificationCenter.default.post(name: COLLECT_MUSIC_SUCCESS_NOTIFICATION, object: nil, userInfo: ["MUSIC_ID":musicModel.music_id,"MUSIC_TYPE":musicModel.music_type])
            }
            Toast.showErrorWith(model: baseModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    func musicListCell(_ musicListCell:MusicListCell,indexPath:IndexPath,clickedRankButton rankButton:UIButton){
        
    }
}
