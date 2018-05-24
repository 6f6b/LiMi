//
//  ViewController.m
//  AliyunVideo
//
//  Created by Vienta on 2016/12/29.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMagicCameraViewController.h"
#import <AliyunVideoSDKPro/AliyunIRecorder.h>
#import "AliyunMagicCameraView.h"
#import <AVFoundation/AVFoundation.h>
//#import "AliyunFace.h"
#import <AliyunVideoSDKPro/AliyunFacePoint.h>
#import <AliyunVideoSDKPro/AliyunEffectFilter.h>
#import <AliyunVideoSDKPro/AliyunEffectPaster.h>
#import "AliyunVideoPreViewController.h"
#import <AliyunVideoSDKPro/AliyunClipManager.h>
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "AliyunPasterInfoGroup.h"
#import "AliyunPasterInfo.h"
#import "AliyunDownloadManager.h"
#import "AliyunMagicCameraEffectCell.h"
#import <CoreMotion/CoreMotion.h>
#import "AliyunResourceManager.h"
#import "AliyunMusicPickViewController.h"
#import "AliyunPathManager.h"
#import "QUMBProgressHUD.h"
#import "AliyunBeibeiTexture.h"
#import "AliyunEffectMVView.h"
//#import "FaceAR.h"


@interface AliyunMagicCameraViewController () <AliyunMusicPickViewControllerDelegate>

@property (nonatomic, assign) CGFloat lastPinchDistance;
@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, strong) AliyunIRecorder *recorder;
@property (nonatomic, strong) AliyunMagicCameraView *magicCameraView;
//@property (nonatomic, strong) AliyunFace *face;
@property (nonatomic, strong) NSMutableArray *effectFilterItems;
@property (nonatomic, strong) NSMutableArray<AliyunPasterInfo*> *effectGifItems;
@property (nonatomic, strong) AliyunDownloadManager *downloadManager;
@property (nonatomic, strong) AliyunResourceManager *resourceManager;
@property (nonatomic, strong) NSMutableArray *allPasterInfoArray;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) AliyunIRecorderCameraPosition lastCameraPosition;
//@property (nonatomic, strong) FaceAR *faceAR;
@property (nonatomic, strong) AliyunEffectMVView *mvView;
@property (nonatomic, strong) UIButton *backgroundTouchButton;

@end

@implementation AliyunMagicCameraViewController
{
    CGSize _videoSize;
    AliyunEffectPaster *_currentEffectPaster;
    AliyunClipManager *_clipManager;
    CFTimeInterval _recordingDuration;
//    AliyunPasterInfoGroup *_demoPasterInfoGroup;
    BOOL _suspend;
    AliyunBeibeiTexture *_beibeiTexture;
}

- (void)setVideoSize:(CGSize)size
{
    _videoSize = size;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _videoSize = CGSizeMake(540, 960);
        _beauty = YES;
        _faceTrack = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
//    _videoSize = CGSizeMake(480, 480);
    self.magicCameraView = [[AliyunMagicCameraView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) videoSize:_videoSize];
    self.magicCameraView.delegate = (id)self;
    self.view = self.magicCameraView;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *videoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/testVideo/preview.mp4"];
    NSString *taskPath = [AliyunPathManager createMagicRecordDir];
    if ([[NSFileManager defaultManager] fileExistsAtPath:taskPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:taskPath error:nil];
    }
    //录制
    _recorder = [[AliyunIRecorder alloc] initWithDelegate:self videoSize:_videoSize];
    _recorder.preview = self.magicCameraView.previewView;
    _recorder.outputPath = videoPath;
    _recorder.outputType = AliyunIRecorderVideoOutputPixelFormatType420f;//人脸识别只支持YUV格式
    _recorder.taskPath = taskPath;
    _recorder.beautifyStatus = self.beauty;
    _recorder.beautifyValue = 80;
    _recorder.useFaceDetect = YES;
    _recorder.backCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    _recorder.frontCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    _recorder.faceDetectCount = 2;
    _recorder.faceDectectSync = NO;
    //录制片段设置
    _clipManager = _recorder.clipManager;
    _clipManager.maxDuration = 15;
    _clipManager.minDuration = 0.5;
    
    self.magicCameraView.maxDuration = _clipManager.maxDuration;
    _lastCameraPosition = AliyunIRecorderCameraPositionFront;
    [UIApplication sharedApplication].idleTimerDisabled = YES;


    //self.face = [[AliyunFace alloc] init];
//    self.faceAR = [[FaceAR alloc] initWithDimension:CGSizeMake(480, 640) gpuRender:YES];
    
    [self addGesture];
    [self addNotification];
    [self setupFilterEffectData];
    [self fetchData];
    
//    [self testButtons];
}

