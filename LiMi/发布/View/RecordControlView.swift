//
//  RecordControlView.swift
//  LiMi
//
//  Created by dev.liufeng on 2018/5/16.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol RecordControlViewDelegate {
    
    /// 点击返回按钮
    func recordControlViewTap(backBtn:UIButton!)
    ///切换摄像头
    func recordControlViewTap(cameraDirectionBtn:UIButton!)
    /// 切换闪光灯
    func recordControlViewTap(torchModelBtn:UIButton!)
    ///下一步
    func recordControlViewTap(nextStepBtn:UIButton!)
    ///倒计时
    func recordControlViewTap(countDownBtn:UIButton!)
    ///美颜
    func recordControlViewTap(fairBtn:UIButton!)
    ///音乐
    func recordControlViewTap(musicBtn:UIButton!)
    ///变速
    func recordControlViewTap(shiftBtn:UIButton!)
    ///魔法
    func recordControlViewTap(magicBtn:UIButton!)
    ///点击拍摄
    func recordControlViewTap(shotBtn:UIButton!)
    ///回删
    func recordControlViewTap(backDeleteBtn:UIButton!)

}

enum RecordControlViewState {
    case inDefault
    case inShot
    case inPause
}

class RecordControlView: UIView {
    var delegate:RecordControlViewDelegate?
    var aliyunRecorder:AliyunIRecorder!
    private var state:RecordControlViewState = .inDefault
    
    /*各功能按钮对应参数*/
    //摄像头方向
    
    /*控制面板功能按钮*/
    //进度条
    var progressView:VideoProgressView?
    //返回按钮
    var backBtn:UIButton!
    //切换摄像头
    var cameraDirectionBtn:UIButton!
    //闪光灯
    var torchModelBtn:UIButton!
    //下一步
    var nextStepBtn:UIButton!
    
    //倒计时
    var countDownBtn:UIButton!
    //美颜
    var fairBtn:UIButton!
    //音乐
    var musicBtn:UIButton!
    //变速
    var shiftBtn:UIButton!
    
    //魔法
    var magicBtn:UIButton!
    //拍摄/暂停按钮
    var shotBtn:UIButton!
    //回删
    var backDeleteBtn:UIButton!
    
    //拍摄/相册切换
    
