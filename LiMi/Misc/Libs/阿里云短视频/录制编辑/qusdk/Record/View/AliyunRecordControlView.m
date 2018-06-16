//
//  AliyunRecordControlView.m
//  LiMi
//
//  Created by dev.liufeng on 2018/5/18.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "AliyunRecordControlView.h"
#import "QUProgressView.h"
#import "AliyunIConfig.h"
#import "AliyunRateSelectView.h"
#import "ShotCountDownView.h"
#import "AliyunEffectFilterView.h"
#import "AliyunMagicCameraView.h"
#import "AliyunPasterInfo.h"
#import "MagicCameraView.h"
#import "AliyunDownloadManager.h"
#import "AliyunResourceManager.h"
#import "AliyunEffectMVView.h"
#import "AliyunMagicCameraEffectCell.h"
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "FilterAndBeautyView.h"
#import "AliyunRecordFocusView.h"
#import "LiMi-Swift.h"

@interface AliyunRecordControlView ()
    /*底部*/
    @property (nonatomic, strong) UIButton *magicButton;//
    @property (nonatomic, strong) UIButton *recordButton;
    @property (nonatomic, strong) UIButton *deleteButton;
    @property (nonatomic, strong) UIButton *finishButton;//?
    @property (nonatomic, strong) UIButton *photoLibraryButton;//?
    @property (nonatomic, strong) AliyunRateSelectView *rateView;
    @property (nonatomic, strong) FilterAndBeautyView *filterView;
@property (nonatomic, strong) UILabel *durationLabel;


    @property (nonatomic, assign) BOOL recording;
    @property (nonatomic, assign) double startTime;
    @property (nonatomic, assign) CGFloat height;
    /*侧边*/
    @property (nonatomic, strong) UIButton *countDownButton;//
    @property (nonatomic, strong) UIButton *beautyButton;
    @property (nonatomic, strong) UIButton *musicButton;//
    @property (nonatomic, strong) UIButton *speedButton;//
    @property (nonatomic, strong) UIButton *ratioButton;


    /*顶部*/
    @property (nonatomic, strong) QUProgressView *progressView;///
    @property (nonatomic, strong) UIButton *backButton;
    @property (nonatomic, strong) UIButton *cameraButton;
    @property (nonatomic, strong) UIButton *flashButton;
    @property (nonatomic, strong) UIButton *nextButton;

    @property (nonatomic, assign) CGFloat currentRatio;
@property (nonatomic, strong) AliyunRecordFocusView *focusView;

    /*添加魔法*/
    @property (nonatomic, strong) MagicCameraView *magicCameraView;
@property (nonatomic, assign) CGFloat lastPanY;

/* 闪光灯模式 */
@property (nonatomic, assign) AliyunIRecorderTorchMode torchMode;
@property (nonatomic, assign) int selectedSegmentIndex;

@end

@implementation AliyunRecordControlView
    {
        AliyunEffectPaster *_currentEffectPaster;
        CFTimeInterval _recordingDuration;
    }
    
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubviews];
        _currentRatio = 3/4.0;
    }
    return self;
}
    