- (void)testButtons {
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20, 80, 60, 20);
    [btn1 setTitle:@"1" forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    btn1.tag = 1;
    btn1.backgroundColor = [UIColor grayColor];
    [btn1 addTarget:self action:@selector(tapTestButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(20, 120, 60, 20);
    [btn2 setTitle:@"2" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    btn2.tag = 2;
    btn2.backgroundColor = [UIColor grayColor];
    [btn2 addTarget:self action:@selector(tapTestButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(20, 160, 60, 20);
    [btn3 setTitle:@"3" forState:UIControlStateNormal];
    btn3.backgroundColor = [UIColor grayColor];
    [self.view addSubview:btn3];
    btn3.tag = 3;
    [btn3 addTarget:self action:@selector(tapTestButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(20, 200, 50, 40)];
    [self.view addSubview:sw];
    sw.on = YES;
    [sw addTarget:self action:@selector(sw:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sw:(UISwitch *)sw {
    _recorder.faceDectectSync = sw.on;
}

- (void)tapTestButton:(UIButton *)btn {
    _recorder.faceDetectCount = (int)btn.tag;
}

- (void)recorderDeviceAuthorization:(AliyunIRecorderDeviceAuthor)status {
    if (status == 1) {
        [self showAlertViewWithWithTitle:@"麦克风无权限"];
    } else if (status == 2) {
        [self showAlertViewWithWithTitle:@"摄像头无权限"];
    }
}

- (void)showAlertViewWithWithTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"打开相机失败" message:title delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupFaceRotate
{
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    //实时获取设备旋转
    _motionManager.deviceMotionUpdateInterval = 1.0;
    __weak typeof(self) weakSelf = self;
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        CMDeviceMotion *deviceMotion = _motionManager.deviceMotion;
        if (deviceMotion) {
            /*
            AliYun_CLOCKWISE_ROTATE rotate = AliYun_CLOCKWISE_ROTATE_0;
            double gravityX = -deviceMotion.gravity.x;
            double gravityY = deviceMotion.gravity.y;
            
            
            double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;//手机旋转角度。
            //double zTheta = atan2(gravityZ,sqrtf(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0;//与水平方向角度

            BOOL isMirror = _recorder.cameraPosition == AliyunIRecorderCameraPositionFront;

            if (xyTheta >= -45 && xyTheta <= 45) {
                //down
                rotate = AliYun_CLOCKWISE_ROTATE_180;
            } else if (xyTheta > 45 && xyTheta < 135) {
                //left
                rotate = isMirror ? AliYun_CLOCKWISE_ROTATE_90  : AliYun_CLOCKWISE_ROTATE_270;
            } else if ((xyTheta >= 135 && xyTheta < 180) || (xyTheta >= -180 && xyTheta < -135)) {
                //up
                rotate = AliYun_CLOCKWISE_ROTATE_0;
            } else if (xyTheta >= -135 && xyTheta < -45) {
                //right
                rotate = isMirror ?  AliYun_CLOCKWISE_ROTATE_270: AliYun_CLOCKWISE_ROTATE_90;
            }
            weakSelf.face.cameraRotate = rotate;
             */
        }
    }];
}

- (void)addGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocusPoint:)];
    [_recorder.preview addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [_recorder.preview addGestureRecognizer:pinchGesture];
    
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightGesture:)];
    [_recorder.preview addGestureRecognizer:swipeGestureRight];
    swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftGesture:)];
    [_recorder.preview addGestureRecognizer:swipeGestureLeft];
    swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)appWillResignActive:(id)sender
{
    if ([_recorder isRecording]) {
        [_recorder stopRecording];
        [_recorder stopPreview];
        _suspend = YES;
    }
}

- (void)appDidBecomeActive:(id)sender
{
    if (_suspend) {
        _suspend = NO;
//        AliyunVideoPreViewController *videoPre = [[AliyunVideoPreViewController alloc] init];
//        videoPre.videoPath = _recorder.outputPath;
//        [self.navigationController pushViewController:videoPre animated:YES];
        [_magicCameraView.srollView hiddenScroll:NO];
        _magicCameraView.hide = NO;
        [_recorder startPreview];
    }
}

- (void)setupFilterEffectData
{
    NSArray *filters = @[@"炽黄",@"粉桃",@"海蓝",@"红润",@"灰白",
                         @"经典",@"麦茶",@"浓烈",@"柔柔",@"闪耀",
                         @"鲜果",@"雪梨",@"阳光",@"优雅",@"朝阳",
                         @"波普",@"光圈",@"海盐",@"黑白",@"胶片",
                         @"焦黄",@"蓝调",@"迷糊",@"思念",@"素描",
                         @"鱼眼",@"马赛克",@"模糊"];
    
    [self.effectFilterItems removeAllObjects];
    
    AliyunEffectFilter *effectFilter1 = [[AliyunEffectFilter alloc] init];
    [self.effectFilterItems addObject:effectFilter1];//作为空效果
    for (int idx = 0; idx < [filters count]; idx++ ){
        NSString *filterName = [NSString stringWithFormat:@"filter/%@",filters[idx]];
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filterName ofType:nil];
        AliyunEffectFilter *effectFilter = [[AliyunEffectFilter alloc] initWithFile:path];
        
        [self.effectFilterItems addObject:effectFilter];
    }
}

