//
//  AliyunCropViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCropViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AVAsset+VideoInfo.h"
#import <AliyunVideoSDKPro/AliyunCrop.h>
#import <AliyunVideoSDKPro/AliyunImageCrop.h>
#import "AliyunCropThumbnailView.h"
#import "AliyunPhotoLibraryManager.h"
#import "AliyunCycleProgressView.h"
#import "AliyunCropViewBottomView.h"


static NSString *const PlayerItemStatus = @"_playerItem.status";

typedef NS_ENUM(NSInteger, AliyunCropPlayerStatus) {
    AliyunCropPlayerStatusPause,             // 结束或暂停
    AliyunCropPlayerStatusPlaying,           // 播放中
    AliyunCropPlayerStatusPlayingBeforeSeek  // 拖动之前是播放状态
};


@interface AliyunCropViewController ()<UIScrollViewDelegate, AliyunCropDelegate>

@property (nonatomic, strong) UIScrollView *previewScrollView;
@property (nonatomic, strong) AliyunCropThumbnailView *thumbnailView;
@property (nonatomic, strong) AliyunCropViewBottomView *bottomView;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) AliyunCycleProgressView *progressView;

@property (nonatomic, assign) CGFloat previewHeight;
@property (nonatomic, assign) CGFloat previewWidth;
@property (nonatomic, assign) CGPoint preViewOffset;

@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) CMTime currentTime;

@property (nonatomic, assign) CGFloat destRatio;
@property (nonatomic, assign) CGFloat orgVideoRatio;
@property (nonatomic, assign) CGSize originalMediaSize;

@property (nonatomic, strong) AliyunCrop *cutPanel;
@property (nonatomic, assign) BOOL shouldStartCut;
@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, assign) BOOL isCancel;
@property (nonatomic, assign) AliyunCropPlayerStatus playerStatus;

@property (nonatomic, assign) BOOL KVOHasRemoved;

@property (nonatomic, strong) CALayer *stillImageLayer;
@property (nonatomic, strong) UIImage *stillImage;


@end

@implementation AliyunCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
    
    
    
    if (_cutInfo.phAsset) {//是图片资源
        _originalMediaSize = CGSizeMake(_cutInfo.phAsset.pixelWidth, _cutInfo.phAsset.pixelHeight);
        _destRatio = _cutInfo.outputSize.width / _cutInfo.outputSize.height;
        _orgVideoRatio = _originalMediaSize.width / _originalMediaSize.height;
        [self setupStillImageLayer];
    } else {
        NSURL *sourceURL = [NSURL fileURLWithPath:_cutInfo.sourcePath];
        _avAsset = [AVAsset assetWithURL:sourceURL];
        _originalMediaSize = [_avAsset avAssetNaturalSize];
        _destRatio = _cutInfo.outputSize.width / _cutInfo.outputSize.height;
        _orgVideoRatio = _originalMediaSize.width / _originalMediaSize.height;
        
        [self setAVPlayer];
        [self addNotification];
        _thumbnailView.avAsset = _avAsset;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)setupSubViews {
    
    self.view.backgroundColor = [AliyunIConfig config].backgroundColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapGesture)];
    self.previewScrollView = [[UIScrollView alloc] init];
    self.previewScrollView.bounces = NO;
    
    self.previewScrollView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    self.previewScrollView.backgroundColor = _cutInfo.backgroundColor ? :[UIColor blackColor];
    self.previewScrollView.delegate = self;
    [self.view addSubview:self.previewScrollView];
    [self.previewScrollView addGestureRecognizer:tapGesture];
    
    UIButton *backButton = [self buttonWithRect:CGRectMake(15, 25, 24, 14) image:@"short_video_back" action:@selector(onClickBackButton)];
    [backButton sizeToFit];
    [self.view addSubview:backButton];
    
    UIButton *saveButton = [self buttonWithRect:CGRectMake(ScreenWidth - 89, 20, 64, 25) image:nil action:@selector(onClickCropButton)];
    [saveButton setTitle:@"下一步" forState:UIControlStateNormal];
    [saveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:15];
    saveButton.backgroundColor = rgba(127, 110, 241, 1);
    saveButton.layer.cornerRadius = 4;
    saveButton.clipsToBounds = true;
    [self.view addSubview:saveButton];
    
    if (!_cutInfo.phAsset) {
        self.thumbnailView = [[AliyunCropThumbnailView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 40 - ScreenWidth/8.0 - 12 - SafeBottom, ScreenWidth, ScreenWidth / 8 + 12) withCutInfo:_cutInfo];
        self.thumbnailView.delegate = (id<AliyunCutThumbnailViewDelegate>)self;
        [self.view addSubview:self.thumbnailView];
    }
    