- (void)setupSubviews {
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [AliyunIConfig config].backgroundColor;
    backgroundView.alpha = 0.5;
    [self addSubview:backgroundView];
    [self addSubview:self.durationLabel];
    [self addSubview:self.recordButton];
    [self addSubview:self.deleteButton];
    [self addSubview:self.progressView];
    [self addSubview:self.magicButton];
    //[self addSubview:self.photoLibraryButton];
    [self addSubview:self.focusView];
    [self addGesture];
    self.photoLibraryButton.hidden = [AliyunIConfig config].hiddenImportButton;
    self.finishButton.hidden = [AliyunIConfig config].hiddenFinishButton;
    self.finishButton.enabled = NO;
    
    
    CGFloat y = 15.0;
    _backButton   = [self createButtonWithImage:[UIImage imageNamed:@"short_video_back"] ];
    _backButton.frame = CGRectMake(15, y, 44, 28);
    
    _nextButton = [self createButtonWithImage:NULL];
    [_nextButton setBackgroundColor:rgba(185, 175, 254, 1)];
    _nextButton.enabled = NO;
    [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    _nextButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _nextButton.layer.cornerRadius = 4;
    _nextButton.clipsToBounds = true;
    _nextButton.frame = CGRectMake(ScreenWidth-15-64, y, 64, 28);
    [_nextButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGFloat x_left = 44;
    CGFloat anchor = ScreenWidth - 22;
    NSInteger distance = 0;
    if (![AliyunIConfig config].hiddenFlashButton) {
        _flashButton  = [self createButtonWithImage:[UIImage imageNamed:@"sgd_close"]];
        _flashButton.enabled = NO;
        _flashButton.frame = CGRectMake((_nextButton.frame.origin.x - 60-28), y, 28, 28);
        distance ++;
    }
    if (![AliyunIConfig config].hiddenCameraButton) {
        _cameraButton = [self createButtonWithImage:[UIImage imageNamed:@"qhsxt"]];
        _cameraButton.frame = CGRectMake(_flashButton.frame.origin.x-41-28, y, 28, 28);
        distance ++;
    }
    
    [AliyunIConfig config].hiddenRatioButton = YES;
    if (![AliyunIConfig config].hiddenRatioButton) {
        _ratioButton  = [self createButtonWithImage:[AliyunImage imageNamed:@"record_ratio"]];
        distance ++;
    }
    
    CGFloat x = ScreenWidth-28-20;
    _countDownButton = [self createButtonWithImage:[UIImage imageNamed:@"time"]];
//    _countDownButton.backgroundColor = UIColor.grayColor;
    [_countDownButton addTarget:self action:@selector(countDownButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _countDownButton.frame = CGRectMake(x, CGRectGetMaxY(_nextButton.frame)+46, 28, 28);
    [_countDownButton setTitle:@"倒计时" forState:UIControlStateNormal];
    _countDownButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_countDownButton sizeToFitTitleBelowImageWithDistance:7];
//    _countDownButton.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    
    x = x+(_countDownButton.frame.size.width-28)/2;
    _beautyButton = [self createButtonWithImage:[UIImage imageNamed:@"meiyan"] ];
    _beautyButton.frame = CGRectMake(x, CGRectGetMaxY(_countDownButton.frame)+38, 28, 28);
    [_beautyButton setTitle:@"美颜" forState:UIControlStateNormal];
    _beautyButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_beautyButton sizeToFitTitleBelowImageWithDistance:7];
    
    _musicButton = [self createButtonWithImage:[UIImage imageNamed:@"music"]];
    _musicButton.frame = CGRectMake(x, CGRectGetMaxY(_beautyButton.frame)+38, 28, 28);
    [_musicButton setTitle:@"音乐" forState:UIControlStateNormal];
    _musicButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_musicButton sizeToFitTitleBelowImageWithDistance:7];

    
    _speedButton = [self createButtonWithImage:[UIImage imageNamed:@"biansu"]];
    [_speedButton addTarget:self action:@selector(speedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _speedButton.frame = CGRectMake(x, CGRectGetMaxY(_musicButton.frame)+38, 28, 28);
    [_speedButton setTitle:@"变速" forState:UIControlStateNormal];
    _speedButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_speedButton sizeToFitTitleBelowImageWithDistance:7];

    
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_ratioButton addTarget:self action:@selector(ratioButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_beautyButton addTarget:self action:@selector(beautyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraButton addTarget:self action:@selector(cameraButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_flashButton addTarget:self action:@selector(flashButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_musicButton addTarget:self action:@selector(musicButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_ratioButton setImage:[AliyunImage imageNamed:@"record_ratio_dis"] forState:UIControlStateDisabled];
    [_beautyButton setImage:[UIImage imageNamed:@"meiyan"] forState:UIControlStateDisabled];
    [_cameraButton setImage:[AliyunImage imageNamed:@"camera_id_dis"] forState:UIControlStateDisabled];
    [_flashButton setImage:[UIImage imageNamed:@"sgd_no"] forState:UIControlStateDisabled];
    [_beautyButton setImage:[AliyunImage imageNamed:@"meiyan"] forState:UIControlStateSelected];
    _beautyButton.selected = YES;
    _ratioButton.hidden = NO;

}

- (void)addGesture {
    UITapGestureRecognizer *previewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapGesture:)];
    previewTap.delegate = self;
        [self addGestureRecognizer:previewTap];
    
    UIPanGestureRecognizer *previewPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(previewPanGesture:)];
    previewPan.delegate = self;
        [self addGestureRecognizer:previewPan];
    
    UIPinchGestureRecognizer *previewPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(previewPinchGesture:)];
    previewPinch.delegate = self;
        [self addGestureRecognizer:previewPinch];
}

//需要旋转 缩放同时起效 设置delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}


- (void)previewTapGesture:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    self.recoder.focusPoint = point;
    _focusView.center = point;
    [self.rateView setHidden:true];
    [_focusView refreshPosition];
}

- (void)previewPanGesture:(UIPanGestureRecognizer *)gesture {
    if (_focusView.alpha == 0 || gesture.numberOfTouches == 2) {
        return;
    }
    CGPoint point = [gesture translationInView:self];
    CGFloat y = point.y;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _lastPanY = y;
    }
    if (fabs(y) > fabs(point.x)) {
        CGFloat v = (_lastPanY - y)/CGRectGetHeight(self.bounds);
        self.recoder.exposureValue += v;
        [_focusView changeExposureValue:self.recoder.exposureValue];
    }
    _lastPanY = y;
}

