//
//  AliyunRecordViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRecordViewController.h"
//#import "AliyunRecordNavigationView.h"
//#import "AliyunRecordBottomView.h"
#import "AliyunRecordControlView.h"
#import "AliyunRecordFocusView.h"
#import <AliyunVideoSDKPro/AliyunIRecorder.h>
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import <CoreMotion/CoreMotion.h>
#import "AliyunPathManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AliyunMediator.h"
#import "AliyunRecoderFilterPlugin.h"
#import "AliyunMagicCameraView.h"
#import "AliyunPasterInfo.h"
#import "AliyunDownloadManager.h"
#import "AliyunResourceManager.h"
#import "AliyunEffectMVView.h"
#import "AliyunMusicPickViewController.h"
#import "AliyunMagicCameraEffectCell.h"
#import "LiMi-Swift.h"
//#import "FURenderer.h"
//#import "AuthFaceUnity.h"


@interface AliyunRecordViewController ()<AliyunIRecorderDelegate,UIGestureRecognizerDelegate,MusicPickViewControllerDelegate>


//@property (nonatomic, strong) AliyunRecordNavigationView *navigationView;
@property (nonatomic, strong) AliyunRecordControlView *controlView;
@property (nonatomic, strong) AliyunClipManager *clipManager;
@property (nonatomic, strong) AliyunRecoderFilterPlugin *filterPlugin;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, assign) CGFloat lastPanY;
@property (nonatomic, assign) BOOL belowiPhone4s;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) int cameraRotate;
    
@end

@implementation AliyunRecordViewController
{
    int *tmpItem;
    CMSampleBufferRef tmpSampleBufferRef;
    int tmpFrameId;
    dispatch_semaphore_t sem;
    NSLock *lock;
    EAGLContext *mcontext;
    BOOL _suspend;
    
//    CGSize _videoSize;
    AliyunEffectPaster *_currentEffectPaster;
    AliyunClipManager *_clipManager;
    CFTimeInterval _recordingDuration;
    //    AliyunPasterInfoGroup *_demoPasterInfoGroup;
//    AliyunBeibeiTexture *_beibeiTexture;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isCameraBack = NO;
        self.beautifyStatus = YES;
        self.beautifyValue = 0;
        self.torchMode = 0;
    }
    return self;
}

- (void)loadView{
    [super loadView];

    //self.view = self.magicCameraView;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirstLoad = YES;
        
    NSString *videoSavePath = [[[AliyunPathManager createRecrodDir] stringByAppendingPathComponent:[AliyunPathManager uuidString]] stringByAppendingPathExtension:@"mp4"];
    NSString *taskPath = [AliyunPathManager createRecrodDir];
    if ([[NSFileManager defaultManager] fileExistsAtPath:taskPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:taskPath error:nil];
    }

    
    _previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.previewView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:_previewView];
    
    _recorder = [[AliyunIRecorder alloc] initWithDelegate:self videoSize:_quVideo.outputSize];
    _recorder.preview = _previewView;
    //_recorder.cameraPosition = AliyunIRecorderCameraPositionFront;
    _recorder.outputType = AliyunIRecorderVideoOutputPixelFormatType420f;
    _recorder.useFaceDetect = YES;
//    _recorder.backCaptureSessionPreset = AVCaptureSessionPreset1280x720;
//    _recorder.frontCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    _recorder.faceDetectCount = 2;
    _recorder.faceDectectSync = NO;
    _recorder.encodeMode = _quVideo.encodeMode;
    _recorder.GOP = _quVideo.gop;
    _recorder.videoQuality = (AliyunVideoQuality)_quVideo.videoQuality;
    _recorder.outputPath = _quVideo.outputPath?_quVideo.outputPath:videoSavePath;
    _recorder.taskPath = taskPath;
    _recorder.beautifyStatus = self.beautifyStatus;
    _recorder.beautifyValue = self.beautifyValue;
    _recorder.bitrate = _quVideo.bitrate;
    [_recorder startPreview];
    
    //录制片段设置
    _clipManager = _recorder.clipManager;
    _clipManager.maxDuration = _quVideo.maxDuration;
    _clipManager.minDuration = _quVideo.minDuration;
    _quVideo.outputPath = _recorder.outputPath;
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    
    //滤镜插件
    if ([AliyunIConfig config].filterArray.count > 0) {
        NSArray *filterArray = [AliyunIConfig config].filterArray;
        _filterPlugin = [[AliyunRecoderFilterPlugin alloc] initWithFilterArry:filterArray];
        _filterPlugin.disPlayView = _previewView;
        _filterPlugin.delegate = (id<AliyunRecoderFilterPluginDelegate>)self;
    }
