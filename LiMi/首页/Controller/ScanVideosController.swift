//
//  ScanVideosController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/6/4.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import DZNEmptyDataSet

protocol ScanVideosControllerDelegate {
//    func scanVideosControllervarCurrentSelectedVideoWith(model:VideoTrendModel)
    
    /*变量*/
    var pageIndex:Int{get set}
    var dataArray:[VideoTrendModel]{get set}
    var time:Int?{get set}
    var currentVideoTrendIndex:Int{get set}
    
    /*函数*/
    func scanVideosControllerRequestDataWith(scanVideosController:ScanVideosController)
}

class ScanVideosController: ViewController {
    var collectionView:UICollectionView!
    var delegate:ScanVideosControllerDelegate!
    var playVideoCertificateModel:UploadVideoCertificateModel?
    var videoCommentListNavController:NavigationController?
    var isNavigationBarHidden:Bool = true
    
    var isFirstIn = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let layOut = UICollectionViewFlowLayout.init()
        layOut.itemSize = SCREEN_RECT.size
        self.collectionView = UICollectionView.init(frame: SCREEN_RECT, collectionViewLayout: layOut)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(UINib.init(nibName: "VideoPlayCell", bundle: nil), forCellWithReuseIdentifier: "VideoPlayCell")
        self.collectionView.isPagingEnabled = true
        self.view.addSubview(self.collectionView)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.mj_header = mjGifHeaderWith {[unowned self] in
            self.delegate.pageIndex = 1
            self.delegate.scanVideosControllerRequestDataWith(scanVideosController: self)
        }
        
        self.collectionView.mj_footer = mjGifFooterWith {[unowned self] in
            self.delegate.pageIndex += 1
            self.delegate.scanVideosControllerRequestDataWith(scanVideosController: self)
        }
        
        if self.delegate.dataArray.count > self.delegate.currentVideoTrendIndex{
            self.reloadCollectionData()
        }else{
            self.delegate.scanVideosControllerRequestDataWith(scanVideosController: self)
        }
        
        self.requestCertificationWith { (model) in
        }
        