- (void)pausePreview {
    [self.recoder stopPreview];
//    [_motionManager stopDeviceMotionUpdates];
}

- (void)previewPinchGesture:(UIPinchGestureRecognizer *)gesture {
    if (isnan(gesture.velocity) || gesture.numberOfTouches != 2) {
        return;
    }
    self.recoder.videoZoomFactor = gesture.velocity;
    gesture.scale = 1;
    
    return;
}

- (void)setMaxDuration:(CGFloat)maxDuration {
    _maxDuration = maxDuration;
    _progressView.maxDuration = maxDuration;
}
    
- (void)setMinDuration:(CGFloat)minDuration {
    _minDuration = minDuration;
    _progressView.minDuration = minDuration;
}
    
- (void)updateRecordStatus {
    _deleteButton.enabled = YES;
}
    
-(void)updateHeight:(CGFloat)height {
    _height = height;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
    
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat recordButtonY  = ScreenHeight - 46 - 72 -SafeBottom;
    _recordButton.frame = CGRectMake((ScreenWidth/2.0-72/2.0), recordButtonY, 72, 72);
    CGPoint center = _recordButton.center;
    
    self.durationLabel.center = center;

    _deleteButton.frame = CGRectMake(0, 0, 36, 36);
    _deleteButton.center = CGPointMake(center.x+36+58+18, center.y);
    
    _magicButton.frame = CGRectMake(0, 0, 36, 36);
    _magicButton.center = CGPointMake(center.x-36-58-18, center.y);

}
    
- (void)updateVideoDuration:(CGFloat)duration {
    [_progressView updateProgress:duration];
    if (duration >= _minDuration) {
        _finishButton.enabled = YES;
    } else {
        _finishButton.enabled = NO;
    }

    if(duration > 0 && !self.recoder.isRecording){
        [self.deleteButton setHidden:NO];
    }
    
    NSDictionary *info = @{@"duration":[NSNumber numberWithFloat:duration]};
    [NSNotificationCenter.defaultCenter postNotificationName:@"RecordingDurationChaged" object:nil userInfo:info];
    
//    if (duration > 0 && _deleteButton.hidden && ![AliyunIConfig config].hiddenDeleteButton) {
//        if (![AliyunIConfig config].hiddenDeleteButton) {
//            _deleteButton.hidden = NO;
//        }
//        _photoLibraryButton.hidden = YES;
//    }
    
    if (duration <=0) {
        [self.finishButton removeFromSuperview];
    } else {
        [self addSubview:self.finishButton];
    }
}
    
- (void)endRecord{
    if (!_recording) {
        return;
    }
    _startTime = 0;
    [self updateRecordTypeToEndRecord];
    [_delegate bottomViewPauseVideo];
    _deleteButton.enabled = YES;
    
    if ([AliyunIConfig config].recordOnePart) {
        if (_delegate) {
            [_delegate bottomViewFinishVideo];
        }
    }
}
    
- (void)updateRecordTypeToEndRecord {
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"btn_psz"]forState:UIControlStateNormal];
    _recording = NO;
    [self changeOtherButtonType];
}
    
