//
//  ReleaseTypeController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/15.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import UIKit

class ReleaseTypeController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        self.navigationController?.navigationBar.isHidden = true
        self.setupSDKUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //MARK: - misc
    func setupSDKUI(){
        let config = AliyunIConfig.init()
        config.backgroundColor = UIColor.init(red: 30, green: 30, blue: 30, alpha: 1)
        config.timelineBackgroundCollor = RGBA(r: 127, g: 110, b: 241, a: 1);
        config.timelineDeleteColor = UIColor.orange
        config.timelineTintColor = UIColor.brown
        config.durationLabelTextColor = UIColor.red
        config.hiddenDurationLabel = false
        config.hiddenFlashButton = false
        config.hiddenBeautyButton = false
        config.hiddenCameraButton = false
        config.hiddenImportButton = false
        config.hiddenDeleteButton = false
        config.hiddenFinishButton = true
        config.recordOnePart = false
        config.filterArray = ["filter/炽黄","filter/粉桃","filter/海蓝","filter/红润","filter/灰白","filter/经典","filter/麦茶","filter/浓烈","filter/柔柔","filter/闪耀","filter/鲜果","filter/雪梨","filter/阳光","filter/优雅","filter/朝阳","filter/波普","filter/光圈","filter/海盐","filter/黑白","filter/胶片","filter/焦黄","filter/蓝调","filter/迷糊","filter/思念","filter/素描","filter/鱼眼","filter/马赛克","filter/模糊"]
        config.imageBundleName = "QPSDK";
        config.recordType = .combination;
        config.filterBundleName = "FilterResource";
        config.showCameraButton = true;
        AliyunIConfig.setConfig(config)
    }
    @IBAction func dealChoosePicture(_ sender: Any) {
    }
    
    @IBAction func dealChooseVideo(_ sender: Any) {
        let mediaContainController  = MediaContainController()
        
//        let recordViewController = AliyunMediator.shared().recordViewController() as? AliyunRecordViewController
//        let quVideo = AliyunMediaConfig.init()
//        quVideo.outputSize = SCREEN_RECT.size
//        quVideo.minDuration = 2
//        quVideo.maxDuration = 30
//
//        recordViewController?.delegate = self
//        recordViewController?.quVideo = quVideo
        self.navigationController?.pushViewController(mediaContainController, animated: true)
    }
    
    @IBAction func dealCancel(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