//    [[AuthFaceUnity share] auth];
    
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (_isFirstLoad) {
        _isFirstLoad = NO;
        [_recorder startPreviewWithPositon:self.isCameraBack?AliyunIRecorderCameraPositionBack:AliyunIRecorderCameraPositionFront];
    } else {
        [_recorder startPreviewWithPositon:_recorder.cameraPosition];
    }
    [_recorder switchTorchWithMode:_torchMode];
    [self startMotionManager];
    
    
//   tmpItem = [[AuthFaceUnity share] loadItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self addWaterMark];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_recorder stopPreview];
    [_motionManager stopDeviceMotionUpdates];
}


- (void)dealloc {
//    [[AuthFaceUnity share] destroy];
    [_recorder destroyRecorder];
    _recorder = nil;
    //    [self.faceAR destroy];
    //    self.faceAR = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addWaterMark {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"watermark" ofType:@"png"];
    AliyunEffectImage *testImage = [[AliyunEffectImage alloc] initWithFile:path];
    // frame的宽高要和图片宽高等比例
    testImage.frame = CGRectMake(20, 20, 70, 50);
    [_recorder applyImage:testImage];
}

- (void)setupSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (CGSizeEqualToSize(size, CGSizeMake(320, 480)) || CGSizeEqualToSize(size, CGSizeMake(480, 320))) {
        _belowiPhone4s = YES;
    }

    [self.view addSubview:self.controlView];
    [self.controlView setupBeautyStatus:self.beautifyStatus flashStatus:self.torchMode];
    [self updateUIWithVideoSize:_quVideo.outputSize];
    
    
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)startMotionManager {
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    //实时获取设备旋转
    _motionManager.deviceMotionUpdateInterval = 1.0;
//    __weak typeof(self) weakSelf = self;
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        CMDeviceMotion *deviceMotion = _motionManager.deviceMotion;
        if (deviceMotion) {
            int rotate = 0;
            double gravityX = -deviceMotion.gravity.x;
            double gravityY = deviceMotion.gravity.y;
            double gravityZ = deviceMotion.gravity.z;
            
            if (gravityZ <= -0.9 || gravityZ >= 0.9) {
                rotate = 0;
            } else {
                BOOL isMirror = _recorder.cameraPosition == AliyunIRecorderCameraPositionBack;

                float radians = atan2(gravityY, gravityX);
                if(radians >= -2 && radians <= -1) {                  // up
                    rotate = 0;
                }else if(radians >= -0.5 && radians <= 0.5) {         // right
                    rotate = isMirror ? 270 : 270;
                }else if(radians >= 1.0 && radians <= 2.0)  {         // down
                    rotate = 180;
                }else if(radians <= -2.5 || radians >= 2.5) {         // left
                    rotate = isMirror ? 90 : 90;
                }
            }
            _cameraRotate = rotate;
//            _recorder.cameraRotate = _cameraRotate;//需设置 否则拍摄旋转角度有问题
        }
    }];
    
}

    
#pragma mark --- AliyunIRecorderDelegate

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

- (void)recorderDidFinishRecording {
    if (_delegate) {
        NSURL *sourceURL = [NSURL fileURLWithPath:_recorder.outputPath];
        AVAsset *avAsset = [AVAsset assetWithURL:sourceURL];
        CGSize outputSize = [avAsset avAssetNaturalSize];
        self.quVideo.outputSize = outputSize;
        
        [_delegate recoderFinish:self videopath:_recorder.outputPath];
    }
}

- (void)recorderDidStopWithMaxDuration {
    [_controlView updateRecordStatus];
    [_controlView updateRecordTypeToEndRecord];
    [_controlView updateNavigationStatusWithRecord:NO];
    [self bottomViewFinishVideo];
}
- (void)recorderVideoDuration:(CGFloat)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"已录制:%f",duration);
        [_controlView updateVideoDuration:duration];
        [_controlView updateNavigationStatusWithDuration:duration];
    });
}

- (void)recoderError:(NSError *)error {
    NSLog(@"录制错误");
    // update UI
    [self.controlView deleteLastProgress];
    [_clipManager deletePart];
    [_controlView updateVideoDuration:_clipManager.duration];
    [_controlView updateNavigationStatusWithDuration:_clipManager.duration];
}