    convenience init(delegate:RecordControlViewDelegate?,recorder:AliyunIRecorder!) {
        self.init(frame: SCREEN_RECT)
        self.delegate = delegate
        self.aliyunRecorder = recorder
        recorder.delegate = self
        self.controlsInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.backBtn = UIButton.init()
        self.backBtn.addTarget(self, action: #selector(dealTap(backBtn:)), for: .touchUpInside)
        self.backBtn.setImage(UIImage.init(named: "short_video_back"), for: .normal)
        self.addSubview(self.backBtn)
        self.backBtn.snp.makeConstraints {[unowned self] (make) in
            make.left.equalTo(self).offset(15)
            make.top.equalTo(self).offset(25)
        }
        
        self.nextStepBtn = UIButton.init()
        self.nextStepBtn.addTarget(self, action: #selector(dealTap(nextStepBtn:)), for: .touchUpInside)
        self.nextStepBtn.layer.cornerRadius = 4
        self.nextStepBtn.clipsToBounds = true
        self.nextStepBtn.setTitle("下一步", for: .normal)
        self.nextStepBtn.backgroundColor = RGBA(r: 186, g: 175, b: 254, a: 1)
        self.addSubview(self.nextStepBtn)
        self.nextStepBtn.snp.makeConstraints {[unowned self] (make) in
            make.height.equalTo(25)
            make.width.equalTo(64)
            make.centerY.equalTo(self.backBtn)
            make.right.equalTo(self).offset(-15)
        }
        
        self.torchModelBtn = UIButton()
        self.torchModelBtn.addTarget(self, action: #selector(dealTap(torchModelBtn:)), for: .touchUpInside)
        self.torchModelBtn.setImage(UIImage.init(named: "sgd_close"), for: .normal)
        self.torchModelBtn.setImage(UIImage.init(named: "sgd_open"), for: .selected)
        self.addSubview(self.torchModelBtn)
        self.torchModelBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.backBtn)
            make.right.equalTo(self.nextStepBtn.snp.left).offset(-60)
        }

        self.cameraDirectionBtn = UIButton.init()
        self.cameraDirectionBtn.addTarget(self, action: #selector(dealTap(cameraDirectionBtn:)), for: .touchUpInside)
        self.cameraDirectionBtn.setImage(UIImage.init(named: "qhsxt"), for: .normal)
        self.addSubview(self.cameraDirectionBtn)
        self.cameraDirectionBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.backBtn)
            make.right.equalTo(self.torchModelBtn.snp.left).offset(-41)
        }
        
        self.countDownBtn = UIButton()
        self.countDownBtn.addTarget(self, action: #selector(dealTap(countDownBtn:)), for: .touchUpInside)
        self.countDownBtn.setImage(UIImage.init(named: "time"), for: .normal)
        self.countDownBtn.setTitle("倒计时", for: .normal)
        self.countDownBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.countDownBtn.setContentInCenter()
        self.addSubview(self.countDownBtn)
        self.countDownBtn.snp.makeConstraints {[unowned self] (make) in
            make.right.equalTo(self).offset(-20)
            make.top.equalTo(self.nextStepBtn.snp.bottom).offset(38)
        }
        
        self.fairBtn = UIButton()
        self.fairBtn.addTarget(self, action: #selector(dealTap(fairBtn:)), for: .touchUpInside)
        self.fairBtn.setImage(UIImage.init(named: "meiyan"), for: .normal)
        self.fairBtn.setTitle("美颜", for: .normal)
        self.fairBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.fairBtn.setContentInCenter()
        self.addSubview(self.fairBtn)
        self.fairBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerX.equalTo(self.countDownBtn)
            make.top.equalTo(self.countDownBtn.snp.bottom).offset(22)
        }
        
        self.musicBtn = UIButton()
        self.musicBtn.addTarget(self, action: #selector(dealTap(musicBtn:)), for: .touchUpInside)
        self.musicBtn.setImage(UIImage.init(named: "music"), for: .normal)
        self.musicBtn.setTitle("音乐", for: .normal)
        self.musicBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.musicBtn.setContentInCenter()
        self.addSubview(self.musicBtn)
        self.musicBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerX.equalTo(self.fairBtn)
            make.top.equalTo(self.fairBtn.snp.bottom).offset(22)
        }
        
        self.shiftBtn = UIButton()
        self.shiftBtn.addTarget(self, action: #selector(dealTap(shiftBtn:)), for: .touchUpInside)
        self.shiftBtn.setImage(UIImage.init(named: "biansu"), for: .normal)
        self.shiftBtn.setTitle("变速", for: .normal)
        self.shiftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.shiftBtn.setContentInCenter()
        self.addSubview(self.shiftBtn)
        self.shiftBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerX.equalTo(self.musicBtn)
            make.top.equalTo(self.musicBtn.snp.bottom).offset(22)
        }
        
        self.shotBtn = UIButton()
        self.shotBtn.addTarget(self, action: #selector(dealTap(shotBtn:)), for: .touchUpInside)
        self.shotBtn.setImage(UIImage.init(named: "btn_paishe"), for: .normal)
        self.addSubview(self.shotBtn)
        self.shotBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-46)
        }
        
        self.magicBtn = UIButton()
        self.magicBtn.addTarget(self, action: #selector(dealTap(magicBtn:)), for: .touchUpInside)
        self.magicBtn.setImage(UIImage.init(named: "mofa"), for: .normal)
        self.magicBtn.setTitle("魔法", for: .normal)
        self.magicBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.magicBtn.setContentInCenter()
        self.addSubview(self.magicBtn)
        self.magicBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.shotBtn)
            make.right.equalTo(self.shotBtn.snp.left).offset(-61)
        }
        