- (void)setupPasterEffectData
{
    
    AliyunPasterInfo *empty1 = [[AliyunPasterInfo alloc] init];
    AliyunPasterInfo *empty2 = [[AliyunPasterInfo alloc] init];
    
    NSString *filterName = [NSString stringWithFormat:@"hanfumei-800"];
    NSString *path = [[NSBundle mainBundle] pathForResource:filterName ofType:nil];
    
    AliyunPasterInfo *paster = [[AliyunPasterInfo alloc] initWithBundleFile:path];

    [self.effectGifItems removeAllObjects];
    [self.effectGifItems addObject:empty1];
    [self.effectGifItems addObject:paster];
    [self.effectGifItems addObjectsFromArray:self.allPasterInfoArray];
    [self.effectGifItems addObject:empty2];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.magicCameraView loadEffectData:self.effectGifItems];
    });
    
}

- (void)fetchData
{
    [self.allPasterInfoArray removeAllObjects];
    AliyunHttpClient *httpClient = [[AliyunHttpClient alloc] initWithBaseUrl:kQPResourceHostUrl];
    NSDictionary *param = @{@"bundleId":@"com.duanqu.qusdkdemo"};
    [httpClient GET:@"api/res/prepose" parameters:param completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error) {
            NSArray *groups = [self loadLocalData];
            
            if (groups.count > 0) {
                AliyunPasterInfoGroup *pasterInfoGroup = [groups objectAtIndex:0];
                
                self.allPasterInfoArray = [NSMutableArray arrayWithArray:pasterInfoGroup.pasterList];
            }
            [self setupPasterEffectData];
            
            return ;
        }
        
        if (![responseObject isKindOfClass:[NSArray class]]) {
            return;
        }
        
        for (NSDictionary *dict in responseObject) {
            AliyunPasterInfoGroup *group = [[AliyunPasterInfoGroup alloc] initWithDictionary:dict error:nil];
            
            for (AliyunPasterInfo *info in group.pasterList) {
                info.groupName = group.name;
                [self.allPasterInfoArray addObject:info];
            }
        }
        
        [self setupPasterEffectData];
    }];
}

- (NSArray *)loadLocalData
{
    return [self.resourceManager loadLocalFacePasters];
}

- (void)appDidEnterBackground:(NSNotification *)noti
{
    [_recorder stopPreview];
}

