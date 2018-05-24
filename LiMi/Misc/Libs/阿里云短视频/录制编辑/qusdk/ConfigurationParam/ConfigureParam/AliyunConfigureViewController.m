//
//  QUConfigureViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/12.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunConfigureViewController.h"

#if SDK_VERSION == SDK_VERSION_BASE
#import <AliyunVideoSDK/AliyunVideoSDK.h>

#else
#import "AliyunMediaConfig.h"


#endif

@interface AliyunConfigureViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textFieldFPS;
@property (weak, nonatomic) IBOutlet UITextField *textFieldGOP;
@property (weak, nonatomic) IBOutlet UITextField *textFieldBitrate;

@property (weak, nonatomic) IBOutlet UISlider *bpsSilder;
@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;
@property (weak, nonatomic) IBOutlet UISlider *ratioSlider;
@property (weak, nonatomic) IBOutlet UILabel *labelVideoSize;
@property (weak, nonatomic) IBOutlet UILabel *ratioLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoQualityLabel;
@property (weak, nonatomic) IBOutlet UIView *roundViewCut;
@property (weak, nonatomic) IBOutlet UIView *roundViewFill;
@property (weak, nonatomic) IBOutlet UISwitch *encodeSwitch;


@property (weak, nonatomic) IBOutlet UISwitch *cropSwitch;

@property (nonatomic, strong) CALayer *fillLayer;

@property (nonatomic, strong) NSArray *qualities;
@property (nonatomic, strong) AliyunMediaConfig *mediaInfo;

@property (nonatomic, assign) CGFloat videoOutputRatio;
@property (nonatomic, assign) CGFloat videoOutputWidth;

@end

@implementation AliyunConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _roundViewCut.layer.cornerRadius = 9;
    _roundViewCut.layer.masksToBounds = YES;
    _roundViewFill.layer.cornerRadius = 9;
    _roundViewFill.layer.masksToBounds = YES;
    
    [_textFieldFPS setValue:RGBToColor(110, 118, 139) forKeyPath:@"_placeholderLabel.textColor"];
    [_textFieldGOP setValue:RGBToColor(110, 118, 139) forKeyPath:@"_placeholderLabel.textColor"];
    
    _sizeSlider.minimumTrackTintColor = RGBToColor(240, 84, 135);
    [_sizeSlider setThumbTintColor:RGBToColor(240, 84, 135)];
    
    _bpsSilder.minimumTrackTintColor = RGBToColor(240, 84, 135);
    [_bpsSilder setThumbTintColor:RGBToColor(240, 84, 135)];
    _bpsSilder.value = 0.25;
    
    _ratioSlider.minimumTrackTintColor = RGBToColor(240, 84, 135);
    [_ratioSlider setThumbTintColor:RGBToColor(240, 84, 135)];
    _ratioSlider.value = 0.6;
    
    
    _mediaInfo = [[AliyunMediaConfig alloc] init];
    _mediaInfo.minDuration = 2.0;
    _mediaInfo.maxDuration = 10.0*60;
    _mediaInfo.fps = 25;
    _mediaInfo.gop = 5;
    _mediaInfo.videoQuality = 1;
    _mediaInfo.outputSize = CGSizeMake(540, 720);
    _mediaInfo.cutMode = AliyunMediaCutModeScaleAspectFill;
    _mediaInfo.videoOnly = NO;
    _mediaInfo.backgroundColor = [UIColor blackColor];
    _qualities = @[@"极高",@"高",@"中",@"低",@"较低",@"极低"];
    
    self.videoOutputRatio = 0.75;
    self.videoOutputWidth = 540;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.textFieldFPS resignFirstResponder];
    [self.textFieldGOP resignFirstResponder];
    [self.textFieldBitrate resignFirstResponder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_mediaInfo.cutMode == AliyunMediaCutModeScaleAspectFill) {
        self.fillLayer.position = _roundViewFill.center;
    } else {
        self.fillLayer.position = _roundViewCut.center;
    }
}

- (IBAction)textFieldFPSEndEdit:(id)sender {
    _mediaInfo.fps = [_textFieldFPS.text intValue];
}
- (IBAction)textFieldGOPEndEdit:(id)sender {
    _mediaInfo.gop = [_textFieldGOP.text intValue];
}

- (IBAction)textFieldBitrateEndEdit:(id)sender {
        _mediaInfo.bitrate = [_textFieldBitrate.text intValue];
}


- (IBAction)silderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSString *str = @"540P";
    if (slider.value < 1/4.0) {
        self.videoOutputWidth = 360;
        str = @"360P";
    } else if (slider.value < 2/4.0) {
        self.videoOutputWidth = 480;
        str = @"480P";
    } else if (slider.value < 3/4.0) {
        self.videoOutputWidth = 540;
        str = @"540P";
    } else {
        self.videoOutputWidth = 720;
        str = @"720P";
    }
    _labelVideoSize.text = str;
}

- (IBAction)bpsSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    int value = slider.value * 100;
    _mediaInfo.videoQuality = value / (100 / 5);
//    if ((int)_mediaInfo.videoQuality == 4) _mediaInfo.videoQuality = 3;
    _videoQualityLabel.text = _qualities[_mediaInfo.videoQuality];
}

- (IBAction)ratioSliderValueChanged:(UISlider *)sender {
    
    NSString *ratio = @"3:4";
    if (sender.value < 1/3.0) {
        self.videoOutputRatio = 9.0/16.0;
        ratio = @"9:16";
    } else if (sender.value < 2/3.0) {
        self.videoOutputRatio = 3.0/4.0;
        ratio = @"3:4";
    } else {
        self.videoOutputRatio = 1.0;
        ratio = @"1:1";
    }
    _ratioLabel.text = ratio;
}

- (IBAction)buttonCencelCLick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonNextClick:(id)sender {
    
    [self updatevideoOutputVideoSize];
    if (self.delegate) {
        [self.delegate configureDidFinishWithMedia:_mediaInfo];
    }
}

- (IBAction)buttonCutModeClick:(id)sender {
    self.fillLayer.position = _roundViewCut.center;
    _mediaInfo.cutMode = AliyunMediaCutModeScaleAspectCut;
}

- (IBAction)buttonFillModeClick:(id)sender {
    self.fillLayer.position = _roundViewFill.center;
    _mediaInfo.cutMode = AliyunMediaCutModeScaleAspectFill;
}

-(IBAction)switchEncode:(UISwitch *)sender {
//    _mediaInfo.encodeMode = sender.on;
}

- (IBAction)switchCrop:(UISwitch *)sender {
    _mediaInfo.gpuCrop = sender.on;
}

- (CALayer *)fillLayer {
    if (!_fillLayer) {
        _fillLayer = [CALayer layer];
        _fillLayer.backgroundColor = RGBToColor(240, 84, 135).CGColor;
        _fillLayer.bounds = CGRectMake(0, 0, 8, 8);
        _fillLayer.cornerRadius = 4;
        _fillLayer.masksToBounds = YES;
        [self.view.layer addSublayer:_fillLayer];
    }
    return _fillLayer;
}

// 根据调节结果更新videoSize
- (void)updatevideoOutputVideoSize {
    
    CGFloat width = self.videoOutputWidth;
    CGFloat height = ceilf(self.videoOutputWidth / self.videoOutputRatio); // 视频的videoSize需为整偶数
    _mediaInfo.outputSize = CGSizeMake(width, height);
    NSLog(@"videoSize:w:%f  h:%f", _mediaInfo.outputSize.width, _mediaInfo.outputSize.height);
    
}

@end