//    self.bottomView = [[AliyunCropViewBottomView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 40 - SafeBottom, ScreenWidth, 40)];
//    self.bottomView.delegate = (id<AliyunCropViewBottomViewDelegate>)self;
//    [self.view addSubview:self.bottomView];
    
    if (!_cutInfo.phAsset) {
        self.progressView = [[AliyunCycleProgressView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        self.progressView.backgroundColor = [UIColor clearColor];
        self.progressView.center = self.view.center;
        self.progressView.progressColor = RGBToColor(230, 60, 91);
        self.progressView.progressBackgroundColor = RGBToColor(160, 168, 183);
        [self.view addSubview:self.progressView];
    }
}

- (UIButton *)buttonWithRect:(CGRect)rect image:(NSString *)imageName action:(SEL)sel
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)saveButtonClicked:(id)sender
{
}

- (void)setAVPlayer {
    _playerItem = [AVPlayerItem playerItemWithAsset:_avAsset];
    [self addObserver:self forKeyPath:PlayerItemStatus options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    _avPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    _avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    [_previewScrollView.layer addSublayer:_avPlayerLayer];
}

- (void)setupStillImageLayer {
    _stillImageLayer = [CALayer layer];
    [_previewScrollView.layer addSublayer:_stillImageLayer];
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:_cutInfo.phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (result.imageOrientation == UIImageOrientationUp)  { //fix:iOS8下图片会旋转的问题
            _stillImage = result;
            _stillImageLayer.contents = (__bridge id _Nullable)(result.CGImage);
        } else {
            UIGraphicsBeginImageContextWithOptions(result.size, NO, result.scale);
            [result drawInRect:(CGRect){0, 0, result.size}];
            UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            _stillImage = normalizedImage;
            _stillImageLayer.contents = (__bridge id _Nullable)(normalizedImage.CGImage);
        }
    }];
}

- (void)destoryAVPlayer {
    if (self.avPlayer) {
        self.avPlayer = nil;
        self.avPlayerLayer = nil;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self cropViewFitRect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cropViewFitRect {
    
    _previewHeight = ScreenWidth / _destRatio;
    
    CGRect frame = _previewScrollView.frame;
    frame.size.height = _previewHeight;
    if (_destRatio == 9.0/16.0) {
        frame.origin.y = SafeTop;
    }
    _previewScrollView.frame = frame;
    _previewScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    if (_cutInfo.cutMode) {
        // 1 : 裁剪
        [self.bottomView.ratioButton setImage:[AliyunImage imageNamed:@"cut_ratio"] forState:0];
        [self fitModeCut];
    } else {
        // 0 : 填充黑边
        [self.bottomView.ratioButton setImage:[AliyunImage imageNamed:@"normal"] forState:0];
        [self fitModeFill];
    }
}

- (void)fitModeCut {
    if (_orgVideoRatio > _destRatio) {
        _previewScrollView.contentSize = CGSizeMake(_previewHeight * _orgVideoRatio, _previewHeight);
        if (_cutInfo.phAsset) {
            _stillImageLayer.frame = CGRectMake(0, 0, _previewHeight * _orgVideoRatio, _previewHeight);
        } else {
            _avPlayerLayer.frame = CGRectMake(0, 0, _previewHeight * _orgVideoRatio, _previewHeight);
        }
        [_previewScrollView setContentOffset:CGPointMake((_previewHeight *_orgVideoRatio - ScreenWidth)/2.0, 0)];
    } else {
        _previewScrollView.contentSize = CGSizeMake(ScreenWidth, ScreenWidth / _orgVideoRatio);
        if (_cutInfo.phAsset) {
            _stillImageLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth / _orgVideoRatio);
        } else {
            _avPlayerLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth / _orgVideoRatio);
        }
        
        [_previewScrollView setContentOffset:CGPointMake(0, (ScreenWidth / _orgVideoRatio - _previewHeight) / 2.0)];
    }
    _preViewOffset = _previewScrollView.contentOffset;
}