- (void)appWillEnterForeground:(NSNotification *)noti
{
    if ([self.navigationController.childViewControllers lastObject] != self) {
        return;
    }
    
    
    [_recorder startPreview];
//    _magicCameraView.flashButton.userInteractionEnabled = (_recorder.cameraPosition != 0);
    
    AliyunIRecorderTorchMode mode = _recorder.torchMode;
    if (mode == AliyunIRecorderTorchModeOn) {
//        [_magicCameraView.flashButton setImage:[AliyunImage imageNamed:@"camera_flash_on"] forState:0];
    } else if (mode == AliyunIRecorderTorchModeOff) {
//        [_magicCameraView.flashButton setImage:[AliyunImage imageNamed:@"camera_flash_close"] forState:0];
    } else {
//        [_magicCameraView.flashButton setImage:[AliyunImage imageNamed:@"camera_flash_auto"] forState:0];
    }
    
    [self setupFaceRotate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFaceRotate];
    [_recorder startPreviewWithPositon:_lastCameraPosition];
//    [self.magicCameraView recordingPercent:0];
    _magicCameraView.hide = NO;
//    [_magicCameraView.progressView reset];
//    [_magicCameraView.flashButton setImage:[AliyunImage imageNamed:@"camera_flash_close"] forState:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_recorder stopPreview];
    [_motionManager stopDeviceMotionUpdates];
}

- (void)dealloc
{
    NSLog(@"~~~~~~%s delloc", __PRETTY_FUNCTION__);
    [_recorder destroyRecorder];
    _recorder = nil;
//    [self.faceAR destroy];
//    self.faceAR = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)tapToFocusPoint:(UITapGestureRecognizer *)tapGesture {
    UIView *tapView = tapGesture.view;
    CGPoint point = [tapGesture locationInView:tapView];
    self.recorder.focusPoint = point;
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.numberOfTouches != 2) {
        return;
    }
    CGPoint p1 = [pinchGesture locationOfTouch:0 inView:_recorder.preview];
    CGPoint p2 = [pinchGesture locationOfTouch:1 inView:_recorder.preview];
    CGFloat dx = (p2.x - p1.x);
    CGFloat dy = (p2.y - p1.y);
    CGFloat dist = sqrt(dx*dx + dy*dy);
    
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        _lastPinchDistance = dist;
    }
    CGFloat change = dist - _lastPinchDistance;
    change = change / (CGRectGetWidth(_recorder.preview.bounds) * 0.8) * 2.0;
    _recorder.videoZoomFactor = change;
    _lastPinchDistance = dist;
}

static int filterIdx = 0;

- (void)swipeRightGesture:(id)sender
{
    ++filterIdx;
    if (filterIdx >= [self.effectFilterItems count]) {
        filterIdx = 0;
    }
    [self displayFilterWithIndex:filterIdx];
}

- (void)swipeLeftGesture:(id)sender
{
    --filterIdx;
    if (filterIdx < 0) {
        filterIdx = (int)[self.effectFilterItems count] - 1;
    }
    [self displayFilterWithIndex:filterIdx];
}

- (void)displayFilterWithIndex:(int)index
{
    AliyunEffectFilter *effectFilter = [self.effectFilterItems objectAtIndex:index];
    [_recorder applyFilter:effectFilter];
    
    [self.magicCameraView displayFilterName:effectFilter.name];
}

#pragma mark - Getter -
- (NSMutableArray *)effectFilterItems
{
    if (!_effectFilterItems) {
        _effectFilterItems = [[NSMutableArray alloc] init];
    }
    return _effectFilterItems;
}

- (NSMutableArray *)effectGifItems
{
    if (!_effectGifItems) {
        _effectGifItems = [[NSMutableArray alloc] init];
    }
    return _effectGifItems;
}

- (AliyunDownloadManager *)downloadManager
{
    if (!_downloadManager) {
        _downloadManager = [[AliyunDownloadManager alloc] init];
    }
    return _downloadManager;
}

- (AliyunResourceManager *)resourceManager
{
    if (!_resourceManager) {
        _resourceManager = [[AliyunResourceManager alloc] init];
    }
    return _resourceManager;
}

- (NSMutableArray *)allPasterInfoArray
{
    
    if (!_allPasterInfoArray) {
        _allPasterInfoArray = [[NSMutableArray alloc] init];
    }
    return _allPasterInfoArray;
}