        self.backDeleteBtn = UIButton()
        self.backDeleteBtn.addTarget(self, action: #selector(dealTap(backDeleteBtn:)), for: .touchUpInside)
        self.backDeleteBtn.setImage(UIImage.init(named: "huitui"), for: .normal)
        self.backDeleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.backDeleteBtn.setContentInCenter()
        self.addSubview(self.backDeleteBtn)
        self.backDeleteBtn.snp.makeConstraints {[unowned self] (make) in
            make.centerY.equalTo(self.shotBtn)
            make.left.equalTo(self.shotBtn.snp.right).offset(61)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func controlsInit(){
        //闪光灯关闭
        self.aliyunRecorder.switchTorch(with: .off)
        if self.aliyunRecorder.cameraPosition != .front{
            self.aliyunRecorder.switchCameraPosition()
        }
        self.torchModelBtn.isEnabled = false
        
        self.refreshUIWith(state: self.state)
    }
    
    func refreshUIWith(state:RecordControlViewState){
        if state == .inDefault{
            self.progressView?.isHidden = true
            self.backBtn.isHidden = false
            self.cameraDirectionBtn.isHidden = false
            self.torchModelBtn.isHidden = false
            self.nextStepBtn.isHidden = false
            self.countDownBtn.isHidden = false
            self.fairBtn.isHidden = false
            self.musicBtn.isHidden = false
            self.shiftBtn.isHidden = false
            self.backDeleteBtn.isHidden = true
            self.shotBtn.isHidden = false
            self.magicBtn.isHidden = false
        }
        if state == .inShot{
            self.progressView?.isHidden = false
            self.cameraDirectionBtn.isHidden = true
            self.torchModelBtn.isHidden = true
            self.nextStepBtn.isHidden = true
            self.countDownBtn.isHidden = true
            self.fairBtn.isHidden = true
            self.musicBtn.isHidden = true
            self.shiftBtn.isHidden = true
            self.backDeleteBtn.isHidden = true
            self.shotBtn.isHidden = false
            self.magicBtn.isHidden = true
        }
        if state == .inPause{
            self.progressView?.isHidden = false
            self.backBtn.isHidden = false
            self.cameraDirectionBtn.isHidden = false
            self.torchModelBtn.isHidden = false
            self.nextStepBtn.isHidden = false
            self.countDownBtn.isHidden = false
            self.fairBtn.isHidden = false
            self.musicBtn.isHidden = false
            self.shiftBtn.isHidden = false
            self.backDeleteBtn.isHidden = false
            self.shotBtn.isHidden = false
            self.magicBtn.isHidden = false
        }
    }
    
    /// 点击返回按钮
    @objc func dealTap(backBtn:UIButton!){
        self.delegate?.recordControlViewTap(backBtn: backBtn)
    }
    ///切换摄像头
    @objc func dealTap(cameraDirectionBtn:UIButton!){
        self.aliyunRecorder.switchCameraPosition()
        if self.aliyunRecorder.cameraPosition == .front{
            self.aliyunRecorder.switchTorch(with: .off)
            self.torchModelBtn.isSelected = true
            self.torchModelBtn.isEnabled = false
        }else{
            self.torchModelBtn.isEnabled = true
        }
        self.delegate?.recordControlViewTap(cameraDirectionBtn: cameraDirectionBtn)
    }
    /// 切换电筒
    @objc func dealTap(torchModelBtn:UIButton!){
        torchModelBtn.isSelected = !torchModelBtn.isSelected
        if torchModelBtn.isSelected{
            self.aliyunRecorder.switchTorch(with: .on)
        }else{
            self.aliyunRecorder.switchTorch(with: .off)
        }
        self.delegate?.recordControlViewTap(torchModelBtn: torchModelBtn)
    }
    ///下一步
    @objc func dealTap(nextStepBtn:UIButton!){
        self.delegate?.recordControlViewTap(nextStepBtn: nextStepBtn)
    }
    ///倒计时
    @objc func dealTap(countDownBtn:UIButton!){
        let shotCountDownView = ShotCountDownView()
        shotCountDownView.completeBlock = {
            print("开始拍摄")
            //self.dealTap(shotBtn: self.shotBtn)
        }
        shotCountDownView.showWith(time: 3)
        self.delegate?.recordControlViewTap(countDownBtn: countDownBtn)
    }
    ///美颜
    @objc func dealTap(fairBtn:UIButton!){
        self.delegate?.recordControlViewTap(fairBtn: fairBtn)
    }
    ///音乐
   @objc  func dealTap(musicBtn:UIButton!){
        self.delegate?.recordControlViewTap(musicBtn: musicBtn)
    }
    ///变速
    @objc func dealTap(shiftBtn:UIButton!){
        self.delegate?.recordControlViewTap(shiftBtn: shiftBtn)
    }
    ///魔法
    @objc func dealTap(magicBtn:UIButton!){
        self.delegate?.recordControlViewTap(magicBtn: magicBtn)
    }
    ///点击拍摄
    @objc func dealTap(shotBtn:UIButton!){
        shotBtn.isSelected = !shotBtn.isSelected
        if shotBtn.isSelected{
            self.aliyunRecorder.startRecording()
            self.state = .inShot
            self.refreshUIWith(state: self.state)
        }
        if !shotBtn.isSelected{
            self.aliyunRecorder.stopRecording()
            self.state = .inPause
            self.refreshUIWith(state: self.state)
        }
        self.delegate?.recordControlViewTap(shotBtn: shotBtn)
    }
    ///回删
    @objc func dealTap(backDeleteBtn:UIButton!){
        self.delegate?.recordControlViewTap(backDeleteBtn: backDeleteBtn)
    }
}

extension RecordControlView:AliyunIRecorderDelegate{
    func recorderDeviceAuthorization(_ status: AliyunIRecorderDeviceAuthor) {
//        AliyunIRecorderDeviceAuthorEnabled,
//        AliyunIRecorderDeviceAuthorAudioDenied,
//        AliyunIRecorderDeviceAuthorVideoDenied
    }
    
    /**
     摄像头返回的原始视频数据  开放出来的目的是用于做人脸识别
     
     @param sampleBuffer 视频数据
     */
    func recorderOutputVideoRawSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
    }
    
    /**
     返回原始的音频数据 用来做语音识别一类的业务
     
     @param sampleBuffer 音频数据
     */
    func recorderOutputAudioRawSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
    }

 
 /**
 用户自定义渲染
 
 @param sampleBuffer 原始数据
 @return 用户自渲染后的PixelBuffer
 */

//    func customRenderedPixelBuffer(withRawSampleBuffer sampleBuffer: CMSampleBuffer!) -> Unmanaged<CVPixelBuffer>! {
//
//    }
 
