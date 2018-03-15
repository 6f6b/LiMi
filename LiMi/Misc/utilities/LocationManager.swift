//
//  LocationManager.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/2/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

import Foundation
import CoreLocation
import SVProgressHUD

class LocationManager :NSObject{
    static let shared = LocationManager()
    ///位置信息
    var location:CLLocation?
    var locationManager = CLLocationManager()
    var successBlock:((CLLocation?)->Void)?
    var faildBlock:((Error)->Void)?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    func startLocateWith(success:((CLLocation?)->Void)?,failed:((Error)->Void)?){
        self.successBlock = success
        self.faildBlock = failed
        if CLLocationManager.locationServicesEnabled(){
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 5.0
            locationManager.startUpdatingLocation()
        }else{
            Toast.showInfoWith(text: "请开启定位权限")
        }
    }
    
    
}

extension LocationManager:CLLocationManagerDelegate{
    //定位失败
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let _faildBlock = self.faildBlock{
            _faildBlock(error)
        }
    }
    //定位成功
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        self.location = locations.last
        if let _successBlock = self.successBlock{
            _successBlock(self.location)
        }
    }
}