- (void)recordButtonTouchUp {
    NSLog(@" DD----  %f    %f  - %f", CFAbsoluteTimeGetCurrent(), _startTime, (CFAbsoluteTimeGetCurrent() - _startTime));
    BOOL longPass = (CFAbsoluteTimeGetCurrent() - _startTime) > 1;
    switch ([AliyunIConfig config].recordType) {
        case AliyunIRecordActionTypeCombination:
        
        if (longPass) {
            if (_recording) {
                [self endRecord];
            }
        }else{
            if (_recording) {
                [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_paishe"]forState:UIControlStateNormal];
                
            }else{
                [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_psz"]forState:UIControlStateNormal];
            }
        }
        break;
        case AliyunIRecordActionTypeHold:
        [self endRecord];
        break;
        
        case AliyunIRecordActionTypeClick:
        if (_recording) {
            [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_paishe"]forState:UIControlStateNormal];
        }else{
            [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_psz"]forState:UIControlStateNormal];
        }
        break;
        default:
        break;
    }
    
}
    
- (void)recordButtonTouchDown {
    _startTime = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"  YY----%f", _startTime);
    
    switch ([AliyunIConfig config].recordType) {
        case AliyunIRecordActionTypeCombination:
        if (_recording) {
            [self endRecord];
            return;
        }else{
            [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_hold"]forState:UIControlStateNormal];
            _recording = YES;
        }
        break;
        case AliyunIRecordActionTypeHold:
        _recording = YES;
        [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_hold"]forState:UIControlStateNormal];
        break;
        
        case AliyunIRecordActionTypeClick:
        if (_recording) {
            [self endRecord];
            return;
        }else{
            _recording = YES;
        }
        break;
        default:
        break;
    }
    
    [self changeOtherButtonType];
    
    [_delegate bottomViewRecordVideo];
    
    _progressView.showBlink = NO;
    _progressView.videoCount++;
    
    _deleteButton.selected = NO;
}
    
    - (void)magicButtonClick:(UIButton *)button{
        [self.magicCameraView show];
    }
    
- (void)deleteButtonClick:(UIButton *)buttonClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认删除上一段视频？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _progressView.videoCount--;
        [self bottomViewDeleteFinished];
        if (_progressView.videoCount <= 0) {
            if (![AliyunIConfig config].hiddenImportButton) {
                _photoLibraryButton.hidden = NO;
            }
            
            _deleteButton.hidden = YES;
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    UIViewController *controller = self.delegate;
    [controller presentViewController:alertController animated:true completion:nil];
    
//    NSLog(@"delete   %d", self.deleteButton.selected);
//    buttonClick.selected = !buttonClick.selected;
//    if (buttonClick.selected) {
//        _progressView.selectedIndex = _progressView.videoCount - 1;
//    } else {
//        _progressView.videoCount--;
//        [self bottomViewDeleteFinished];
//        if (_progressView.videoCount <= 0) {
//            if (![AliyunIConfig config].hiddenImportButton) {
//                _photoLibraryButton.hidden = NO;
//            }
//            
//            _deleteButton.hidden = YES;
//        }
//    }
}
    
- (void)deleteLastProgress {
    
    _progressView.videoCount--;
}
    
- (void)changeOtherButtonType {
    
    _deleteButton.userInteractionEnabled = !_recording;
    _finishButton.userInteractionEnabled = !_recording;
}
    
- (void)finishButtonClick {
    [_delegate bottomViewFinishVideo];
}
    
- (void)photoLibraryButtonClick {
    [_delegate bottomViewShowLibrary];
}
    
- (MagicCameraView *)magicCameraView{
    if(!_magicCameraView){
        _magicCameraView = [[MagicCameraView alloc] init];
        _magicCameraView.delegate = (id)self;
    }
    return _magicCameraView;
}
    
- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordButton.bounds = CGRectMake(0, 0, 72, 72);
        _recordButton.backgroundColor = [UIColor clearColor];
        _recordButton.adjustsImageWhenHighlighted = NO;
        [_recordButton setBackgroundImage:[UIImage imageNamed:@"btn_paishe"]forState:UIControlStateNormal];
        _recordButton.layer.masksToBounds = YES;
        [_recordButton addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchDragOutside];
    }
    return _recordButton;
}
    
- (QUProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[QUProgressView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 5)];
        [_progressView setHidden:YES];
        _progressView.showBlink = NO;
        _progressView.showNoticePoint = NO;
    }
    return _progressView;
}
    
- (UIButton *)magicButton {
    if (!_magicButton) {
        _magicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _magicButton.bounds = CGRectMake(0, 0, SizeWidth(40), SizeWidth(40));
        _magicButton.hidden = NO;
        [_magicButton setImage:[UIImage imageNamed:@"mofa"] forState:0];
        [_magicButton setImage:[UIImage imageNamed:@"mofa"] forState:(UIControlStateSelected)];
        [_magicButton setTitle:@"魔法" forState:UIControlStateNormal];
        _magicButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_magicButton addTarget:self action:@selector(magicButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_magicButton sizeToFitTitleBelowImageWithDistance:7];
    }
    return _magicButton;
}
    
- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.bounds = CGRectMake(0, 0, SizeWidth(40), SizeWidth(40));
        _deleteButton.hidden = YES;
        [_deleteButton setImage:[UIImage imageNamed:@"huitui"] forState:0];
        [_deleteButton setImage:[UIImage imageNamed:@"huitui"] forState:(UIControlStateSelected)];
        [_deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}
    
- (UIButton *)finishButton {
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.bounds = CGRectMake(0, 0, SizeWidth(40), SizeWidth(40));
        [_finishButton setImage:[AliyunImage imageNamed:@"record_finish"] forState:0];
        [_finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}
    
- (UIButton *)photoLibraryButton {
    if (!_photoLibraryButton) {
        _photoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoLibraryButton.bounds = CGRectMake(0, 0, SizeWidth(40), SizeWidth(40));
        [_photoLibraryButton setImage:[AliyunImage imageNamed:@"record_lib"] forState:0];
        [_photoLibraryButton addTarget:self action:@selector(photoLibraryButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoLibraryButton;
}

- (AliyunRecordFocusView *)focusView {
    if (!_focusView) {
        _focusView = [[AliyunRecordFocusView alloc] init];
        _focusView.bounds = CGRectMake(0, 0, 72, 72);
        _focusView.center = CGPointMake(ScreenWidth /2.f, CGRectGetMidY(self.bounds));
        _focusView.alpha = 0;
        _focusView.userInteractionEnabled = NO;
    }
    return _focusView;
}

    - (FilterAndBeautyView *)filterView {
        if (!_filterView) {
            _filterView = [[[NSBundle mainBundle] loadNibNamed:@"FilterAndBeautyView" owner:nil options:nil] lastObject];
            _filterView.delegate = self;
            _filterView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            
//            _filterView = [[AliyunEffectFilterView alloc] initWithFrame:CGRectMake(0, ScreenHeight-142, ScreenWidth, 142)];
//            _filterView.delegate = (id<AliyunEffectFilter2ViewDelegate>)self;
//            [self addSubview:_filterView];
        }
        return _filterView;
    }

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.hidden = true;
        _durationLabel.bounds = CGRectMake(0, 0, 72, 72);
        CGPoint p = CGPointMake(ScreenWidth / 2.f, ScreenWidth * 4/3.f );
        _durationLabel.center = p;
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.textColor = UIColor.whiteColor;
        _durationLabel.font = [UIFont systemFontOfSize:10];
        _durationLabel.hidden = YES;
        _durationLabel.text = @"00:00";
    }
    return _durationLabel;
}

- (AliyunRateSelectView *)rateView{
    if(!_rateView){
        _rateView = [[AliyunRateSelectView alloc] initWithItems:@[@"极慢",@"慢",@"标准",@"快",@"极快"]];
        _rateView.frame = CGRectMake(40, self.recordButton.frame.origin.y-40-20, ScreenWidth-80, 36);
        _selectedSegmentIndex = 2;
        _rateView.selectedSegmentIndex = _selectedSegmentIndex;
        [_rateView setHidden:true];
        [_rateView addTarget:self action:@selector(rateChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_rateView];
    }
    return _rateView;
}

- (void)setupBeautyStatus:(BOOL)isBeauty flashStatus:(NSInteger)flashStatus {
    
//    self.beautyButton.selected = isBeauty;
    //[self updateNavigationFlashStatus:flashStatus];
}



- (void)updateNavigationStatusWithDuration:(CGFloat)duration {
    self.duration = duration;
        int d = duration;
        int m = d / 60;
        int s = d % 60;
    
    NSString *recordImageName = self.recoder.isRecording ? @"btn_psz" : @"btn_paishe";
    [self.recordButton setBackgroundImage:[UIImage imageNamed:recordImageName] forState:UIControlStateNormal];
    
    BOOL isRecording = self.recoder.isRecording;
    if(!isRecording && self.duration >= self.progressView.minDuration){
        [_nextButton setBackgroundColor:rgba(127, 110, 241, 1)];
        _nextButton.enabled = YES;
    }else{
        [_nextButton setBackgroundColor:rgba(185, 175, 254, 1)];
        _nextButton.enabled = NO;
    }
    self.progressView.hidden = duration <= 0 ? YES : NO;
    if(duration <= 0){}
    _durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",m,s];
    
    AliyunRecordViewController *recordController = (AliyunRecordViewController *)self.delegate;
//    if(duration <= 0){
//        [self.musicButton setHidden:false];
//    }else{
//        BOOL hidden = recordController.musicId == 0 ? false : true;
//        [self.musicButton setHidden:hidden];
//    }
}
    
- (void)updateNavigationStatusWithRecord:(BOOL)isRecording {
    //NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [self.progressView setHidden:!isRecording];
    if(self.duration > 0){[self.progressView setHidden:NO];}
    if(!isRecording && self.duration >= self.progressView.minDuration){
        [_nextButton setBackgroundColor:rgba(127, 110, 241, 1)];
        _nextButton.enabled = YES;
    }else{
        [_nextButton setBackgroundColor:rgba(185, 175, 254, 1)];
        _nextButton.enabled = NO;
    }
    NSDictionary *info = @{@"isRecording":[NSNumber numberWithBool:isRecording]};
    [NSNotificationCenter.defaultCenter postNotificationName:@"RecordingStatusChaged" object:nil userInfo:info];
    [self.backButton setHidden:isRecording];
    [self.cameraButton setHidden:isRecording];
    [self.flashButton setHidden:isRecording];
    [self.nextButton setHidden:isRecording];
    [self.countDownButton setHidden:isRecording];
    [self.beautyButton setHidden:isRecording];
    [self.musicButton setHidden:isRecording];
    [self.speedButton setHidden:isRecording];
    [self.deleteButton setHidden:isRecording];
    
//    [self.recordButton setHidden:isRecording];
    [self.magicButton setHidden:isRecording];
    [self.durationLabel setHidden:!isRecording];
    NSString *recordImageName = isRecording ? @"btn_psz" : @"btn_paishe";
    [self.recordButton setBackgroundImage:[UIImage imageNamed:recordImageName] forState:UIControlStateNormal];
//    _flashButton.enabled  = !isRecording;
//    _beautyButton.enabled = !isRecording;
//    _cameraButton.enabled = !isRecording;
//    _backButton.enabled = !isRecording;
}
    
- (void)backButtonClick {
    [_delegate navigationBackButtonClick];
}
    
- (void)ratioButtonClick {
    if (_currentRatio == 3/4.0) {
        _currentRatio = 9/16.0;
    } else if (_currentRatio == 9/16.0) {
        _currentRatio = 1;
    } else if (_currentRatio == 1) {
        _currentRatio = 3/4.0;
    }
    [self updateNavigationRatioStatus];
    [_delegate navigationRatioDidChangedWithValue:_currentRatio];
}



    - (void)beautyButtonClick:(UIButton *)button {
        [self.filterView show];
//        [self addSubview:self.filterView];
//        [self.filterView setHidden:NO];
//        _beautyButton.selected = !_beautyButton.selected;
//    //[_delegate navigationBeautyDidChangedStatus:_beautyButton.selected];
}
    
    - (void)musicButtonClick:(UIButton *)butotn{
        [self.delegate musicButtonClick];
    }
    
- (void)flashButtonClick {
    NSInteger status = [self navigationFlashModeDidChanged];
    [self updateNavigationFlashStatus:status];
}

- (NSInteger)navigationFlashModeDidChanged {
    if (_recoder.torchMode == AliyunIRecorderTorchModeOff){
        [_recoder switchTorchWithMode:AliyunIRecorderTorchModeOn];
    }
    else if(_recoder.torchMode == AliyunIRecorderTorchModeOn){
        [_recoder switchTorchWithMode:AliyunIRecorderTorchModeOff];
    }
    else if(_recoder.torchMode == AliyunIRecorderTorchModeAuto){
        [_recoder switchTorchWithMode:AliyunIRecorderTorchModeOff];
    }
    _torchMode = _recoder.torchMode;
    
    return (int)_torchMode;
}
    
- (void)speedButtonClick:(UIButton *)button{
    self.rateView.selectedSegmentIndex = self.selectedSegmentIndex;
    [self.rateView setHidden:false];
}
    
    - (void)countDownButtonClick:(UIButton *)button{
        ShotCountDownView *countDownView = [[ShotCountDownView alloc] init];
        countDownView.completeBlock = ^{
            [self recordButtonTouchDown];
        };
        [countDownView showWith:3];
    }

- (void)updateNavigationFlashStatus:(NSInteger)status {
    if (status == 0) {
        [_flashButton setImage:[UIImage imageNamed:@"sgd_close"] forState:0];
    } else if (status == 1) {
        [_flashButton setImage:[UIImage imageNamed:@"sgd_open"] forState:0];
    }
}
    
- (void)updateNavigationRatioStatus {
    if (_currentRatio == 1) {
        [_ratioButton setImage:[AliyunImage imageNamed:@"record_videoSize_1_1"] forState:0];
    } else if (_currentRatio == 9/16.0) {
        [_ratioButton setImage:[AliyunImage imageNamed:@"record_videoSize_9_16"] forState:0];
    } else {
        [_ratioButton setImage:[AliyunImage imageNamed:@"record_videoSize_4_3"] forState:0];
    }
}
    
- (void)cameraButtonClick {
    AliyunIRecorderCameraPosition cameraPosition = [self.recoder switchCameraPosition];
    [self.recoder switchTorchWithMode:AliyunIRecorderTorchModeOff];
    _torchMode = AliyunIRecorderTorchModeOff;
    [self updateNavigationFlashStatus:(int)_torchMode];

    if(cameraPosition == AliyunIRecorderCameraPositionFront){
        self.flashButton.enabled = NO;
    }else{
        self.flashButton.enabled = YES;
    }
}

- (UIButton *)createButtonWithImage:(UIImage *)imageName{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:imageName forState:0];
    button.bounds = CGRectMake(0, 0, 40, 40);
    [self addSubview:button];
    return button;
}

- (void)rateChanged:(AliyunRateSelectView *)rateView {
    [rateView setHidden:true];
    self.selectedSegmentIndex = rateView.selectedSegmentIndex;
    CGFloat rate = 1.0f;
    switch (rateView.selectedSegmentIndex) {
        case 0:
        rate = 0.5f;
        break;
        case 1:
        rate = 0.75f;
        break;
        case 2:
        rate = 1.0f;
        break;
        case 3:
        rate = 1.5f;
        break;
        case 4:
        rate = 2.0f;
        break;
        default:
        break;
    }
    [self.delegate didSelectRate:rate];
}

- (void)bottomViewRecordVideo {
    //    if ([_clipManager partCount] == 0) {
//    _recorder.cameraRotate = _cameraRotate; // 旋转角度以第一段视频为准  产品需求更改:不以第一段视频角度计算
    //    }
    
    [self.recoder startRecording];
    
    [self updateNavigationStatusWithRecord:YES];
}

- (void)bottomViewPauseVideo {
    [self.recoder stopRecording];
    [self updateNavigationStatusWithRecord:NO];
}

- (void)bottomViewDeleteFinished {
    [_clipManager deletePart];
    [self updateVideoDuration:_clipManager.duration];
    [self updateNavigationStatusWithDuration:_clipManager.duration];
}

    
#pragma mark - AliyunEffectFilter2ViewDelegate
- (void)cancelButtonClick{
    [self.filterView removeFromSuperview];
}
    
- (void)animtionFilterButtonClick{
    
}
    
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter{
    AliyunEffectFilter *filter2 =[[AliyunEffectFilter alloc] initWithFile:[filter localFilterResourcePath]];
    [self.recoder applyFilter:filter2];
}

- (void)beautyValueChangedWith:(float)value{
    self.recoder.beautifyValue = (int)value;
}


- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup{
    
}
    
- (void)didSelectEffectMoreMv{
    
}
    
- (void)didBeganLongPressEffectFilter:(AliyunEffectFilterInfo *)animtinoFilter{
    
}
    
- (void)didEndLongPress{
    
}
    
- (void)didRevokeButtonClick{
    
}
    
- (void)didTouchingProgress{
    
}
    
#pragma mark - 魔法（人脸识别）
    
- (void)addEffectWithPath:(NSString *)path
    {
        AliyunEffectPaster *paster = [[AliyunEffectPaster alloc] initWithFile:path];
        [self deleteCurrentEffectPaster];
        
        _currentEffectPaster = paster;
        [self.recoder applyPaster:paster];
    }
    
- (void)deleteCurrentEffectPaster
    {
        if (_currentEffectPaster) {
            [self.recoder deletePaster:_currentEffectPaster];
            _currentEffectPaster = nil;
        }
    }

@end