        //离开播放页
        NotificationCenter.default.addObserver(self, selector: #selector(leave), name: LEAVE_PLAY_PAGE_NOTIFICATION, object: nil)
        //进入播放页
        NotificationCenter.default.addObserver(self, selector: #selector(into), name: INTO_PLAY_PAGE_NOTIFICATION, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = (self.navigationController?.navigationBar.isHidden)!
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = self.isNavigationBarHidden
        NotificationCenter.default.post(name: LEAVE_PLAY_PAGE_NOTIFICATION, object: nil)
    }
    
    //互相校验
    func requestCertificationWith(completeBlock:((UploadVideoCertificateModel)->Void)?){
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let shortVideoCreateUploadCertificate = ShortVideoCreateUploadCertificate.init(type: "play")
        _ = moyaProvider.rx.request(.targetWith(target: shortVideoCreateUploadCertificate)).subscribe(onSuccess: { (response) in
            let playVideoCertificateModel = Mapper<UploadVideoCertificateModel>().map(jsonData: response.data)
            if playVideoCertificateModel?.commonInfoModel?.status == successState{
                self.playVideoCertificateModel = playVideoCertificateModel
                self.reloadCollectionData()
                if let _block = completeBlock{
                    _block(playVideoCertificateModel!)
                }
            }else{
                Toast.showErrorWith(model: playVideoCertificateModel)
            }
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    //刷新数据
    func reloadCollectionData(){
        if self.playVideoCertificateModel == nil{return}
        self.collectionView.reloadData()
        let indexPath = IndexPath.init(row: self.delegate.currentVideoTrendIndex, section: 0)
        if self.delegate.dataArray.count <= indexPath.row{return}
        //self.collectionView.layoutIfNeeded()//这个必须先执行，否则没效果
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        var offset = self.collectionView.contentOffset
        offset.y = offset.y + 100
        self.collectionView.setContentOffset(offset, animated: true)
        self.collectionView.setContentOffset(CGPoint.init(x: 0, y: SCREEN_HEIGHT*CGFloat(indexPath.row)), animated: false)
    }
    
//    func playWith(videoPlayCell:VideoPlayCell){
//        videoPlayCell
//    }
//    func playWith(index:Int){
//        if let videoPlayCell
//        self.delegate.currentVideoTrendIndex = index
//        cell.play()
//    }
}

extension ScanVideosController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.delegate.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let videoPlayCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayCell", for: indexPath) as! VideoPlayCell
        videoPlayCell.delegate = self
        let videoModel = self.delegate.dataArray[indexPath.row]
        videoPlayCell.configWith(videoTrendModel: videoModel, playCertificateModel: self.playVideoCertificateModel)
        if indexPath.row == self.delegate.currentVideoTrendIndex{
            if isFirstIn{
                isFirstIn = false
                videoPlayCell.play()
            }
        }
        return videoPlayCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SCREEN_RECT.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.y/scrollView.frame.size.height)
        if self.delegate.dataArray.count <= index{return}
        let videoTrendModel = self.delegate.dataArray[index]
        if let currentCell = self.collectionView.cellForItem(at: IndexPath.init(row: index, section: 0)) as? VideoPlayCell{
            self.stopCollectionViewAllPlayCellsExcept(videoTrendModel: videoTrendModel)
            self.delegate.currentVideoTrendIndex = index
            currentCell.play()
        }
    }
    
    func stopCollectionViewAllPlayCellsExcept(videoTrendModel:VideoTrendModel){
        for subView in self.collectionView.subviews{
            if let videoPlayCell  = subView as? VideoPlayCell{
                if videoPlayCell.videoTrendModel?.id != videoTrendModel.id{
                    videoPlayCell.stop()
                }
            }
        }
    }
    
    func stopCollectionViewAllPlayCells(){
        for subView in self.collectionView.subviews{
            if let videoPlayCell  = subView as? VideoPlayCell{
                videoPlayCell.stop()
            }
        }
    }
}

extension ScanVideosController:VideoPlayCellDelegate{
    func videoPlayCellUserHeadButtonClicked(button:UIButton){
        let currentVideoTrendIndex = self.delegate.currentVideoTrendIndex
        let videoModel = self.delegate.dataArray[currentVideoTrendIndex]
        let userDetailsController = UserDetailsController()
        userDetailsController.userId = videoModel.user_id!
        self.navigationController?.pushViewController(userDetailsController, animated: true)
    }
    func videoPlayCellAddFollowButtonClicked(button:UIButton){
        if !AppManager.shared.checkUserStatus(){return}
        let currentVideoTrendIndex = self.delegate.currentVideoTrendIndex
        let videoModel = self.delegate.dataArray[currentVideoTrendIndex]
        
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        let addAttention = AddAttention.init(attention_id: videoModel.user_id)
        _ = moyaProvider.rx.request(.targetWith(target: addAttention)).subscribe(onSuccess: {[unowned self] (response) in
            let personCenterModel = Mapper<PersonCenterModel>().map(jsonData: response.data)
            if personCenterModel?.commonInfoModel?.status == successState{
                videoModel.is_attention = !videoModel.is_attention!
                NotificationCenter.default.post(name: ADD_ATTENTION_SUCCESSED_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:videoModel])
            }
            Toast.showErrorWith(model: personCenterModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    func videoPlayCellThumbsUpButtonClicked(button:UIButton){
        //let VideoClickAction
        if !AppManager.shared.checkUserStatus(){return}
        let currentVideoTrendIndex = self.delegate.currentVideoTrendIndex
        let videoModel = self.delegate.dataArray[currentVideoTrendIndex]
        let videoClickAciton = VideoClickAction.init(video_id: videoModel.id)
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: videoClickAciton)).subscribe(onSuccess: { (response) in
            let resultModel = Mapper<BaseModel>().map(jsonData: response.data)
            if resultModel?.commonInfoModel?.status == successState{
                videoModel.is_click = !videoModel.is_click!
                if videoModel.is_click!{
                    videoModel.click_num = videoModel.click_num! + 1
                }else{
                    videoModel.click_num = videoModel.click_num! - 1
                }
                NotificationCenter.default.post(name: THUMBS_UP_NOTIFICATION, object: nil, userInfo: [TREND_MODEL_KEY:videoModel])
            }
            Toast.showErrorWith(model: resultModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    func videoPlayCellCommentButtonClicked(button:UIButton){
        let videoCommentListController = VideoCommentListController()
        videoCommentListController.view.frame = SCREEN_RECT
        let currentVideoTrendIndex = self.delegate.currentVideoTrendIndex
        videoCommentListController.videoTrendModel = self.delegate.dataArray[currentVideoTrendIndex]
        videoCommentListController.loadData()
        self.videoCommentListNavController = NavigationController.init(rootViewController: videoCommentListController)
        self.videoCommentListNavController?.navigationBar.isHidden = true
        self.videoCommentListNavController?.view.backgroundColor = UIColor.clear
        self.definesPresentationContext = true
        self.videoCommentListNavController?.modalPresentationStyle = .overFullScreen
        self.present(self.videoCommentListNavController!, animated: true, completion: nil)
    }
    func videoPlayCellMoreOperationButtonClicked(button:UIButton){
        let moreOperationController = MoreOperationController()
        moreOperationController.statusBarHidden = true
        moreOperationController.delegate = self
        moreOperationController.modalPresentationStyle = .overFullScreen
        self.definesPresentationContext = true
        self.present(moreOperationController, animated: true, completion: nil)
    }
}

extension ScanVideosController{
    @objc func leave(){
        print("离开停止")
        self.stopCollectionViewAllPlayCells()
    }
    
    @objc func into(){
        print("进入播放")
        let indexPath = IndexPath.init(row: self.delegate.currentVideoTrendIndex, section: 0)
        if let videoPlayCell = self.collectionView.cellForItem(at: indexPath) as? VideoPlayCell{
            videoPlayCell.play()
        }
    }
}

extension ScanVideosController:MoreOperationControllerDelegate{
    func moreOperationReportClicked(){
        self.doMoreOperationWith(type: "report")
    }
    func moreOperationBlackClicked(){
        self.doMoreOperationWith(type: "black")

    }
    func moreOperationDeleteClicked(){
        self.doMoreOperationWith(type: "delete")

    }
    
    func doMoreOperationWith(type:String){
        if !AppManager.shared.checkUserStatus(){return}
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        var body:TargetType!
        //report black delete
        let currentVideoTrendIndex = self.delegate.currentVideoTrendIndex
        let videoTrendModel = self.delegate.dataArray[currentVideoTrendIndex]
        if type == "report"{
            body = VideoMultiFunction(type: type, video_id: videoTrendModel.id, user_id: videoTrendModel.user_id)
        }
        if type == "black"{
            body = VideoMultiFunction(type: type, video_id: videoTrendModel.id, user_id: videoTrendModel.user_id)
        }
        if type == "delete"{
            body = VideoMultiFunction(type: type, video_id: videoTrendModel.id, user_id: videoTrendModel.user_id)
        }
        _ = moyaProvider.rx.request(.targetWith(target: body)).subscribe(onSuccess: { (response) in
            let baseModel = Mapper<BaseModel>().map(jsonData: response.data)
            if baseModel?.commonInfoModel?.status == successState{
//                var moreOperationModel = MoreOperationModel()
//                moreOperationModel.operationType = operationType
//                moreOperationModel.action_id = trendModel?.action_id
//                moreOperationModel.user_id = trendModel?.user_id
//                NotificationCenter.default.post(name: DID_TOPIC_MORE_OPERATION, object: nil, userInfo: [MORE_OPERATION_KEY:moreOperationModel])
            }
            Toast.showResultWith(model: baseModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }

}