#pragma mark - MagicCameraViewDelegate -
- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)flashButtonClicked
{
    AliyunIRecorderTorchMode mode = [_recorder switchTorchMode];
    if (mode == AliyunIRecorderTorchModeOn) {
        return @"QPSDK.bundle/camera_flash_on";
    } else if (mode == AliyunIRecorderTorchModeOff) {
        return @"QPSDK.bundle/camera_flash_close";
    } else {
        return @"QPSDK.bundle/camera_flash_auto";
    }
}

- (void)cameraIdButtonClicked
{
    [_recorder switchCameraPosition];
    _lastCameraPosition = _recorder.cameraPosition;
//    _magicCameraView.flashButton.userInteractionEnabled = (_recorder.cameraPosition != 0);
    
    AliyunIRecorderTorchMode mode = _recorder.torchMode;
    if (mode == AliyunIRecorderTorchModeOn) {
//        [_magicCameraView.flashButton setImage:[AliyunImage imageNamed:@"camera_flash_on"] forState:0];
    } else if (mode == AliyunIRecorderTorchModeOff) {
//        [_magicCameraView.flashButton setImage:[AliyunImage imageNamed:@"camera_flash_close"] forState:0];
    } else {
//        [_magicCameraView.flashButton setImage:[AliyunImage imageNamed:@"camera_flash_auto"] forState:0];
    }

}

