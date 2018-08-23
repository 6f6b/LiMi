//
//  PurposeScreeningController.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/8/21.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

class PurposeScreeningController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ageRangeLabel: UILabel!
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var rangeSliderContainView: UIView!
    
    @IBOutlet weak var girlButton: UIButton!
    @IBOutlet weak var boyButton: UIButton!
    @IBOutlet weak var notLimitButton: UIButton!
    @IBOutlet weak var purposeContainView: UIView!
    
    var nearbyPurposeListView:NearbyPurposeListView?
    var customSlider:JLSliderView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.distanceSlider.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
        self.distanceSlider.setThumbImage(UIImage.init(named: "fjr_ic_yuandian"), for: .normal)
        self.distanceSlider.setMinimumTrackImage(UIImage.init(named: "fjr_pic_bai"), for: .normal)
        self.distanceSlider.setMaximumTrackImage(UIImage.init(named: "fjr_pic_hei"), for: .normal)
        self.distanceSlider.addTarget(self, action: #selector(distanceSliderValueChangedWith(slider:)), for: .valueChanged)
        
        self.customSlider = JLSliderView.init(frame: CGRect.init(x: 20, y: 28, width: SCREEN_WIDTH-40, height: 22))
        self.customSlider.minValue = 18;
        self.customSlider.maxValue = 48;
        self.customSlider.thumbColor = UIColor.white;
        self.customSlider.sliderType = .center;
        self.customSlider.delegate = self;
        self.rangeSliderContainView.addSubview(self.customSlider)
        
        self.loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.nearbyPurposeListView != nil {return }
        self.nearbyPurposeListView = NearbyPurposeListView.init(frame: self.purposeContainView.bounds, maxSelectedNum: 1)
        self.nearbyPurposeListView?.delegate = self
        self.purposeContainView.addSubview(self.nearbyPurposeListView!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadData(){
        let getUpdateUserInfo = GetUpdateUserInfo.init()
        let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
        _ = moyaProvider.rx.request(.targetWith(target: getUpdateUserInfo)).subscribe(onSuccess: { (response) in
            let screeningFiltersModel = Mapper<ScreeningFiltersModel>().map(jsonData: response.data)
            self.refreshUIWith(model: screeningFiltersModel)

            Toast.showErrorWith(model: screeningFiltersModel)
        }, onError: { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        })
    }
    
    func refreshUIWith(model:ScreeningFiltersModel?){
        if let purposes = model?.target_list{
            self.nearbyPurposeListView?.reloadDataWith(models: purposes)
        }
        if model?.target_sex == 0{
            self.girlButton.isSelected = true
            self.girlButton.backgroundColor = APP_THEME_COLOR_3
        }
        if model?.target_sex == 1{
            self.boyButton.isSelected = true
            self.boyButton.backgroundColor = APP_THEME_COLOR_3
        }
        if model?.target_sex == 2{
            self.notLimitButton.isSelected = true
            self.notLimitButton.backgroundColor = APP_THEME_COLOR_3
        }
        if let _distance = model?.target_distance{
            self.distanceLabel.text = "\(_distance)KM"
            self.distanceSlider.value = Float(_distance)
        }
        if let _target_age = model?.target_age{
            let ages = NSString.init(string: _target_age).components(separatedBy: ",")
            if let _min = ages.first,let _max = ages.last{
                self.ageRangeLabel.text = "\(_min)-\(_max)"
                self.customSlider.setCurrentMinValue(UInt(_min.intValue()), currentMaxValue: UInt(_max.intValue()))
//                self.customSlider.currentMinValue = UInt(_min.intValue())
//                self.customSlider.currentMaxValue = UInt(_max.intValue())
            }
        }
    }
    
    @objc func distanceSliderValueChangedWith(slider:UISlider){
        self.distanceLabel.text = "\(String.init(format: "%.1f", slider.value))KM"
    }
    
    @IBAction func dealCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dealSave(_ sender: Any) {
        LocationManager.shared.startLocateWith(success: { (location) in
            let moyaProvider = MoyaProvider<LiMiAPI>(manager: DefaultAlamofireManager.sharedManager)
            let latitude = location?.coordinate.latitude as? Double
            let longitude = location?.coordinate.longitude as? Double
            let purposes = self.nearbyPurposeListView?.clickedItemWith(clickedModel: nil)
            let age = "\( self.customSlider.currentMinValue),\( self.customSlider.currentMaxValue)"
            var sex = 0
            if self.girlButton.isSelected{
                sex = 0
            }else if self.boyButton.isSelected{
                sex = 1
            }else if self.notLimitButton.isSelected{
                sex = 2
            }else{
                Toast.showInfoWith(text: "请选择性别")
                return
            }
            
            let purpose = self.nearbyPurposeListView?.clickedItemWith(clickedModel: nil)
            let purposeValue = purpose?.intValue() == 0 ? nil : purpose?.intValue()
            let updateUserInfo = UpdateUserInfo.init(lat: latitude, lng: longitude, target_age: age, target_distance: Int(self.distanceSlider.value), target_sex: sex, target_target: purposeValue)
            _ = moyaProvider.rx.request(.targetWith(target: updateUserInfo)).subscribe(onSuccess: { (response) in
                let peopleNearbyContainModel = Mapper<PeopleNearbyContainModel>().map(jsonData: response.data)
                if peopleNearbyContainModel?.commonInfoModel?.status == successState{
                    self.dismiss(animated: true, completion: nil)
                }
                Toast.showErrorWith(model: peopleNearbyContainModel)
            }, onError: { (error) in
                Toast.showErrorWith(msg: error.localizedDescription)
            })
        }) { (error) in
            Toast.showErrorWith(msg: error.localizedDescription)
        }

    }

    @IBAction func clickedGirl(_ sender: Any) {
        self.girlButton.isSelected = true
        self.boyButton.isSelected = false
        self.notLimitButton.isSelected = false
        self.girlButton.backgroundColor = APP_THEME_COLOR_3
        self.boyButton.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
        self.notLimitButton.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
    }
    
    @IBAction func clickedBoy(_ sender: Any) {
        self.girlButton.isSelected = false
        self.boyButton.isSelected = true
        self.notLimitButton.isSelected = false
        self.girlButton.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
        self.boyButton.backgroundColor = APP_THEME_COLOR_3
        self.notLimitButton.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
    }
    
    @IBAction func clickedNotLimit(_ sender: Any) {
        self.girlButton.isSelected = false
        self.boyButton.isSelected = false
        self.notLimitButton.isSelected = true
        self.girlButton.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
        self.boyButton.backgroundColor = RGBA(r: 53, g: 53, b: 53, a: 1)
        self.notLimitButton.backgroundColor = APP_THEME_COLOR_3
    }
}

extension PurposeScreeningController : JLSliderViewDelegate{
    func sliderViewDidSliderLeft(_ leftValue: UInt, right rightValue: UInt) {
        self.ageRangeLabel.text = "\(leftValue)-\(rightValue)"
    }
}

extension PurposeScreeningController : NearbyPurposeListViewDelegate{
    func nearbyPurposeListView(view: NearbyPurposeListView, selectedWith purposes: String) -> Bool {
        return true
    }
}
