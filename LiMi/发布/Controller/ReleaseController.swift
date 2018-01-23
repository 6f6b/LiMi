//
//  ReleaseController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/1/19.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit
import TZImagePickerController

class ReleaseController: ViewController {
    var releaseBtn:UIButton!
    var tableView:UITableView!
    var releaseContentTextInputCell:ReleaseContentTextInputCell!
    var releaseContentImgInputCell:ReleaseContentImgInputCell!
    var releaseContentTagInputCell:ReleaseContentOtherInputCell!
    var releaseContentRedBagInputCell:ReleaseContentOtherInputCell!
    var imgArr = [UIImage]()
    var imagePickerVc:TZImagePickerController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新动态"
        let navigationBarTitleAttributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = navigationBarTitleAttributes
        
        let cancelBtn = UIButton.init(type: .custom)
        let cancelAttributeTitle = NSAttributedString.init(string: "取消", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)])
        cancelBtn.setAttributedTitle(cancelAttributeTitle, for: .normal)
        cancelBtn.sizeToFit()
        cancelBtn.addTarget(self, action: #selector(dealCancel), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: cancelBtn)
        
        
        let releaseBtn = UIButton.init(type: .custom)
        releaseBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 25)
        self.releaseBtn = releaseBtn
        self.makeReleaseBtn(isEnable: false)
        releaseBtn.addTarget(self, action: #selector(dealRelease), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: releaseBtn)
        
        self.tableView = UITableView(frame: self.view.bounds)
        self.view.addSubview(self.tableView)
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.releaseContentTextInputCell = GET_XIB_VIEW(nibName: "ReleaseContentTextInputCell") as! ReleaseContentTextInputCell
        self.releaseContentImgInputCell = ReleaseContentImgInputCell()
        self.releaseContentImgInputCell.addImgBlock = {
            self.imagePickerVc = TZImagePickerController.init(maxImagesCount: 9-self.imgArr.count, delegate: self)
            self.imagePickerVc?.didFinishPickingPhotosHandle = {(photos,assets,isOriginal) in
                if let _imgs = photos{
                    for img in _imgs{
                        self.imgArr.append(img)
                    }
                }
                self.tableView.reloadData()
            }
            self.present(self.imagePickerVc!, animated: true, completion: nil)
        }
        self.releaseContentImgInputCell.deleteImgBlock = {(index) in
            self.imgArr.remove(at: index)
            self.tableView.reloadData()
        }
        self.releaseContentTagInputCell = GET_XIB_VIEW(nibName: "ReleaseContentOtherInputCell") as! ReleaseContentOtherInputCell
        self.releaseContentTagInputCell.leftLabel.text = "添加标签"
        self.releaseContentTagInputCell.leftImgV.image = UIImage.init(named: "fb_icon_bq")
        self.releaseContentTagInputCell.rightLabel.text = nil
        self.releaseContentRedBagInputCell = GET_XIB_VIEW(nibName: "ReleaseContentOtherInputCell") as! ReleaseContentOtherInputCell
        self.releaseContentRedBagInputCell.leftLabel.text = "打赏红包"
        self.releaseContentRedBagInputCell.leftImgV.image = UIImage.init(named: "fb_icon_hb")
        self.releaseContentRedBagInputCell.rightLabel.text = nil
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        super.viewWillDisappear(animated)
    }

    //MARK: - misc
    func makeReleaseBtn(isEnable:Bool){
        if isEnable{
            releaseBtn.backgroundColor = UIColor.white
            let releaseBtnAttributeTitle = NSAttributedString.init(string: "发送", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 51, g: 51, b: 51, a: 1)])
            releaseBtn.setAttributedTitle(releaseBtnAttributeTitle, for: .normal)
        }
        if !isEnable{
            releaseBtn.backgroundColor = RGBA(r: 240, g: 240, b: 240, a: 1)
            let releaseBtnAttributeTitle = NSAttributedString.init(string: "发送", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:RGBA(r: 184, g: 184, b: 184, a: 1)])
            releaseBtn.setAttributedTitle(releaseBtnAttributeTitle, for: .normal)
        }
        releaseBtn.isUserInteractionEnabled = isEnable
    }
    
    @objc func dealCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dealRelease(){
        
    }
    
}

//MARK: - UITableViewDelegate、UITableViewDataSource
extension ReleaseController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{return 7}
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                return self.releaseContentTextInputCell
            }
            if indexPath.row == 1{
                self.releaseContentImgInputCell.configWith(imgArry: self.imgArr)
                return self.releaseContentImgInputCell
            }
        }
        if indexPath.section == 1{
            if indexPath.row == 0{
                return self.releaseContentTagInputCell
            }
            if indexPath.row == 1{
                return self.releaseContentRedBagInputCell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1{
            if indexPath.row == 0{
                let tagListView = TagListView(frame: SCREEN_RECT)
                UIApplication.shared.keyWindow?.addSubview(tagListView)
            }
            if indexPath.row == 1{
                let rewardRedPacketController = RewardRedPacketController()
                self.navigationController?.pushViewController(rewardRedPacketController, animated: true)
            }
        }
    }
}

extension ReleaseController:TZImagePickerControllerDelegate{
    
}