- (void)musicButtonClicked
{
    [self pausePreview];
    AliyunMusicPickViewController *vc = [[AliyunMusicPickViewController alloc] init];
    vc.duration = _clipManager.maxDuration;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pausePreview {
    [_recorder stopPreview];
    [_motionManager stopDeviceMotionUpdates];
}

- (void)resumePreview {
    [self setupFaceRotate];
    [_recorder startPreviewWithPositon:_lastCameraPosition];
    _magicCameraView.hide = NO;
//    [_magicCameraView.flashButton setImage:[AliyunImage imageNamed:@"camera_flash_close"] forState:0];
}

- (void)mvButtonClicked {
    [self presentBackgroundButton];
    [self showEffectView:self.mvView duration:0.2];
    [self.mvView reloadDataWithEffectType:3];//MV
}

- (AliyunEffectMVView *)mvView {
    if (!_mvView) {
        _mvView = [[AliyunEffectMVView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 142)];
        _mvView.delegate = (id<AliyunEffectFilterViewDelegate>)self;
        _mvView.frontMV = YES;
        [self.view addSubview:_mvView];
    }
    return _mvView;
}

- (void)showEffectView:(UIView *)view duration:(CGFloat)duration {
    view.hidden = NO;
    [self.view bringSubviewToFront:view];
//    [self dismissTopView];
    [UIView animateWithDuration:duration animations:^{
        CGRect f = view.frame;
        f.origin.y = ScreenHeight - CGRectGetHeight(f)-SafeBottom;
        view.frame = f;
    }];
}

- (void)presentBackgroundButton
{
    [self dismissBackgroundButton];
    self.backgroundTouchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backgroundTouchButton.frame = self.view.bounds;
    self.backgroundTouchButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3];
    [self.backgroundTouchButton addTarget:self action:@selector(backgroundTouchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backgroundTouchButton];
}

- (void)dismissBackgroundButton
{
    [self.backgroundTouchButton removeFromSuperview];
    self.backgroundTouchButton = nil;
}

- (void)backgroundTouchButtonClicked:(id)sender
{
    [self dismissBackgroundButton];
    [self dismissEffectView:self.mvView duration:.2];
}

- (void)dismissEffectView:(UIView *)view duration:(CGFloat)duration {
    [self dismissBackgroundButton];
    [UIView animateWithDuration:duration animations:^{
        CGRect f = view.frame;
        f.origin.y = ScreenHeight;
        view.frame = f;
    } completion:^(BOOL finished) {
        view.hidden = YES;
    }];
}

- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup {
    if (mvGroup == NULL) {//点击原片 清掉所有mv效果
        [self.recorder applyMV:nil];
        return;
    }
    
    float aspects[5] = {9/16.0, 3/4.0, 1.0, 4/3.0,16/9.0};
    CGSize fixedSize = _videoSize;
    float videoAspect = fixedSize.width/fixedSize.height;
    int index = 0;
    for (int i = 0; i < 5; i++) {
        index = i;
        if (videoAspect <= aspects[i]) break;
    }
    if (index > 0) {
        if (fabsf(videoAspect - aspects[index]) > fabsf(videoAspect-aspects[index-1])) {
            index = index-1;
        }
    }
    
    NSString *str = [mvGroup localResoucePathWithVideoRatio:index];
    
    if (str) {
        [self.recorder applyMV:[[AliyunEffectMV alloc] initWithFile:str]];
    }
}



-(void)deleteButtonClicked {
    [_clipManager deletePart];
//    _magicCameraView.progressView.videoCount--;
    CGFloat percent = _clipManager.duration / _clipManager.maxDuration;
    [self.magicCameraView recordingPercent:percent];
    _recordingDuration = _clipManager.duration;
//    _magicCameraView.finishButton.enabled = [_clipManager partCount];
//    _magicCameraView.musicButton.enabled = ![_clipManager partCount];
//    _magicCameraView.mvButton.enabled = ![_clipManager partCount];
}

- (void)finishButtonClicked {
    if ([_clipManager partCount]) {
        [QUMBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_recorder finishRecording];
    }
}

- (CGFloat)cameraRotate {
    return 0;
    /*
    switch (self.face.cameraRotate) {
        case AliYun_CLOCKWISE_ROTATE_0:
            return 0;
        case AliYun_CLOCKWISE_ROTATE_90:
            if (_recorder.cameraPosition == AliyunIRecorderCameraPositionFront) {
                return 270;
            }
            return 90;
            
        case AliYun_CLOCKWISE_ROTATE_180:
            return 180;
        case AliYun_CLOCKWISE_ROTATE_270:
            if (_recorder.cameraPosition == AliyunIRecorderCameraPositionFront) {
                return 90;
            }
            return 270;
        default:
            return 0;
    }
     */
}

- (void)recordButtonTouchesBegin
{
    NSLog(@"vvvv %s", __PRETTY_FUNCTION__);
    _recorder.cameraRotate = [self cameraRotate];
    [_recorder startRecording];
    [_magicCameraView.srollView hiddenScroll:YES];
    _magicCameraView.hide = YES;
    
}

- (void)recordButtonTouchesEnd
{
    NSLog(@"vvvv %s", __PRETTY_FUNCTION__);
    [_recorder stopRecording];
    [_magicCameraView.srollView hiddenScroll:NO];
    _magicCameraView.hide = NO;
}

- (void)effectItemFocusToIndex:(NSInteger)index cell:(UICollectionViewCell *)cell
{
    AliyunPasterInfo *pasterInfo = [self.effectGifItems objectAtIndex:index];
    if (pasterInfo.eid <= 0) {
        [self deleteCurrentEffectPaster];
        return;
    }
    
    if (pasterInfo.bundlePath != nil) {
        [self addEffectWithPath:pasterInfo.bundlePath];
        return;
    }
    
    BOOL isExist = [pasterInfo fileExist];
    
    if (!isExist) {
        AliyunDownloadTask *task = [[AliyunDownloadTask alloc] initWithInfo:pasterInfo];
        [self.downloadManager addTask:task];
        
        
        AliyunMagicCameraEffectCell *effectCell = (AliyunMagicCameraEffectCell *)cell;
        [effectCell shouldDownload:NO];
        
        task.progressBlock = ^(NSProgress *progress) {
            CGFloat pgs = progress.completedUnitCount * 1.0 / progress.totalUnitCount;
            [effectCell downloadProgress:pgs];
        };
        
        __weak typeof(self) weakSelf = self;
        task.completionHandler = ^(NSString *path, NSError *err) {
            [weakSelf addEffectWithPath:path];
        };
    } else {
        
        [self addEffectWithPath:[pasterInfo filePath]];
    }
}

- (void)addEffectWithPath:(NSString *)path
{
    AliyunEffectPaster *paster = [[AliyunEffectPaster alloc] initWithFile:path];
    [self deleteCurrentEffectPaster];
   
    _currentEffectPaster = paster;
    [_recorder applyPaster:paster];
}

- (void)deleteCurrentEffectPaster
{
    if (_currentEffectPaster) {
        [_recorder deletePaster:_currentEffectPaster];
        _currentEffectPaster = nil;
    }
}

- (void)recordingProgressDuration:(CFTimeInterval)duration
{

}

- (void)recorderVideoDuration:(CGFloat)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat percent = duration / _clipManager.maxDuration;
        [self.magicCameraView recordingPercent:percent];
        _recordingDuration = duration;
    });
}

