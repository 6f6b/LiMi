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

@interface AliyunRecordControlView ()
    /*底部*/
    @property (nonatomic, strong) UIButton *magicButton;//
    @property (nonatomic, strong) UIButton *recordButton;
    @property (nonatomic, strong) UIButton *deleteButton;
    @property (nonatomic, strong) UIButton *finishButton;//?
    @property (nonatomic, strong) UIButton *photoLibraryButton;//?
    @property (nonatomic, strong) AliyunRateSelectView *rateView;
    @property (nonatomic, strong) FilterAndBeautyView *filterView;


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
    
    /*添加魔法*/
    @property (nonatomic, strong) MagicCameraView *magicCameraView;
@end

@implementation AliyunRecordControlView
    {
        AliyunEffectPaster *_currentEffectPaster;
        AliyunClipManager *_clipManager;
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
    [self addSubview:self.recordButton];
    [self addSubview:self.deleteButton];
    [self addSubview:self.progressView];
    [self addSubview:self.magicButton];
    //[self addSubview:self.photoLibraryButton];
    
    self.photoLibraryButton.hidden = [AliyunIConfig config].hiddenImportButton;
    self.finishButton.hidden = [AliyunIConfig config].hiddenFinishButton;
    self.finishButton.enabled = NO;
    
    
    CGFloat y = 15.0;
    _backButton   = [self createButtonWithImage:[UIImage imageNamed:@"short_video_back"] ];
    _backButton.frame = CGRectMake(15, y, 44, 28);
    
    _nextButton = [self createButtonWithImage:NULL];
    [_nextButton setBackgroundColor:rgba(185, 175, 254, 1)];
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
    [_countDownButton addTarget:self action:@selector(countDownButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _countDownButton.frame = CGRectMake(x, CGRectGetMaxY(_nextButton.frame)+46, 28, 28);
    [_countDownButton setTitle:@"倒计时" forState:UIControlStateNormal];
    _countDownButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    _beautyButton = [self createButtonWithImage:[UIImage imageNamed:@"meiyan"] ];
    _beautyButton.frame = CGRectMake(x, CGRectGetMaxY(_countDownButton.frame)+38, 28, 28);
    [_beautyButton setTitle:@"美颜" forState:UIControlStateNormal];
    _beautyButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    _musicButton = [self createButtonWithImage:[UIImage imageNamed:@"music"]];
    _musicButton.frame = CGRectMake(x, CGRectGetMaxY(_beautyButton.frame)+38, 28, 28);
    [_musicButton setTitle:@"音乐" forState:UIControlStateNormal];
    _musicButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    _speedButton = [self createButtonWithImage:[UIImage imageNamed:@"biansu"]];
    [_speedButton addTarget:self action:@selector(speedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _speedButton.frame = CGRectMake(x, CGRectGetMaxY(_musicButton.frame)+38, 28, 28);
    [_speedButton setTitle:@"变速" forState:UIControlStateNormal];
    _speedButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_ratioButton addTarget:self action:@selector(ratioButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_beautyButton addTarget:self action:@selector(beautyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraButton addTarget:self action:@selector(cameraButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_flashButton addTarget:self action:@selector(flashButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_musicButton addTarget:self action:@selector(musicButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_ratioButton setImage:[AliyunImage imageNamed:@"record_ratio_dis"] forState:UIControlStateDisabled];
    [_beautyButton setImage:[UIImage imageNamed:@"meiyan"] forState:UIControlStateDisabled];
    [_cameraButton setImage:[AliyunImage imageNamed:@"camera_id_dis"] forState:UIControlStateDisabled];
    [_flashButton setImage:[AliyunImage imageNamed:@"camera_flash_dis"] forState:UIControlStateDisabled];
    [_beautyButton setImage:[AliyunImage imageNamed:@"meiyan"] forState:UIControlStateSelected];
    _beautyButton.selected = YES;
    _ratioButton.hidden = NO;

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
    _progressView.showBlink = YES;
}
    
-(void)updateHeight:(CGFloat)height {
    _height = height;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
    
- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    _recordButton.frame = CGRectMake((ScreenWidth/2.0-72/2.0), ScreenHeight-46-72, 72, 72);
    
    CGPoint center = _recordButton.center;
    _deleteButton.frame = CGRectMake(0, 0, 36, 36);
    _deleteButton.center = CGPointMake(center.x+36+58+18, center.y);
    
    _magicButton.frame = CGRectMake(0, 0, 36, 36);
    _magicButton.center = CGPointMake(center.x-36-58-18, center.y);
//    _deleteButton.center = CGPointMake(SizeWidth(55), centerY);
//    _finishButton.center = CGPointMake(w - SizeWidth(55), centerY);
//    _photoLibraryButton.center = CGPointMake(SizeWidth(55), centerY);
}
    
- (void)updateVideoDuration:(CGFloat)duration {
    [_progressView updateProgress:duration];
    if (duration >= _minDuration) {
        _finishButton.enabled = YES;
    } else {
        _finishButton.enabled = NO;
    }
    
    if (duration > 0 && _deleteButton.hidden && ![AliyunIConfig config].hiddenDeleteButton) {
        if (![AliyunIConfig config].hiddenDeleteButton) {
            _deleteButton.hidden = NO;
        }
        _photoLibraryButton.hidden = YES;
    }
    
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
    _progressView.showBlink = YES;
    
    _deleteButton.enabled = YES;
    
    if ([AliyunIConfig config].recordOnePart) {
        if (_delegate) {
            [_delegate bottomViewFinishVideo];
        }
    }
}
    
- (void)updateRecordTypeToEndRecord {
    [self.recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_normal"]forState:UIControlStateNormal];
    _recording = NO;
    _progressView.showBlink = YES;
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
                [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_suspend"]forState:UIControlStateNormal];
                
            }else{
                [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_normal"]forState:UIControlStateNormal];
            }
        }
        break;
        case AliyunIRecordActionTypeHold:
        [self endRecord];
        break;
        
        case AliyunIRecordActionTypeClick:
        if (_recording) {
            [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_suspend"]forState:UIControlStateNormal];
        }else{
            [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_normal"]forState:UIControlStateNormal];
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
    NSLog(@"delete   %d", self.deleteButton.selected);
    buttonClick.selected = !buttonClick.selected;
    if (buttonClick.selected) {
        _progressView.selectedIndex = _progressView.videoCount - 1;
    } else {
        _progressView.videoCount--;
        [_delegate bottomViewDeleteFinished];
        if (_progressView.videoCount <= 0) {
            if (![AliyunIConfig config].hiddenImportButton) {
                _photoLibraryButton.hidden = NO;
            }
            
            _deleteButton.hidden = YES;
        }
    }
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
        _recordButton.bounds = CGRectMake(0, 0, 60, 60);
        _recordButton.backgroundColor = [UIColor clearColor];
        _recordButton.adjustsImageWhenHighlighted = NO;
        [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_normal"]forState:UIControlStateNormal];
        _recordButton.layer.masksToBounds = YES;
        _recordButton.layer.cornerRadius = 30;
        [_recordButton addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchDragOutside];
    }
    return _recordButton;
}
    
- (QUProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[QUProgressView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 5)];
        _progressView.showBlink = YES;
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
        [_magicButton addTarget:self action:@selector(magicButtonClick:) forControlEvents:UIControlEventTouchUpInside];
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
    
- (void)setupBeautyStatus:(BOOL)isBeauty flashStatus:(NSInteger)flashStatus {
    
//    self.beautyButton.selected = isBeauty;
    //[self updateNavigationFlashStatus:flashStatus];
}
    
- (void)updateNavigationStatusWithDuration:(CGFloat)duration {
    if (duration > 0 && _ratioButton.enabled) {
        _ratioButton.enabled = NO;
    }
    if (duration <= 0 && !_ratioButton.enabled) {
        _ratioButton.enabled = YES;
    }
}
    
- (void)updateNavigationStatusWithRecord:(BOOL)isRecording {
    _flashButton.enabled  = !isRecording;
    _beautyButton.enabled = !isRecording;
    _cameraButton.enabled = !isRecording;
    _backButton.enabled = !isRecording;
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
    NSInteger status = [_delegate navigationFlashModeDidChanged];
    [self updateNavigationFlashStatus:status];
}
    
- (void)speedButtonClick:(UIButton *)button{
    [button setSelected:!button.isSelected];
    if(button.isSelected){
        self.rateView = [[AliyunRateSelectView alloc] initWithItems:@[@"极慢",@"慢",@"标准",@"快",@"极快"]];
        self.rateView.frame = CGRectMake(40, self.recordButton.frame.origin.y-40-20, ScreenWidth-80, 36);
        self.rateView.selectedSegmentIndex = 2;
        //[self.rateView addTarget:self action:@selector(rateChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.rateView];
    }else{
        [self rateChanged:self.rateView];
        [self.rateView removeFromSuperview];
    }
}
    
    - (void)countDownButtonClick:(UIButton *)button{
        ShotCountDownView *countDownView = [[ShotCountDownView alloc] init];
        countDownView.completeBlock = ^{
            [self recordButtonTouchUp];
        };
        [countDownView showWith:3];
    }

- (void)updateNavigationFlashStatus:(NSInteger)status {
    
    if (status == 0) {
        [_flashButton setImage:[UIImage imageNamed:@"sgd_close"] forState:0];
    } else if (status == 1) {
        [_flashButton setImage:[UIImage imageNamed:@"sgd_open"] forState:0];
    } else {
        [_flashButton setImage:[AliyunImage imageNamed:@"camera_flash_auto"] forState:0];
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
    _cameraButton.selected = !_cameraButton.selected;
    [_delegate navigationCamerationPositionDidChanged:_cameraButton.selected];
}
    
- (UIButton *)createButtonWithImage:(UIImage *)imageName{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:imageName forState:0];
    button.bounds = CGRectMake(0, 0, 40, 40);
    [self addSubview:button];
    return button;
}

- (void)rateChanged:(AliyunRateSelectView *)rateView {
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