- (void)fitModeFill {
    _previewScrollView.contentSize = CGSizeMake(0, 0);
    
    if (_cutInfo.phAsset) {
        
        if (_orgVideoRatio > _destRatio) {
            //上下黑
            CGFloat top = (CGRectGetHeight(_previewScrollView.bounds) - ScreenWidth / _orgVideoRatio) / 2;
            _stillImageLayer.frame = CGRectMake(0, top, ScreenWidth, ScreenWidth / _orgVideoRatio);
            
        } else {
            //左右黑
            CGFloat left = (CGRectGetWidth(_previewScrollView.bounds) - CGRectGetHeight(_previewScrollView.bounds) * _orgVideoRatio) / 2;
            _stillImageLayer.frame = CGRectMake(left, 0, _orgVideoRatio * CGRectGetHeight(_previewScrollView.bounds) , CGRectGetHeight(_previewScrollView.bounds));
        }
        
    } else {
        _avPlayerLayer.frame = _previewScrollView.bounds;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _preViewOffset = scrollView.contentOffset;
    if (_shouldStartCut) {
        [self didStartClip];
        _shouldStartCut = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _preViewOffset = scrollView.contentOffset;
}

#pragma mark --- AliyunCropDelegate

- (void)cropTaskOnProgress:(float)progress {
    NSLog(@"~~~~~progress:%@", @(progress));
    if (_isCancel) {
        return;
    } else {
        self.progressView.progress = progress;
    }
}

- (void)cropOnError:(int)error {
    NSLog(@"~~~~~~~crop error:%@", @(error));
    if (_isCancel) {
        _isCancel = NO;
    } else {
        _hasError = YES;
        NSString *err = [NSString stringWithFormat:@"错误码: %d",error];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪失败" message:err delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        self.thumbnailView.userInteractionEnabled = YES;
        self.progressView.progress = 0;
        self.bottomView.cropButton.userInteractionEnabled = YES;
        [self destoryAVPlayer];
        [self setAVPlayer];
 
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [_cutPanel cancel];
    _alertView = nil;
    _hasError = YES;
}

- (void)cropTaskOnComplete {
    NSLog(@"TestLog, %@:%@", @"log_crop_complete_time", @([NSDate date].timeIntervalSince1970));
    self.progressView.progress = 0;
    if (_isCancel) {
        _isCancel = NO;
    } else {
        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
        _alertView = nil;
        if (_hasError) {
            _hasError = NO;
            return;
        }
        
        if (self.delegate) {
            [self.delegate cropViewControllerFinish:self.cutInfo viewController:self];
        }
    }
}

- (void)cropTaskOnCancel {
    NSLog(@"cancel");
}

#pragma mark ---

- (void)photoCrop {
    AliyunImageCrop *imageCrop = [[AliyunImageCrop alloc] init];
    imageCrop.originImage = _stillImage;
    imageCrop.cropMode = (AliyunImageCropMode)_cutInfo.cutMode;
    imageCrop.outputSize = _cutInfo.outputSize;
    imageCrop.fillBackgroundColor = _cutInfo.backgroundColor;
    
    if (_cutInfo.cutMode == 1) {
        imageCrop.cropRect = [self configureReservationRect];
    }
    
    UIImage *image = [imageCrop generateImage];
    
    self.cutInfo.phImage = image;
    
    if (self.delegate) {
        [self.delegate cropViewControllerFinish:self.cutInfo viewController:self];
    }
}

- (void)didStartClip {
//    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSString *mp3Path = [[NSBundle mainBundle] pathForResource:@"music/Axol" ofType:@"mp3"];
//    NSString *tmp32Path = [documentPath stringByAppendingPathComponent:@"22222.mp3"];
//    NSError *error = nil;
//    [[NSFileManager defaultManager] copyItemAtPath:mp3Path toPath:tmp32Path error:&error];
//    NSLog(@"~~~errr:%@", error);
//    NSString *mp32Path = [documentPath stringByAppendingPathComponent:@"1111.mp3"];
    
    [self pauseVideo];
    self.thumbnailView.userInteractionEnabled = NO;
    if (_previewScrollView.isDragging) {
        _shouldStartCut = YES;
        return;
    }

    if (_fakeCrop) {
        if (self.delegate) {
            [self.delegate cropViewControllerFinish:self.cutInfo viewController:self];
        }
        return;
    }

    if (_cutPanel) {
        [_cutPanel cancel];
    }
    _cutPanel = [[AliyunCrop alloc] init];
    _cutPanel.delegate = (id<AliyunCropDelegate>)self;
//    _cutPanel.inputPath = tmp32Path;
//    _cutPanel.outputPath = mp32Path;
    _cutPanel.inputPath = _cutInfo.sourcePath;
    _cutPanel.outputPath = _cutInfo.outputPath;

    _cutPanel.outputSize = _cutInfo.outputSize;
    _cutPanel.fps = _cutInfo.fps;
    _cutPanel.gop = _cutInfo.gop;
    _cutPanel.bitrate = _cutInfo.bitrate;
    _cutPanel.videoQuality = (AliyunVideoQuality)_cutInfo.videoQuality;

    if (_cutInfo.cutMode == 1) {
        _cutPanel.rect = [self evenRect:[self configureReservationRect]];
    }
    _cutPanel.cropMode = (AliyunCropCutMode)_cutInfo.cutMode;
    
    _cutPanel.startTime = _cutInfo.startTime;
    _cutPanel.endTime = _cutInfo.endTime;
    
//    _cutPanel.startTime = 0;
//    _cutPanel.endTime = 5;
    
    _cutPanel.fadeDuration = 0;
    _cutPanel.gop = _cutInfo.gop;
    _cutPanel.fps = _cutInfo.fps;
    _cutPanel.videoQuality = (AliyunVideoQuality)_cutInfo.videoQuality;
    _cutPanel.encodeMode = _cutInfo.encodeMode;
    _cutPanel.fillBackgroundColor = _cutInfo.backgroundColor;
    _cutPanel.useHW = _cutInfo.gpuCrop;

    NSLog(@"TestLog, %@:%@", @"log_crop_start_time", @([NSDate date].timeIntervalSince1970));

    [_cutPanel startCrop];
    _isCancel = NO;
    _hasError = NO;
}
//裁剪必须为偶数
- (CGRect)evenRect:(CGRect)rect {
    return CGRectMake((int)rect.origin.x / 2 * 2, (int)rect.origin.y / 2 * 2, (int)rect.size.width / 2 * 2, (int)rect.size.height / 2 * 2);
}


- (CGRect)configureReservationRect {
    CGFloat x = 0, y = 0, w = 0, h = 0;
    y = _preViewOffset.y;
    if (_orgVideoRatio > _destRatio) {
        if (_preViewOffset.x == 0 || _previewScrollView.contentSize.width == 0 ||_originalMediaSize.width == 0) {
            x = 0;
        } else {
            x = _preViewOffset.x / _previewScrollView.contentSize.width * _originalMediaSize.width;
        }
        h = _originalMediaSize.height;
        w = h * _destRatio;
    } else {
        if (_preViewOffset.y == 0 || _previewScrollView.contentSize.height == 0 ||_originalMediaSize.height == 0) {
            y = 0;
        } else {
            y = _preViewOffset.y / _previewScrollView.contentSize.height * _originalMediaSize.height;
        }
        w = _originalMediaSize.width;
        h = _originalMediaSize.width / _destRatio;
    }
    if (!y) {
        y = 0;
    }
    return CGRectMake(x, y, w, h);
}

- (void)didStopCut {
    self.progressView.progress = 0;
    self.thumbnailView.userInteractionEnabled = YES;
    self.bottomView.cropButton.userInteractionEnabled = YES;
    [_cutPanel cancel];
    _isCancel = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:PlayerItemStatus]) {
        AVPlayerItemStatus status = _playerItem.status;
        if (status == AVPlayerItemStatusReadyToPlay) {
            _cutInfo.sourceDuration = [_playerItem.asset avAssetVideoTrackDuration];
            if (_cutInfo.endTime == 0) {
                _cutInfo.startTime = 0.0;
                _cutInfo.endTime = _cutInfo.sourceDuration;
            }
            _playerStatus = AliyunCropPlayerStatusPlayingBeforeSeek;
            [self playVideo];
            [_thumbnailView loadThumbnailData];
            [self removeObserver:self forKeyPath:PlayerItemStatus];
            _KVOHasRemoved = YES;
        }else if (status == AVPlayerItemStatusFailed){
            NSLog(@"系统播放器无法播放视频=== %@",keyPath);
        }
    }
}

- (void)previewTapGesture {
    if (_playerStatus == AliyunCropPlayerStatusPlaying) {
        [self pauseVideo];
    } else {
        [self playVideo];
    }
}

- (void)playVideo {
    
    if (_playerStatus == AliyunCropPlayerStatusPlayingBeforeSeek) {
        [_avPlayer seekToTime:CMTimeMake(_cutInfo.startTime * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    
    [_avPlayer play];
    _playerStatus = AliyunCropPlayerStatusPlaying;
    
    if (_timeObserver) return;
    __weak typeof(self) weakSelf = self;
    _timeObserver = [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 10)
                                                            queue:dispatch_get_main_queue()
                                                       usingBlock:^(CMTime time) {
                                                           
                                                           __strong typeof(self) strong = weakSelf;
                                                           CGFloat crt = CMTimeGetSeconds(time);
                                                           
                                                           if (strong.cutInfo.sourceDuration) {
                                                               [strong.thumbnailView updateProgressViewWithProgress:crt/strong.cutInfo.sourceDuration];
                                                           }
                                                       }];
}

- (void)pauseVideo {
    if (_playerStatus == AliyunCropPlayerStatusPlaying) {
        _playerStatus = AliyunCropPlayerStatusPause;
        [_avPlayer pause];
        [_avPlayer removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

- (void)cutBarDidMovedToTime:(CGFloat)time {
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [_avPlayer seekToTime:CMTimeMake(time * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        if (_playerStatus == AliyunCropPlayerStatusPlaying) {
            [_avPlayer pause];
            _playerStatus = AliyunCropPlayerStatusPlayingBeforeSeek;
        }
    }
}

- (void)cutBarTouchesDidEnd {
    _playerItem.forwardPlaybackEndTime = CMTimeMake(_cutInfo.endTime * 1000, 1000);
    if (_playerStatus == AliyunCropPlayerStatusPlayingBeforeSeek) {
        [self playVideo];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [_avPlayer pause];
    AVPlayerItem *p = [notification object];
    [p seekToTime:CMTimeMake(_cutInfo.startTime * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [_avPlayer play];
    _playerStatus = AliyunCropPlayerStatusPlaying;
}

#pragma mark - Notification

- (void)addNotification {
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    _avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_avPlayer.currentItem];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self didStopCut];

   // sleep(1);
    [self pauseVideo];
//    _isCancel = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {

    [self playVideo];
}

#pragma mark - Actions
- (void)onClickBackButton {
    [self pauseVideo];
    [self didStopCut];
//    [_delegate cropViewControllerExit];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)onClickRatioButton {
    _cutInfo.cutMode = !_cutInfo.cutMode;
    [self cropViewFitRect];
}


- (void)onClickCropButton {
    
    if (_cutInfo.phAsset) {
        [self photoCrop];
    } else {
        [self didStartClip];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pauseVideo];
}

- (void)dealloc {
    if (!_cutInfo.phAsset) {
        if (_timeObserver) {
            [_avPlayer removeTimeObserver:_timeObserver];
        }
        
        if (!_KVOHasRemoved) {
            [self removeObserver:self forKeyPath:PlayerItemStatus];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
}

@end