////接入faceunity
//- (NSInteger)recorderOutputVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer textureName:(NSInteger)textureName {
//    if (tmpItem == NULL) {
//        NSLog(@"~~~~~~~~~~~环境未好");
//        return textureName;
//    }
//    
//    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//    
//    int h = (int)CVPixelBufferGetHeight(pixelBuffer);
//    int w = (int)CVPixelBufferGetWidth(pixelBuffer);
//    int stride = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
//    
//    TIOSDualInput input;
//    input.p_BGRA = CVPixelBufferGetBaseAddress(pixelBuffer);
//    input.tex_handle = (GLuint)textureName;
//    input.format = FU_IDM_FORMAT_BGRA;
//    input.stride_BGRA = stride;
//    
//    GLuint outHandle;
//    fuRenderItemsEx(FU_FORMAT_RGBA_TEXTURE, &outHandle, FU_FORMAT_INTERNAL_IOS_DUAL_INPUT, &input, w, h, tmpFrameId, tmpItem, 1);
//    tmpFrameId++;
//    
//    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//    
//    
//    return outHandle;
//}

//- (CVPixelBufferRef)customRenderedPixelBufferWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer {
//    
//    CVPixelBufferRef pixbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    
//    if (tmpItem == NULL) {
//        NSLog(@"~~~~~~~~~~~环境未好");
//        return pixbuffer;
//    }
//    
//   	if(!mcontext){
//        mcontext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//    }
//    if(!mcontext || ![EAGLContext setCurrentContext:mcontext]){
//        NSLog(@"faceunity: failed to create / set a GLES2 context");
//    }
//
//    CVPixelBufferRef pix = [[FURenderer shareRenderer] renderPixelBuffer:pixbuffer withFrameId:tmpFrameId items:tmpItem itemCount:1];
//    tmpFrameId++;
//    return pix;
//}

#pragma mark - AliyunMusicPickViewControllerDelegate
-(void)didSelectMusic:(AliyunMusicPickModel *)music {
    [self.navigationController popViewControllerAnimated:YES];
    AliyunEffectMusic *effectMusic = [[AliyunEffectMusic alloc] initWithFile:music.path];
    effectMusic.startTime = music.startTime;
    effectMusic.duration = music.duration;
    [_recorder applyMusic:effectMusic];
}
    
-(void)didCancelPick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MusicPickViewControllerDelegate
- (void)musicPickViewControllerSelectedNone{
    AliyunEffectMusic *effectMusic = [[AliyunEffectMusic alloc] initWithFile:nil];
    effectMusic.startTime = 0;
    effectMusic.duration = 0;
    [_recorder applyMusic:effectMusic];
}

- (void)musicPickViewControllerSelectedWithMusicPath:(NSString *)musicPath startTime:(float)startTime duration:(float)duration{
    AliyunEffectMusic *effectMusic = [[AliyunEffectMusic alloc] initWithFile:musicPath];
    effectMusic.startTime = startTime;
    effectMusic.duration = duration;
    [_recorder applyMusic:effectMusic];
}

#pragma mark --- AliyunRecordControlViewDelegate
- (void)musicButtonClick{
    [self pausePreview];
    
    MusicPickViewController *musicPickViewController = [[MusicPickViewController alloc] init];
    musicPickViewController.delegate = self;
    musicPickViewController.duration = (30);
    [self.navigationController pushViewController:musicPickViewController animated:true];
    
//    AliyunMusicPickViewController *vc = [[AliyunMusicPickViewController alloc] init];
//    vc.duration = _clipManager.maxDuration;
//    vc.delegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pausePreview {
    [_recorder stopPreview];
    [_motionManager stopDeviceMotionUpdates];
}

- (void)navigationBackButtonClick {
    if (_delegate) {
        [_delegate exitRecord];
    }

}

- (void)navigationRatioDidChangedWithValue:(CGFloat)r {
    
    CGSize videoSize = [_quVideo updateVideoSizeWithRatio:r];
    [_recorder stopPreview];
    [_recorder reStartPreviewWithVideoSize:videoSize];
    [self updateUIWithVideoSize:videoSize];
}

- (void)updateUIWithVideoSize:(CGSize)videoSize {
    CGFloat r = videoSize.width / videoSize.height;
    BOOL top = (r - 9/16.0)<0.01;
    CGFloat y = top ? SafeTop : SafeTop+44;

    CGRect preFrame = CGRectMake(0, y, ScreenWidth, ScreenWidth / r);
    
    if (_belowiPhone4s && top) {
        preFrame = CGRectMake((ScreenWidth - ScreenHeight * r)/2.f , 0, ScreenHeight * r, ScreenHeight);
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _previewView.frame = preFrame;
    }];
    
    y = CGRectGetMaxY(_previewView.frame);