//需要reset
- (void)recordReset {
    if (_recordingDuration < [_clipManager minDuration]) {
        [_clipManager deletePart];
        _recordingDuration = 0;
        return;
    }
    
    _recordingDuration = 0;
    [_clipManager deleteAllPart];
}

- (void)didSelectRate:(CGFloat)rate {
    [self.recorder setRate:rate];
}

#pragma mark - MusicPickViewControllerDelegate

-(void)didSelectMusic:(AliyunMusicPickModel *)music {
    [self resumePreview];
    [self.navigationController popViewControllerAnimated:YES];
    AliyunEffectMusic *effectMusic = [[AliyunEffectMusic alloc] initWithFile:music.path];
    effectMusic.startTime = music.startTime;
    effectMusic.duration = music.duration;
    [_recorder applyMusic:effectMusic];
}

-(void)didCancelPick {
    [self resumePreview];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AliyunIRecorderDelegate -
/*
- (NSInteger)recorderOutputVideoTextureName:(NSInteger)textureName textureSize:(CGSize)textureSie {
    if (!_beibeiTexture) {
        _beibeiTexture = [[AliyunBeibeiTexture alloc] initWithTextureSize:textureSie];
    }
    return [_beibeiTexture renderWithTexture:textureName textureSize:textureSie];
}*/

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    NSDictionary *options = @{
                              (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                              };
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                                          CGImageGetHeight(image), kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status!=kCVReturnSuccess) {
        NSLog(@"Operation failed");
    }
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGAffineTransform flipVertical = CGAffineTransformMake( 1, 0, 0, -1, 0, CGImageGetHeight(image) );
    CGContextConcatCTM(context, flipVertical);
    CGAffineTransform flipHorizontal = CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGImageGetWidth(image), 0.0 );
    CGContextConcatCTM(context, flipHorizontal);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    
    return pxbuffer;
}

/*
- (CVPixelBufferRef)customRenderedPixelBufferWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    UIImage *image = [UIImage imageNamed:@"QPSDK.bundle/app_launch"];
    CVPixelBufferRef pixbuffer = [self pixelBufferFromCGImage:image.CGImage];
    

    return pixbuffer;
}
*/

//- (void)recorderOutputVideoRawSampleBuffer:(CMSampleBufferRef)sampleBuffer {
//    if (self.faceTrack == NO) {
//        return;
//    }
//
////    NSArray<AliyunFacePoint *> *facePoints = [self.faceAR facelistWithSampleBuffer:sampleBuffer];
////    [_recorder faceTrack:facePoints];
//}

- (void)recorderDidStopRecording {
    // 注释允许多段录制
    //[_recorder finishRecording];
//    _magicCameraView.finishButton.enabled = [_clipManager partCount];
//    _magicCameraView.musicButton.enabled = ![_clipManager partCount];
//    _magicCameraView.mvButton.enabled = ![_clipManager partCount];
    
    [_magicCameraView destroy];
}

- (void)recorderDidFinishRecording {
    [[QUMBProgressHUD HUDForView:self.view] hideAnimated:YES];
//    [self recordReset];
    if (_suspend == NO) {
        AliyunVideoPreViewController *videoPre = [[AliyunVideoPreViewController alloc] init];
        videoPre.videoPath = _recorder.outputPath;
        [self.navigationController pushViewController:videoPre animated:YES];
    }
//    [self.magicCameraView destroy];
}

- (void)recorderDidStopWithMaxDuration {
    [QUMBProgressHUD showHUDAddedTo:self.view animated:YES];
//    self.magicCameraView.flashButton.userInteractionEnabled = (_recorder.cameraPosition != 0);
//    self.magicCameraView.progressView.videoCount++;
//    self.magicCameraView.progressView.showBlink = NO;
    [self.recorder finishRecording];
    [self.magicCameraView destroy];
}

- (void)recoderError:(NSError *)error
{

}

@end