 /**
 用户自定义渲染，开放pixelBuffer和纹理id给用户自渲染 （仅支持BGRA格式）
 
 @param pixelBuffer 摄像头数据
 @param textureName 摄像头数据纹理
 @return 自定义渲染后的纹理id
 */
//    func recorderOutputVideoPixelBuffer(_ pixelBuffer: CVPixelBuffer!, textureName: Int) -> Int {
//    }
 
 /**
 用户自定义渲染接口
 
 @param srcTexture 原始视频帧纹理id
 @param size 原始视频帧纹理size
 @return 返回纹理id
 */
//    func customRender(_ srcTexture: Int32, size: CGSize) -> Int32 {
//    }
    
 /**
 
 录制实时时长
 
 @param duration 录制时长
 */
    func recorderVideoDuration(_ duration: CGFloat) {
        print("录制时长：\(duration)")
    }
 
 /**
 摄像头返回的原始视频纹理
 摄像头数据格式为BGRA、YUV时都需实现
 
 @param textureName 原始纹理ID
 @return 处理后的纹理ID
 */
//    func recorderOutputVideoTextureName(_ textureName: Int, textureSize textureSie: CGSize) -> Int {
//    }
 
 /**
 摄像头返回的原始视频纹理
 摄像头数据格式仅为YUV时须实现，反之不实现
 
 @param textureName  原始UV分量的纹理ID
 @return 处理后的纹理ID
 */
//    func recorderOutputVideoUVTextureName(_ textureName: Int) -> Int {
//    }
    
 /**
 开始预览回调
 */
    func recorderDidStartPreview() {
        
    }
 /**
 停止录制回调
 */
    func recorderDidStopRecording() {
        print("录制停止")
    }
 /**
 当录至最大时长时回调
 */
    func recorderDidStopWithMaxDuration() {
        print("已录制最大时长")
    }
 /**
 结束录制回调
 */
    func recorderDidFinishRecording() {
        print("录制结束")
    }
 /**
 录制异常
 
 @param error 异常
 */
    func recoderError(_ error: Error!) {
        Toast.showErrorWith(msg: error.localizedDescription)
    }
    
}
