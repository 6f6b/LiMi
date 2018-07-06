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

protocol MusicListControllerDelegate {
    func musicListController(_ musicListController: MusicListController, didSelectModel musicModel: MusicModel, rowIndex: Int?,controllerIndex:Int?)
    func currentSelectedMusicListControllerIndex()->Int?
    func currentSelectedRowIndex()->Int?
    func selectedMusicStatus()->PlayerStatus?
    
    func musicListController(_ musicListController: MusicListController, didClickPickMusic musicModel: MusicModel, rowIndex: Int?,controllerIndex:Int?)
    func musicListController(_ musicListController: MusicListController, didClickCutMusic musicModel: MusicModel, rowIndex: Int?,controllerIndex:Int?)

}
class MusicListController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var dataArray = [MusicModel]()
    
    var index:Int? //自身index
    var delegate:MusicListControllerDelegate?
    var musicTypeModel:MusicTypeModel?
    var autoLoadData:Bool = false
    var pageIndex:Int = 1
    var keyWord:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "MusicListCell", bundle: nil), forCellReuseIdentifier: "MusicListCell")
        self.tableView.mj_header = mjGifHeaderWith {[unowned self] in
            self.pageIndex = 1
            self.loadDataWith(keyWord: self.keyWord)
        }
        
        self.tableView.mj_footer = mjGifFooterWith {[unowned self] in
            self.pageIndex += 1
            self.loadDataWith(keyWord: self.keyWord)
        }
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
        if self.pageIndex == 1{self.dataArray.removeAll()}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let musicList = MusicList.init(page: pageIndex, m_id: self.musicTypeModel?.m_id, type: self.musicTypeModel?.type, name: keyWord)
        
        _ = moyaProvider.rx.request(.targetWith(target: musicList)).subscribe(onSuccess: {[unowned self] (response) in
            let musicListModel = Mapper<MusicListModel>().map(jsonData: response.data)
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
        
    }
    func musicListCell(_ musicListCell:MusicListCell,indexPath:IndexPath,clickedRankButton rankButton:UIButton){
        
    }
}