//    if (_belowiPhone4s) {
//        if (r == 1) {
            _controlView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
//        } else {
//            _controlView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
//        }
//    } else {
//        if (!top) {
//            _controlView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
//        } else {
//            CGFloat bottomTop = ScreenWidth * 4/3.f + 44 + SafeTop;
//            if (ScreenHeight-y > 0 && y-bottomTop > 60) {
//                [_controlView updateHeight:y-bottomTop];
//            }
//        }
//    }

}

- (void)navigationBeautyDidChangedStatus:(BOOL)on {
    _recorder.beautifyStatus = !_recorder.beautifyStatus;
    
}


- (void)bottomViewRecordVideo {
    if ([_clipManager partCount] == 0) {
        _recorder.cameraRotate = 0; // 旋转角度以第一段视频为准  产品需求更改:不以第一段视频角度计算
    }

    [_recorder startRecording];

    [_controlView updateNavigationStatusWithRecord:YES];
}

- (void)bottomViewPauseVideo {
    [_recorder stopRecording];
    [_controlView updateNavigationStatusWithRecord:NO];
}

- (void)bottomViewDeleteFinished {
    [_clipManager deletePart];
    [_controlView updateVideoDuration:_clipManager.duration];
    [_controlView updateNavigationStatusWithDuration:_clipManager.duration];
}

- (void)bottomViewFinishVideo {
    
    [_recorder stopPreview];
//    // TODO:有没有更好的判断方法
//    if ([[self.delegate class] isEqual:NSClassFromString(@"AliyunVideoBase")]) {
//        [_recorder finishRecording];
//    }
//
    _quVideo.videoRotate = [_clipManager firstClipVideoRotation];
    if (!self.isSkipEditVC) {
        [_recorder finishRecording];
    }else {
#if SDK_VERSION == SDK_VERSION_BASE
        [_recorder destroyRecorder];
#endif
        if (_delegate) {
            [_delegate recoderFinish:self videopath:_recorder.outputPath];
        }
    }
}

- (void)bottomViewShowLibrary {
        
    if (_delegate) {
        [_delegate recordViewShowLibrary:self];
        return;
    }
}

- (void)selectFilter:(AliyunEffectFilter*)filter index:(NSInteger)index{
    [_recorder applyFilter:filter];
}

- (void)didSelectRate:(CGFloat)rate {
    [self.recorder setRate:rate];
}
#pragma mark --- Get

- (AliyunRecordControlView *)controlView {
    if (!_controlView) {
        CGRect rect = CGRectMake(0,ScreenWidth * 4/3.f + 44 + SafeTop, ScreenWidth, ScreenHeight - ScreenWidth * 4/3.f - 44 - SafeTop - SafeBottom);
        if (_belowiPhone4s) {
            rect.size.height = 98;
            rect.origin.y = ScreenHeight - 98;
        }
        _controlView = [[AliyunRecordControlView alloc] initWithFrame:rect];
        _controlView.backgroundColor = [UIColor clearColor];
        _controlView.recoder = self.recorder;
        _controlView.clipManager = self.clipManager;
        _controlView.delegate = (id<AliyunRecordControlViewDelegate>)self;
        _controlView.minDuration = _quVideo.minDuration;
        _controlView.maxDuration = _quVideo.maxDuration;
    }
    return _controlView;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    
    AliyunIRecorderTorchMode mode = _recorder.torchMode;
    if (mode == AliyunIRecorderTorchModeOn) {
    } else if (mode == AliyunIRecorderTorchModeOff) {
    } else {
    }
    
    [self setupFaceRotate];
}

- (void)appWillResignActive:(id)sender
{
    if ([self.navigationController.childViewControllers lastObject] != self) {
        return;
    }
    if ([_recorder isRecording]) {
        [_recorder stopRecording];
        [_recorder stopPreview];
        _suspend = YES;
    }
}

- (void)appDidBecomeActive:(id)sender
{
    if ([self.navigationController.childViewControllers lastObject] != self) {
        return;
    }
    if (_suspend) {
        _suspend = NO;
        
        [_recorder startPreview];
        [_recorder switchTorchWithMode:_torchMode];
        [self.controlView updateNavigationFlashStatus:_torchMode];
        [self.controlView updateNavigationStatusWithRecord:NO];
        [self.controlView updateRecordTypeToEndRecord];
    }
}

#pragma mark - 魔法（人脸识别）
    
    
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
    @end
