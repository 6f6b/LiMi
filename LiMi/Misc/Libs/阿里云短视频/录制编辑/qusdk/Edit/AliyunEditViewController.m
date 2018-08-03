//
//  QUEditViewController.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//
#import <AliyunVideoSDKPro/AliyunPasterManager.h>
#import <AliyunVideoSDKPro/AliyunEditor.h>
#import <AliyunVideoSDKPro/AliyunEffectMusic.h>
#import <AliyunVideoSDkPro/AliyunPasterBaseView.h>
#import <AliyunVideoSDkPro/AliyunClip.h>
#import <AliyunVideoSDKPro/AVAsset+AliyunSDKInfo.h>
#import "AliyunEditViewController.h"
#import "AliyunTimelineView.h"
#import "AliyunEditButtonsView.h"
#import "AliyunEditHeaderView.h"
#import "AliyunTabController.h"
#import "AliyunPasterView.h"
#import "AliyunPasterTextInputView.h"
#import "AliyunEditZoneView.h"
#import "AliyunPasterShowView.h"
#import "AliyunEffectMoreViewController.h"
#import "AliyunEffectMVView.h"
#import "AliyunEffectCaptionShowView.h"
#import "AliyunEffectMVView.h"
#import "AliyunEffectMusicView.h"
#import "AliyunTimelineItem.h"
#import "AliyunTimelineMediaInfo.h"
#import "AliyunPathManager.h"
#import "AliyunEffectFontInfo.h"
#import "AliyunDBHelper.h"
#import "AliyunResourceFontDownload.h"
#import "QUMBProgressHUD.h"
#import "AliyunPaintEditView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AliyunCustomFilter.h"
#import "AVAsset+VideoInfo.h"
#import "AliyunPublishViewController.h"
#import "AliyunEffectFilterView.h"
#import "AddAnimationFilterController.h"
#import "FilterAndBeautyView.h"
#import "AliyunPathManager.h"
#import "SoundTrackAndMusicAdjustView.h"
#import "LiMi-Swift.h"
typedef enum : NSUInteger {
    AliyunEditSouceClickTypeNone = 0,
    AliyunEditSouceClickTypeFilter,
    AliyunEditSouceClickTypePaster,
    AliyunEditSouceClickTypeSubtitle,
    AliyunEditSouceClickTypeMV,
    AliyunEditSouceClickTypeMusic,
    AliyunEditSouceClickTypePaint
} AliyunEditSouceClickType;

typedef struct _AliyunPasterRange {
    CGFloat startTime;
    CGFloat duration;
} AliyunPasterRange;

extern NSString * const AliyunEffectResourceDeleteNoti;

//TODO:此类需再抽一层,否则会太庞大
@interface AliyunEditViewController () <AliyunIExporterCallback, AliyunIPlayerCallback,MusicPickViewControllerDelegate,AliyunEditButtonsViewDelegate,SoundTrackAndMusicAdjustViewDelegate>

@property (nonatomic, strong) UIView *movieView;
@property (nonatomic, strong) AliyunTimelineView *timelineView;
@property (nonatomic, strong) AliyunEditButtonsView *editButtonsView;
@property (nonatomic, strong) AliyunEditHeaderView *editHeaderView;
@property (nonatomic, strong) AliyunTabController *tabController;
@property (nonatomic, strong) UIButton *backgroundTouchButton;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) FilterAndBeautyView *filterView;

@property (nonatomic, strong) AliyunPasterManager *pasterManager;
@property (nonatomic, strong) AliyunEditZoneView *editZoneView;
@property (nonatomic, strong) AliyunEditor *editor;
@property (nonatomic, strong) id<AliyunIPlayer> player;
@property (nonatomic, strong) id<AliyunIExporter> exporter;
@property (nonatomic, strong) AliyunEffectImage *paintImage;

@property (nonatomic, strong) AliyunEffectMVView *mvView;
@property (nonatomic, strong) AliyunEffectMusicView *musicView;
@property (nonatomic, strong) AliyunPasterShowView *pasterShowView;
@property (nonatomic, strong) AliyunEffectCaptionShowView *captionShowView;
@property (nonatomic, strong) AliyunPaintEditView *paintShowView;
@property (nonatomic, strong) AliyunDBHelper *dbHelper;

@property (nonatomic, assign) BOOL isExporting;
//@property (nonatomic, assign) BOOL isExported;
@property (nonatomic, assign) BOOL isAddMV;
@property (nonatomic, assign) CGSize outputSize;
@property (nonatomic, strong) AliyunCustomFilter *filter;
@property (nonatomic, strong) UIButton *staticImageButton;



//动效滤镜
@property (nonatomic, strong) NSMutableArray *animationFilters;

@property (nonatomic,strong) NSMutableArray *filterDataArray;
@property (nonatomic, strong) UILabel *filterInfoLabel;
@property (nonatomic, strong) AliyunDBHelper *filterDbHelper;

//混音权重
@property (nonatomic, assign) int mixWeight;
//主流权重
@property (nonatomic, assign) int mainWeight;


@end

@implementation AliyunEditViewController {
    AliyunPasterTextInputView *_currentTextInputView;
    AliyunEditSouceClickType _editSouceClickType;
    BOOL _prePlaying;
    BOOL _haveStaticImage;
    AliyunEffectStaticImage *_staticImage;
    AliyunEffectFilter *_processAnimationFilter;
    AliyunTimelineFilterItem *_processAnimationFilterItem;
}

- (instancetype)init{
    if (self = [super init]){
        _musicType = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mixWeight = 50;
    _mainWeight = 50;
    // 校验视频分辨率，如果首段视频是横屏录制，则outputSize的width和height互换
    _outputSize = [_config fixedSize];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor =UIColor.blackColor;
    _filterDataArray = [NSMutableArray new];
    _filterIndex = 0;
    _filterDbHelper = [[AliyunDBHelper alloc] init];

    [self reloadDataWithEffectType:4];
    
    [self addSubviews];
    
    // editor
    self.editor = [[AliyunEditor alloc] initWithPath:_taskPath preview:self.movieView];
    [self adjustVolumeWithMainWeight:_mainWeight andMixWeight:_mixWeight];
    self.editor.delegate = (id)self;

    // player
    self.player = [self.editor getPlayer];
    self.exporter = [self.editor getExporter];
    
    // setup pasterEditZoneView
//    self.editZoneView = [[AliyunEditZoneView alloc] initWithFrame:self.movieView.bounds];
//    self.editZoneView.delegate = (id)self;
//    [self.movieView addSubview:self.editZoneView];
    
    // setup pasterManager
//    self.pasterManager = [self.editor getPasterManager];
//    self.pasterManager.displaySize = self.editZoneView.bounds.size;
//    self.pasterManager.outputSize = _outputSize;
//    self.pasterManager.delegate = (id)self;
    
    [self.editor setRenderBackgroundColor:[UIColor blackColor]];
 
    // setup timeline

    NSArray *clips = [self.editor getMediaClips];
    NSMutableArray *mediaClips = [[NSMutableArray alloc] init];
    for (int idx = 0; idx < [clips count]; idx++ ) {
        AliyunClip *clip = clips[idx];
        AliyunTimelineMediaInfo *mediaInfo = [[AliyunTimelineMediaInfo alloc] init];
        mediaInfo.mediaType = (AliyunTimelineMediaInfoType)clip.mediaType;
        mediaInfo.path = clip.src;
        mediaInfo.duration = clip.duration;
        mediaInfo.startTime = clip.startTime;
        [mediaClips addObject:mediaInfo];
    }
    [self.timelineView setMediaClips:mediaClips segment:8.0 photosPersegent:8];
  
    // update views
    [self updateSubViews];
    [self addNotifications];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)adjustVolumeWithMainWeight:(int)mainWeight andMixWeight:(int)mixWeight{
    
    int volume = mainWeight+mixWeight;
    int musicWeight = 100*((float)mixWeight/(float)(mixWeight+mainWeight));
    [self.editor setVolume:volume];
    [self.editor setAudioMixWeight:musicWeight];
    NSLog(@"当前总音量：%d--配乐：%d--原声：%d",volume,musicWeight,100-musicWeight);
}
- (UIButton *)staticImageButton {
    if (!_staticImageButton) {
        _staticImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _staticImageButton.frame = CGRectMake(ScreenWidth - 120, 120, 100, 40);
        [_staticImageButton addTarget:self action:@selector(staticImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_staticImageButton setTitle:@"静态贴图" forState:UIControlStateNormal];
    }
    return _staticImageButton;
}

- (void)setFilterIndex:(int)filterIndex{
    if(filterIndex == _filterIndex){return;}
    _filterIndex = filterIndex;
    AliyunEffectInfo *currentEffect = _filterDataArray[filterIndex];
    AliyunEffectFilter *filter =[[AliyunEffectFilter alloc] initWithFile:[currentEffect localFilterResourcePath]];
    [self.filterInfoLabel.layer removeAllAnimations];
    self.filterInfoLabel.alpha = 1;
    self.filterInfoLabel.text = currentEffect.name;
    __weak AliyunEditViewController *weakSelf = self;
    [UIView animateWithDuration:0.2 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
        weakSelf.filterInfoLabel.alpha = 0;
    } completion:nil];
    [self.editor applyFilter:filter];
}

- (void)staticImageButtonTapped:(id)sender {
    if (_haveStaticImage == NO) {
        _haveStaticImage = YES;
        _staticImage = [[AliyunEffectStaticImage alloc]  init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"yuanhao8" ofType:@"png"];
        _staticImage.startTime = 5;
        _staticImage.endTime = 10;
        _staticImage.path = path;
        
        CGSize displaySize = self.editZoneView.bounds.size;
        CGFloat scale = [[UIScreen mainScreen] scale];
        _staticImage.displaySize = CGSizeMake(displaySize.width * scale, displaySize.height * scale);//displaySize需要进行scale换算
        _staticImage.frame = CGRectMake(_staticImage.displaySize.width /2 - 200, _staticImage.displaySize.height / 2 -200, 400, 400);//图片自身宽高
        [self.editor applyStaticImage:_staticImage];
    } else {
        _haveStaticImage = NO;
        [self.editor removeStaticImage:_staticImage];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSURL *sourceURL = [NSURL fileURLWithPath:_config.outputPath];
//    AVAsset *_avAsset = [AVAsset assetWithURL:sourceURL];
//    CGSize _originalMediaSize = [_avAsset avAssetNaturalSize];
    
    CGSize size = CGSizeZero;
    CGFloat _screenRatio = ScreenWidth/ScreenHeight;
    CGFloat _orgVideoRatio =  _config.outputSize.width/_config.outputSize.height;
    CGSize _originalMediaSize = _config.outputSize;
    if (_screenRatio >= _orgVideoRatio){
        CGFloat heightRatio = ScreenHeight/_originalMediaSize.height;
        size.height = ScreenHeight;
        size.width = _originalMediaSize.width*heightRatio;
    }
    if ( _screenRatio < _orgVideoRatio){
        CGFloat widthRatio = ScreenWidth/_originalMediaSize.width;
        size.width = ScreenWidth;
        size.height = _originalMediaSize.height*widthRatio;
    }

    CGRect frame = CGRectZero;
    frame.size = size;

    self.movieView.frame = frame;
    self.movieView.center = self.view.center;

    [self.view addSubview:self.movieView];
    [self.view addSubview:self.editHeaderView];
    [self.view addSubview:self.editButtonsView];
    self.editor.delegate =(id) self;
    [self.editor startEdit];
    [self.player play];

    self.timelineView.actualDuration = [self.player getDuration]; //为了让导航条播放时长匹配，必须在这里设置时长
    _prePlaying = YES;

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player stop];
    [self.editor stopEdit];
    self.filter = nil;
}

- (void)dealloc {
    [self.editor destroyAllEffect];//清理所有效果
    [self removeNotifications];
}

#pragma mark - Notification

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resourceDeleteNoti:)
                                                 name:AliyunEffectResourceDeleteNoti
                                               object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Action
- (void)resourceDeleteNoti:(NSNotification *)noti {
    NSArray *deleteResourcePaths = noti.object;
    for (NSString *delePath in deleteResourcePaths) {
        NSString *deleIconPath = [delePath stringByAppendingPathComponent:@"icon.png"];
        NSArray *pasterList = [self.pasterManager getAllPasterControllers];
        [pasterList enumerateObjectsUsingBlock:^(AliyunPasterController *controller, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[controller getIconPath] isEqualToString:deleIconPath]) {
                [controller.delegate onRemove:controller]; // 删除paster
            }
        }];
    }
}

- (void)applicationDidBecomeActive {
    if (self.isExporting) {
        [[QUMBProgressHUD HUDForView:self.view] hideAnimated:YES];
        self.isExporting = NO;
    }else {
    }
    [self.player setActive:YES];
    [self.player play];
    [self forceFinishLastEditPasterView];
}

#pragma mark - FilterAndBeautyViewDelegate
- (void)filterAndBeautyViewSelectedFilterIndex:(int)index{
    self.filterIndex = index;
}

#pragma mark - AliyunIPlayerCallback -
- (void)playerDidStart {
    NSLog(@"play start");
}

- (void)playerDidEnd {
    
    if (_processAnimationFilter) {//如果当前有正在添加的动效滤镜 则pause
        [self.player play];
        _processAnimationFilter.endTime = [self.player getDuration];
        [self didEndLongPress];
    } else {
        if (!self.isExporting) {
            [self.player play];
            self.isExporting = NO;
            [self forceFinishLastEditPasterView];
        }
    }
}

- (void)playProgress:(double)sec {
    [self.timelineView seekToTime:sec];
    self.currentTimeLabel.text = [self stringFromTimeInterval:sec];
    [self.currentTimeLabel sizeToFit];
}

- (void)seekDidEnd {
    NSLog(@"seek end");
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

- (void)playError:(int)errorCode {
    NSLog(@"demo :Errorcode:%d", errorCode);
    [self.player pause];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"video_reminder_common", nil) message:NSLocalizedString(@"video_error_edit", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"video_affirm_common", nil) otherButtonTitles: nil];
        [alert show];
    });
}

- (int)customRender:(int)srcTexture size:(CGSize)size {
    // 自定义滤镜渲染
//    if (!self.filter) {
//        self.filter = [[AliyunCustomFilter alloc] initWithSize:size];
//    }
//    return [self.filter render:srcTexture size:size];
    return srcTexture;
}

#pragma mark - AliyunIExporterCallback 

-(void)exporterDidStart {
    NSLog(@"TestLog, %@:%@", @"log_edit_start_time", @([NSDate date].timeIntervalSince1970));

    QUMBProgressHUD *hud = [QUMBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = QUMBProgressHUDModeDeterminate;
    [hud.button setTitle:NSLocalizedString(@"cancel_camera_import", nil) forState:UIControlStateNormal];
    [hud.button addTarget:self action:@selector(cancelExport) forControlEvents:UIControlEventTouchUpInside];
    hud.label.text = NSLocalizedString(@"video_is_exporting_edit", nil);
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)exporterDidEnd {
    NSLog(@"TestLog, %@:%@", @"log_edit_complete_time", @([NSDate date].timeIntervalSince1970));

    [[QUMBProgressHUD HUDForView:self.view] hideAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (self.isExporting) {
        self.isExporting = NO;

        NSURL *outputPathURL = [NSURL fileURLWithPath:_config.outputPath];
        AVAsset *as = [AVAsset assetWithURL:outputPathURL];
        CGSize size = [as aliyunNaturalSize];
        CGFloat videoDuration = [as aliyunVideoDuration];
        float frameRate = [as aliyunFrameRate];
        float bitRate = [as aliyunBitrate];
        float estimatedKeyframeInterval =  [as aliyunEstimatedKeyframeInterval];

        NSLog(@"TestLog, %@:%@", @"log_output_resolution", NSStringFromCGSize(size));
        NSLog(@"TestLog, %@:%@", @"log_video_duration", @(videoDuration));
        NSLog(@"TestLog, %@:%@", @"log_frame_rate", @(frameRate));
        NSLog(@"TestLog, %@:%@", @"log_bit_rate", @(bitRate));
        NSLog(@"TestLog, %@:%@", @"log_i_frame_interval", @(estimatedKeyframeInterval));


        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:outputPathURL
                                    completionBlock:^(NSURL *assetURL, NSError *error)
        {
            /* process assetURL */
            if (!error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"video_exporting_finish_edit", nil) message:NSLocalizedString(@"video_local_save_edit", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"video_exporting_finish_fail_edit", nil) message:NSLocalizedString(@"video_exporting_check_autho", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        }];
    }
    [self.player play];
}

-(void)exporterDidCancel {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.player play];
}

- (void)exportProgress:(float)progress {
  [QUMBProgressHUD HUDForView:self.view].progress = progress;
}

-(void)exportError:(int)errorCode {
    [[QUMBProgressHUD HUDForView:self.view] hideAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.player play];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)addSubviews
{
    CGSize size = CGSizeZero;
    CGFloat _screenRatio = ScreenWidth/ScreenHeight;
    CGFloat _orgVideoRatio =  _config.outputSize.width/_config.outputSize.height;
    CGSize _originalMediaSize = _config.outputSize;
    if (_screenRatio >= _orgVideoRatio){
        CGFloat heightRatio = ScreenHeight/_originalMediaSize.height;
        size.height = ScreenHeight;
        size.width = _originalMediaSize.width*heightRatio;
    }
    if ( _screenRatio < _orgVideoRatio){
        CGFloat widthRatio = ScreenWidth/_originalMediaSize.width;
        size.width = ScreenWidth;
        size.height = _originalMediaSize.height*widthRatio;
    }
    
    CGRect frame = CGRectZero;
    frame.size = size;
    
    self.movieView = [[UIView alloc] initWithFrame:frame];
    self.movieView.center = self.view.center;
    self.movieView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.movieView];
    
    self.editHeaderView = [[AliyunEditHeaderView alloc] initWithFrame:CGRectMake(0, SafeTop, ScreenWidth, 44)];
    [self.view addSubview:self.editHeaderView];
    
    __weak typeof(self) weakSelf = self;
    self.editHeaderView.backClickBlock = ^{
        [weakSelf back];
    };
    self.editHeaderView.saveClickBlock = ^{
        [weakSelf save];
    };
    
//    self.timelineView = [[AliyunTimelineView alloc] initWithFrame:CGRectMake(0, 44+SafeTop, ScreenWidth, ScreenWidth / 8)];
//    self.timelineView.backgroundColor = [UIColor whiteColor];
    self.timelineView.delegate = (id)self;
//    [self.view addSubview:self.timelineView];

    
    self.editButtonsView = [[AliyunEditButtonsView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 68 - SafeBottom, ScreenWidth, 68)];
    [self.view addSubview:self.editButtonsView];
    self.editButtonsView.delegate = (id)self;
    
    _filterInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    _filterInfoLabel.font = [UIFont systemFontOfSize:23];
    _filterInfoLabel.textAlignment = UITextAlignmentCenter;
    _filterInfoLabel.textColor = [UIColor whiteColor];
    _filterInfoLabel.text = @"";
    _filterInfoLabel.center = CGPointMake(ScreenWidth*0.5, ScreenHeight*0.5);
    _filterInfoLabel.alpha = 0;
    [self.view addSubview:_filterInfoLabel];
    
}


- (void)updateSubViews {
    // 9:16模式下 view透明
    if ([_config mediaRatio] == AliyunMediaRatio9To16) {
        self.movieView.frame = self.movieView.bounds;
//        self.editHeaderView.alpha = 0.5;
        [self.timelineView updateTimelineViewAlpha:0.5];
//        self.editButtonsView.alpha = 0.5;
    }
}

- (AliyunTabController *)tabController
{
    if (!_tabController) {
        _tabController = [[AliyunTabController alloc] init];
        _tabController.delegate = (id)self;
    }
    return _tabController;
}

#pragma mark - Action

#pragma mark - Private Methods -

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save {
    [self forceFinishLastEditPasterView];
    
    if (self.isExporting) return;
    
    // 当前页面合成视频
//    UIImage *image = [UIImage imageNamed:@"tail"];
//    NSString *path = _config.outputPath;
//    [self.exporter setTailWaterMark:image frame:CGRectMake(0, 0, 84,60) duration:2];
//    [self.exporter startExport:path];
//    self.isExporting = YES;

    // 发布页面合成视频
    PulishViewController *pulishViewController = [[PulishViewController alloc] init];
    pulishViewController.taskPath = _taskPath;
    pulishViewController.config = _config;
    pulishViewController.outputSize = _outputSize;
    pulishViewController.backgroundImage = _timelineView.coverImage;
    pulishViewController.musicId = self.musicId;
    pulishViewController.startTime = self.startTime;
    pulishViewController.duration = self.duration;
    pulishViewController.musicType = self.musicType;
    pulishViewController.challengeName = self.challengeName;
    
    pulishViewController.challengeId = self.challengeId;
    if(self.challengeId && self.challengeName){
        
    }
    [self.navigationController pushViewController:pulishViewController animated:true];
    
//    AliyunPublishViewController *vc = [[AliyunPublishViewController alloc] init];
//    vc.taskPath = _taskPath;
//    vc.config = _config;
//    vc.outputSize = _outputSize;
//    vc.backgroundImage = _timelineView.coverImage;
//    [self.navigationController pushViewController:vc animated:YES];

}

- (void)cancelExport {
    self.isExporting = NO;
    [self.exporter cancelExport];
    [[QUMBProgressHUD HUDForView:self.view] hideAnimated:YES];
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
    if (_editSouceClickType == AliyunEditSouceClickTypeSubtitle) {
        [self dismissEffectView:self.captionShowView duration:0.2f];
    } else if (_editSouceClickType == AliyunEditSouceClickTypePaster) {
        [self dismissEffectView:self.pasterShowView duration:0.2f];
    } else if (_editSouceClickType == AliyunEditSouceClickTypeFilter) {
        [self dismissEffectView:self.filterView duration:0.2f];
    } else if (_editSouceClickType == AliyunEditSouceClickTypeMusic) {
        [self dismissEffectView:self.musicView duration:0.2f];
    } else if (_editSouceClickType == AliyunEditSouceClickTypeMV) {
        [self dismissEffectView:self.mvView duration:0.2f];
    }
    if (_currentTextInputView) {
        [self textInputViewEditCompleted];
    }

    
}

- (void)textInputViewEditCompleted {
    [self.tabController dismissPresentTabContainerView];
    [self showTopView];
    self.editZoneView.currentPasterView = nil;
    
    AliyunPasterController *editPasterController = [self.pasterManager getCurrentEditPasterController];
    if (editPasterController) {//当前有正在编辑的动图控制器，则更新
        AliyunPasterView *pasterView = (AliyunPasterView *)editPasterController.pasterView;
        pasterView.text = [_currentTextInputView getText];
        pasterView.textFontName = [_currentTextInputView fontName];
        pasterView.textColor = [_currentTextInputView getTextColor];
        editPasterController.subtitle = pasterView.text;
        editPasterController.subtitleFontName = [_currentTextInputView fontName];
        [editPasterController editCompletedWithImage:[pasterView textImage]];
        editPasterController.subtitleStroke = pasterView.textColor.isStroke;
        editPasterController.subtitleColor = [pasterView contentColor];
        editPasterController.subtitleStrokeColor = [pasterView strokeColor];
        [self makePasterControllerBecomeEditStatus:editPasterController];
        
    } else {//当前无正在编辑的动图控制器，则新建
        NSString *text = [_currentTextInputView getText];
        if (text == nil || [text isEqualToString:@""]) {
            [self destroyInputView];
            return;
        }
        CGRect inputViewBounds = _currentTextInputView.bounds;
        
        AliyunPasterRange range = [self calculatePasterStartTimeWithDuration:1];
        
        AliyunPasterController *pasterController = [self.pasterManager addSubtitle:text bounds:inputViewBounds startTime:range.startTime duration:range.duration];
        [self addPasterViewToDisplayAndRender:pasterController pasterFontId:-1];
        [self addPasterToTimeline:pasterController]; //加到timelineView联动
        [self makePasterControllerBecomeEditStatus:pasterController];
    }
    [self destroyInputView];
}

- (void)destroyInputView {
    [_currentTextInputView removeFromSuperview];
    _currentTextInputView = nil;
}

- (void)makePasterControllerBecomeEditStatus:(AliyunPasterController *)pasterController {
    self.editZoneView.currentPasterView = (AliyunPasterView *)[pasterController pasterView];
    [pasterController editWillStart];
    self.editZoneView.currentPasterView.editStatus = YES;
    [self editPasterItemBy:pasterController]; //TimelineView联动
}

- (void)addPasterViewToDisplayAndRender:(AliyunPasterController *)pasterController pasterFontId:(NSInteger)fontId {
    AliyunPasterView *pasterView = [[AliyunPasterView alloc] initWithPasterController:pasterController];
    
    if (pasterController.pasterType == AliyunPasterEffectTypeSubtitle) {
        pasterView.textColor = [_currentTextInputView getTextColor];
        pasterView.textFontName = [_currentTextInputView fontName];
        pasterController.subtitleFontName = pasterView.textFontName;
        pasterController.subtitleStroke = pasterView.textColor.isStroke;
        pasterController.subtitleColor = [pasterView contentColor];
        pasterController.subtitleStrokeColor = [pasterView strokeColor];
    }
    if (pasterController.pasterType == AliyunPasterEffectTypeCaption) {
        UIColor *textColor = pasterController.subtitleColor;
        UIColor *textStokeColor = pasterController.subtitleStrokeColor;
        BOOL stroke = pasterController.subtitleStroke;
        AliyunColor *color = [[AliyunColor alloc] initWithColor:textColor strokeColor:textStokeColor stoke:stroke];
        pasterView.textColor = color;
        AliyunEffectFontInfo *fontInfo = (AliyunEffectFontInfo *)[self.dbHelper queryEffectInfoWithEffectType:1 effctId:fontId];
        
        if (fontInfo == nil) {
            AliyunResourceFontDownload *download = [[AliyunResourceFontDownload alloc] init];
            [download downloadFontWithFontId:fontId progress:nil completion:^(AliyunEffectResourceModel *newModel, NSError *error) {
                pasterView.textFontName = newModel.fontName;
                pasterController.subtitleFontName = newModel.fontName;
            }];
        } else {
            pasterView.textFontName = fontInfo.fontName;
            pasterController.subtitleFontName = fontInfo.fontName;
        }
    }
    
    pasterView.delegate = (id)pasterController;
    pasterView.actionTarget = (id)self;
    
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformMakeRotation(-pasterController.pasterRotate);
    pasterView.layer.affineTransform = t;
    
    [pasterController setPasterView:pasterView];
    [self.editZoneView addSubview:pasterView];
    
    if (pasterController.pasterType == AliyunPasterEffectTypeSubtitle) {
        [pasterController editCompletedWithImage:[pasterView textImage]];
    } else if (pasterController.pasterType == AliyunPasterEffectTypeNormal) {
        [pasterController editCompleted];
    } else {
        [pasterController editCompletedWithImage:[pasterView textImage]];
    }
}

- (AliyunPasterRange)calculatePasterStartTimeWithDuration:(CGFloat)duration {
    
    AliyunPasterRange pasterRange;
    
    if (duration >= [self.player getDuration]) { //默认动画时间长于视频长度  将默认时间设置为视频长
        pasterRange.duration = [self.player getDuration];
        pasterRange.startTime = 0;
    } else {
        if ([self.player getDuration] - [self.player getCurrentTime] <= duration) { //默认动画的播放时间超过总视频长
            pasterRange.duration = duration;
            pasterRange.startTime = [self.player getDuration] - duration;
        } else { //默认动画时间未超出总视频
            pasterRange.duration = duration;
            pasterRange.startTime = [self.player getCurrentTime];
        }
    }
    return pasterRange;
}

#pragma mark - AliyunTimelineView相关 -
- (void)addAnimationFilterToTimeline:(AliyunEffectFilter *)animationFilter {
    AliyunTimelineFilterItem *filterItem = [[AliyunTimelineFilterItem alloc] init];
    filterItem.startTime = animationFilter.startTime;
    filterItem.endTime = animationFilter.endTime;
    filterItem.displayColor = [self colorWithName:animationFilter.name];
    filterItem.obj = animationFilter;
    [self.timelineView addTimelineFilterItem:filterItem];
}

- (void)updateAnimationFilterToTimeline:(AliyunEffectFilter *)animationFilter {
    if (_processAnimationFilterItem == NULL) {
        _processAnimationFilterItem = [[AliyunTimelineFilterItem alloc] init];
    }
    _processAnimationFilterItem.startTime = animationFilter.startTime;
    _processAnimationFilterItem.endTime = [self.player getCurrentTime];
    _processAnimationFilterItem.displayColor = [self colorWithName:animationFilter.name];
    
    [self.timelineView updateTimelineFilterItems:_processAnimationFilterItem];
}

- (void)removeAnimationFilterFromTimeline:(AliyunTimelineFilterItem *)animationFilterItem {
    [self.timelineView removeTimelineFilterItem:animationFilterItem];
}

- (void)removeLastAnimtionFilterItemFromTimeLineView {
    [self.timelineView removeLastFilterItemFromTimeline];
}

- (void)addPasterToTimeline:(AliyunPasterController *)pasterController {
    AliyunTimelineItem *timeline = [[AliyunTimelineItem alloc] init];
    timeline.startTime = pasterController.pasterStartTime;
    timeline.endTime = pasterController.pasterEndTime;
    timeline.obj = pasterController;
    timeline.minDuration = pasterController.pasterMinDuration;
    [self.timelineView addTimelineItem:timeline];
}

- (void)removePasterFromTimeline:(AliyunPasterController *)pasterController {
    AliyunTimelineItem *timeline = [self.timelineView getTimelineItemWithOjb:pasterController];
    [self.timelineView removeTimelineItem:timeline];
}

- (void)editPasterItemBy:(AliyunPasterController *)pasterController {
    AliyunTimelineItem *timeline = [self.timelineView getTimelineItemWithOjb:pasterController];
    [self.timelineView editTimelineItem:timeline];
}

- (void)editPasterItemComplete {
    [self.timelineView editTimelineComplete];
}

#pragma mark - AliyunPasterManagerDelegate -
- (void)pasterManagerWillDeletePasterController:(AliyunPasterController *)pasterController {
    [self removePasterFromTimeline:pasterController]; //与timelineView联动
}

#pragma mark - AliyunTimelineViewDelegate -
- (void)timelineDraggingTimelineItem:(AliyunTimelineItem *)item {
    [[self.pasterManager getAllPasterControllers] enumerateObjectsUsingBlock:^(AliyunPasterController *pasterController, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([pasterController isEqual:item.obj]) {
            pasterController.pasterStartTime = item.startTime;
            pasterController.pasterEndTime = item.endTime;
            
            *stop = YES;
        }
    }];
}

- (void)timelineBeginDragging {
    [self forceFinishLastEditPasterView];
}

- (void)timelineDraggingAtTime:(CGFloat)time {
    [self.player seek:time];
    
    self.currentTimeLabel.text = [self stringFromTimeInterval:time];
    [self.currentTimeLabel sizeToFit];
}

- (void)timelineEndDraggingAndDecelerate:(CGFloat)time  {
    if (_prePlaying) {
        [self.player resume];
    }
}

#pragma mark - AliyunPasterViewActionTarget -
- (void)oneClick:(id)obj {
    [self presentBackgroundButton];
    AliyunPasterView *pasterView = (AliyunPasterView *)obj;
    AliyunPasterController *pasterController = (AliyunPasterController *)pasterView.delegate;
    [pasterController editDidStart];
    
    int maxCharacterCount = 0;
    if (pasterController.pasterType == AliyunPasterEffectTypeCaption) {
        maxCharacterCount = 20;
    }
    AliyunPasterTextInputView *inputView = [AliyunPasterTextInputView createPasterTextInputViewWithText:[pasterController subtitle]
                                                                                      textColor:pasterView.textColor
                                                                                       fontName:pasterView.textFontName
                                                                                   maxCharacterCount:maxCharacterCount];
    [self.view addSubview:inputView];
    inputView.delegate = (id)self;
    inputView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 50);
    _currentTextInputView = inputView;
}

#pragma mark - AliyunEditZoneViewDelegate -
- (void)currentTouchPoint:(CGPoint)point {
    if (self.editZoneView.currentPasterView) {//如果当前有正在编辑的动图，且点击的位置正好在动图上
        BOOL hitSubview = [self.editZoneView.currentPasterView touchPoint:point fromView:self.editZoneView];
        if (hitSubview == YES) {
            return;
        }
    }
    AliyunPasterController *pasterController = [self.pasterManager touchPoint:point atTime:[self.player getCurrentTime]];
    if (pasterController) {
        [self.player pause];
        AliyunPasterView *pasterView = (AliyunPasterView *)[pasterController pasterView];
        if (pasterView) {//当前点击的位置有动图 逻辑：将上次有编辑的动图完成，让该次选择的动图进入编辑状态
            [self forceFinishLastEditPasterView];
            [self makePasterControllerBecomeEditStatus:pasterController];
        }
    } else {
        [self forceFinishLastEditPasterView];
    }
}

//强制将上次正在编辑的动图进入编辑完成状态
- (void)forceFinishLastEditPasterView {
    if (!self.editZoneView.currentPasterView) {
        return;
    }
    AliyunPasterController *editPasterController = (AliyunPasterController *)self.editZoneView.currentPasterView.delegate;
    self.editZoneView.currentPasterView.editStatus = NO;
    if (editPasterController.pasterType == AliyunPasterEffectTypeSubtitle) {
        [editPasterController editCompletedWithImage:[self.editZoneView.currentPasterView textImage]];
    } else if (editPasterController.pasterType == AliyunPasterEffectTypeNormal) {
        [editPasterController editCompleted];
    } else {
        [editPasterController editCompletedWithImage:[self.editZoneView.currentPasterView textImage]];
    }
    [self editPasterItemComplete];
    self.editZoneView.currentPasterView = nil;
    
    // 产品要求 动图需要一直放在涂鸦下面，所以每次加新动图，需要重新加一次涂鸦
    if (self.paintImage) {
        [self.editor removePaint:self.paintImage];
        [self.editor applyPaint:self.paintImage];
    }
}

- (void)mv:(CGPoint)fp to:(CGPoint)tp {
    if (self.editZoneView.currentPasterView) {
        [self.editZoneView.currentPasterView touchMoveFromPoint:fp to:tp];
    }
}

- (void)touchEnd {
    if (self.editZoneView.currentPasterView) {
        [self.editZoneView.currentPasterView touchEnd];
    }
}

#pragma mark - AliyunTabControllerDelegate -
- (void)completeButtonClicked {
    [self backgroundTouchButtonClicked:AliyunEditSouceClickTypeNone];
}

- (void)keyboardShouldHidden {
    [_currentTextInputView shouldHiddenKeyboard];
}

- (void)keyboardShouldAppear {
    [_currentTextInputView shouldAppearKeyboard];
}

- (void)textColorChanged:(AliyunColor *)color {
    [_currentTextInputView setFilterTextColor:color];
}

- (void)textFontChanged:(NSString *)fontName {
    [_currentTextInputView setFontName:fontName];
}

#pragma mark - AliyunEditButtonsViewDelegate -
//进入特效
- (void)animationFilterButtonClicked{
    AddAnimationFilterController *addAnimationFilterController = [[AddAnimationFilterController alloc] init];
    addAnimationFilterController.taskPath = self.taskPath;
    addAnimationFilterController.config = self.config;
    addAnimationFilterController.editor = self.editor;
    addAnimationFilterController.movieView = self.movieView;
    [self presentViewController:addAnimationFilterController animated:true completion:nil];
}
//滤镜
- (void)filterButtonClicked{
    [self forceFinishLastEditPasterView];
    [self.filterView showOnlyWithType:FilterAndBeautyViewTypeOnlyFilter Index:_filterIndex filterDataArray:self.filterDataArray];
}
//音乐
- (void)musicButtonClicked {
    MusicPickViewController *musicPickViewController = [[MusicPickViewController alloc] init];
    musicPickViewController.delegate = self;
    [self.navigationController pushViewController:musicPickViewController animated:true];
}

- (void)volumeButtonClicked{
    SoundTrackAndMusicAdjustView *soundTrackAndMusicAdjustView = [[SoundTrackAndMusicAdjustView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    soundTrackAndMusicAdjustView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    soundTrackAndMusicAdjustView.delegate = self;
    [soundTrackAndMusicAdjustView showWith:_mainWeight music:_mixWeight];
}

#pragma mark -  SoundTrackAndMusicAdjustViewDelegate
- (void)soundTrackAndMusicAdjustView:(SoundTrackAndMusicAdjustView *)soundTrackAndMusicAdjustView changedMusicValue:(float)value{
    _mixWeight = (int)value;
    [self adjustVolumeWithMainWeight:_mainWeight andMixWeight:_mixWeight];
}

- (void)soundTrackAndMusicAdjustView:(SoundTrackAndMusicAdjustView *)soundTrackAndMusicAdjustView changedSoundTrackValue:(float)value{
    _mainWeight = (int)value;
    [self adjustVolumeWithMainWeight:_mainWeight andMixWeight:_mixWeight];
}

- (void)reloadDataWithEffectType:(NSInteger)eType {
    [_filterDataArray removeAllObjects];
    [_filterDbHelper queryResourceWithEffecInfoType:eType success:^(NSArray *infoModelArray) {
        for (AliyunEffectMvGroup *mvGroup in infoModelArray) {
            [_filterDataArray addObject:mvGroup];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - MusicPickViewControllerDelegate
- (void)musicPickViewControllerSelectedNone{
    AliyunEffectMusic *effectMusic = [[AliyunEffectMusic alloc] initWithFile:nil];
    //清空所有音乐
    [_editor removeMusics];
    
    effectMusic.startTime = 0;
    effectMusic.duration = 0;
    self.musicId = 0;
    self.startTime = 0;
    self.duration = 0;
    [_editor applyMusic:effectMusic];
}

- (void)musicPickViewControllerSelectedWithMusicId:(NSInteger)musicId musicPath:(NSString *)musicPath musicType:(NSInteger)musicType startTime:(float)startTime duration:(float)duration{
    self.musicId = musicId;
    self.startTime = startTime;
    self.duration = duration;
    self.musicType = musicType;
    
    //清空所有音乐
    [_editor removeMusics];
    
    AliyunEffectMusic *effectMusic = [[AliyunEffectMusic alloc] initWithFile:musicPath];
    effectMusic.startTime = startTime;
    effectMusic.duration = duration;
    [_editor applyMusic:effectMusic];
}

//- (void)musicPickViewControllerSelectedWithMusicPath:(NSString *)musicPath startTime:(float)startTime duration:(float)duration{
//    AliyunEffectMusic *effectMusic = [[AliyunEffectMusic alloc] initWithFile:musicPath];
//    effectMusic.startTime = startTime;
//    effectMusic.duration = duration;
//    [_editor applyMusic:effectMusic];
//

////    AliyunEffectMusic *music = [[AliyunEffectMusic alloc] initWithFile:path];
////
////
////    [self.editor applyMusic:music];
////    [self.player replay];
//}

- (void)filterButtonClicked:(AliyunEditButtonType)type {
//    [self forceFinishLastEditPasterView];
//    [self presentBackgroundButton];
//    _editSouceClickType = AliyunEditSouceClickTypeFilter;
//    [self showEffectView:self.filterView duration:0.2f];
//    [self.filterView reloadDataWithEffectType:type];
}

- (void)pasterButtonClicked {
//    [self forceFinishLastEditPasterView];
//    [self presentBackgroundButton];
//    _editSouceClickType = AliyunEditSouceClickTypePaster;
//    [self showEffectView:self.pasterShowView duration:0.2f];
//    [self.pasterShowView fetchPasterGroupDataWithCurrentShowGroup:nil];
}

- (void)subtitleButtonClicked {
    [self forceFinishLastEditPasterView];
    [self presentBackgroundButton];
    _editSouceClickType = AliyunEditSouceClickTypeSubtitle;
    [self showEffectView:self.captionShowView duration:0.2f];
    [self.captionShowView fetchCaptionGroupDataWithCurrentShowGroup:nil];
}

- (void)mvButtonClicked:(AliyunEditButtonType)type {
    [self forceFinishLastEditPasterView];
    [self presentBackgroundButton];
    _editSouceClickType = AliyunEditSouceClickTypeMV;
    [self showEffectView:self.mvView duration:0.2f];
    [self.mvView reloadDataWithEffectType:type];
}

- (void)paintButtonClicked {
    [self forceFinishLastEditPasterView];
    [self presentBackgroundButton];
    if (self.paintImage) {
        [self.editor removePaint:self.paintImage];
    }
    _editSouceClickType = AliyunEditSouceClickTypePaint;
    [self showEffectView:self.paintShowView duration:0];
    [self.paintShowView updateDrawRect:self.movieView.frame];
}

- (void)showEffectView:(UIView *)view duration:(CGFloat)duration {
    view.hidden = NO;
    [self.view bringSubviewToFront:view];
    [self dismissTopView];
    [UIView animateWithDuration:duration animations:^{
        CGRect f = view.frame;
        f.origin.y = ScreenHeight - CGRectGetHeight(f)-SafeBottom;
        view.frame = f;
    }];
}

- (void)dismissEffectView:(UIView *)view duration:(CGFloat)duration {
    [self dismissBackgroundButton];
    [self showTopView];
    [UIView animateWithDuration:duration animations:^{
        CGRect f = view.frame;
        f.origin.y = ScreenHeight;
        view.frame = f;
    } completion:^(BOOL finished) {
        view.hidden = YES;
    }];
}

- (void)dismissTopView {
    
    [UIView animateWithDuration:.2f animations:^{
        CGRect timelineF = self.timelineView.frame;
        CGRect headerF = self.editHeaderView.frame;
        CGRect movieF = self.movieView.frame;
        CGRect timeF = self.currentTimeLabel.frame;
        timelineF.origin.y = SafeTop;
        headerF.origin.y = timelineF.origin.y - headerF.size.height;
        timeF.origin.y = timelineF.origin.y + timelineF.size.height;
        movieF.origin.y = timelineF.origin.y + timelineF.size.height;
        self.timelineView.frame = timelineF;
        self.editHeaderView.frame = headerF;
        self.movieView.frame = movieF;
        self.currentTimeLabel.frame = timeF;
        [self updateSubViews];
    }];
}

- (void)showTopView {
    
    [UIView animateWithDuration:.2f animations:^{
        CGRect headerF = self.editHeaderView.frame;
        CGRect timelineF = self.timelineView.frame;
        CGRect movieF = self.movieView.frame;
        CGRect timeF = self.currentTimeLabel.frame;
        headerF.origin.y = SafeTop;
        timelineF.origin.y = headerF.origin.y + headerF.size.height;
        movieF.origin.y = timelineF.origin.y + timelineF.size.height;
        timeF.origin.y = timelineF.origin.y + timelineF.size.height;
        self.timelineView.frame = timelineF;
        self.editHeaderView.frame = headerF;
        self.movieView.frame = movieF;
        self.currentTimeLabel.frame = timeF;
        [self updateSubViews];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter {
    AliyunEffectFilter *filter2 =[[AliyunEffectFilter alloc] initWithFile:[filter localFilterResourcePath]];
    [self.editor applyFilter:filter2];
}

- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup {
    NSString *str = [mvGroup localResoucePathWithVideoRatio:(AliyunEffectMVRatio)[_config mediaRatio]];
    if (str) {
        self.isAddMV = YES;
        AliyunEffectMusic *music = [[AliyunEffectMusic alloc] initWithFile:nil];
        [self.editor applyMusic:music];
    } else {
        self.isAddMV = NO;
    }
    [self.editor applyMV:[[AliyunEffectMV alloc] initWithFile:str]];
    [self.player replay];
}

- (void)didSelectEffectMoreMv {
    __weak typeof (self)weakSelf = self;
    [self presentAliyunEffectMoreControllerWithAliyunEffectType:AliyunEffectTypeMV completion:^(AliyunEffectInfo *selectEffect) {
        if (selectEffect) {
            weakSelf.mvView.selectedEffect = selectEffect;
        }
        [weakSelf.mvView reloadDataWithEffectType:AliyunEffectTypeMV];
    }];
}

- (void)animtionFilterButtonClick {
//    [self.player pause];
}

//长按开始时，由于结束时间未定，先将结束时间设置为较长的时间  !!!注意这里的实现方式!!!
- (void)didBeganLongPressEffectFilter:(AliyunEffectFilterInfo *)animtinoFilterInfo {
    [self.player resume];
    AliyunEffectFilter *animationFilter = [[AliyunEffectFilter alloc] initWithFile:[animtinoFilterInfo localFilterResourcePath]];
    
    float currentSec = [self.player getCurrentTime];
    animationFilter.startTime = currentSec;
    animationFilter.endTime = [self.player getDuration];
    
    [self.animationFilters addObject:animationFilter];
    [self.editor applyAnimationFilter:animationFilter];
    
    _processAnimationFilter = [[AliyunEffectFilter alloc] initWithFile:[animtinoFilterInfo localFilterResourcePath]];
    _processAnimationFilter.startTime = currentSec;
    _processAnimationFilter.endTime = currentSec;
    
    [self updateAnimationFilterToTimeline:_processAnimationFilter];
}

- (UIColor *)colorWithName:(NSString *)name {
    UIColor *color = nil;
    if ([name isEqualToString:@"抖动"]) {
        color = [UIColor colorWithRed:254.0/255 green:160.0/255 blue:29.0/255 alpha:0.9];
    } else if ([name isEqualToString:@"幻影"]) {
        color = [UIColor colorWithRed:251.0/255 green:222.0/255 blue:56.0/255 alpha:0.9];
    } else if ([name isEqualToString:@"重影"]) {
        color = [UIColor colorWithRed:98.0/255 green:182.0/255 blue:254.0/255 alpha:0.9];
    } else if ([name isEqualToString:@"科幻"]) {
        color = [UIColor colorWithRed:220.0/255 green:92.0/255 blue:179.0/255 alpha:0.9];
    } else if ([name isEqualToString:@"朦胧"]) {
        color = [UIColor colorWithRed:243.0/255 green:92.0/255 blue:75.0/255 alpha:0.9];
    }
    
    return color;
}


//长按进行时 更新
//- (void)didTouchingProgress {
//    if (_processAnimationFilter) {
//        if (_processAnimationFilter.endTime < _processAnimationFilter.startTime) {
//            return;
//        }
//        _processAnimationFilter.endTime = [self.player getCurrentTime];
//        [self updateAnimationFilterToTimeline:_processAnimationFilter];
//    }
//}

//手势结束后，将当前正在编辑的特效滤镜删掉，重新加一个 这时动效滤镜的开始和结束时间都确定了
- (void)didEndLongPress {
    if (_processAnimationFilter == NULL) { //当前没有正在添加的动效滤镜 则不操作
        return;
    }
    float pendTime = _processAnimationFilter.endTime;
    [self.player pause];
    [self removeAnimationFilterFromTimeline:_processAnimationFilterItem];
    _processAnimationFilterItem = NULL;
    _processAnimationFilter = NULL;
    
    AliyunEffectFilter *currentFilter = [self.animationFilters lastObject];
    NSString *filterPath = [currentFilter path];
    float startTime = currentFilter.startTime;
    float endTime = pendTime;
    
    AliyunEffectFilter *realFilter = [[AliyunEffectFilter alloc] initWithFile:filterPath];
    realFilter.startTime = startTime;
    realFilter.endTime = endTime;
    [self.editor removeAnimationFilter:currentFilter];
    [self.animationFilters removeLastObject];
    
    [self.editor applyAnimationFilter:realFilter];
    [self.animationFilters addObject:realFilter];
    
    [self addAnimationFilterToTimeline:realFilter];
}

- (void)cancelButtonClick {
    [self dismissEffectView:self.filterView duration:0.2f];
    [self dismissEffectView:self.mvView duration:0.2f];
}

- (void)didRevokeButtonClick {
    AliyunEffectFilter *currentFilter = [self.animationFilters lastObject];
    [self.editor removeAnimationFilter:currentFilter];
    [self.animationFilters removeLastObject];
    //TODO:这里删除
    [self removeLastAnimtionFilterItemFromTimeLineView];
}

#pragma mark - Getter

-(AliyunEffectMusicView *)musicView {
    if (!_musicView) {
        _musicView = [[AliyunEffectMusicView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight-220)];
        _musicView.delegate = (id)self;
        [self.view addSubview:_musicView];
    }
    return _musicView;
}

#pragma mark - AliyunEffectMusicViewDelegate

- (void)musicViewDidUpdateMute:(BOOL)mute {
    [self.editor setMute:mute];
}

- (void)musicViewDidUpdateAudioMixWeight:(float)weight {
    [self.editor setAudioMixWeight:weight*100];
}

- (void)musicViewDidUpdateMusic:(NSString *)path {
    AliyunEffectMusic *music = [[AliyunEffectMusic alloc] initWithFile:path];
   
    
    [self.editor applyMusic:music];
    [self.player replay];
}

#pragma mark - AliyunPasterTextInputView -

- (void)keyboardFrameChanged:(CGRect)rect animateDuration:(CGFloat)duration {
    [self.tabController presentTabContainerViewInSuperView:self.view height:rect.size.height duration:duration];
    [self dismissTopView];
}

- (void)editWillFinish:(CGRect)inputviewFrame text:(NSString *)text fontName:(NSString *)fontName {
    [self backgroundTouchButtonClicked:AliyunEditSouceClickTypeNone];
    [self textInputViewEditCompleted];
}

#pragma mark - AliyunPasterShowViewDelegate -

//添加普通动图
- (void)onClickPasterWithPasterModel:(AliyunEffectPasterInfo *)pasterInfo {
    [self.player pause];
    [self forceFinishLastEditPasterView];
    
    AliyunPasterRange range = [self calculatePasterStartTimeWithDuration:[pasterInfo defaultDuration]];
    
    AliyunPasterController *pasterController = [self.pasterManager addPaster:pasterInfo.resourcePath startTime:range.startTime duration:range.duration];
    [self addPasterViewToDisplayAndRender:pasterController pasterFontId:[pasterInfo.fontId integerValue]];
    [self addPasterToTimeline:pasterController];
    [self makePasterControllerBecomeEditStatus:pasterController];
}

- (void)onClickRemovePaster {
    //移除所有的普通动图
    [self dismissEffectView:self.pasterShowView duration:0.2f];
    [self.pasterManager removeAllNormalPasterControllers];
}

- (void)onClickPasterDone {
    [self dismissEffectView:self.pasterShowView duration:0.2f];
}

- (void)onClickMorePaster {
    
    [self forceFinishLastEditPasterView];
    __weak typeof (self)weakSelf = self;
    [self presentAliyunEffectMoreControllerWithAliyunEffectType:AliyunEffectTypePaster completion:^(AliyunEffectInfo *selectEffect) {
        
        [weakSelf.pasterShowView fetchPasterGroupDataWithCurrentShowGroup:(AliyunEffectPasterGroup *)selectEffect];
    }];
}

#pragma mark - AliyunPaintEditViewDelegate -
- (void)onClickPaintFinishButtonWithImagePath:(NSString *)path {

    self.paintImage = [[AliyunEffectImage alloc] initWithFile:path];
    self.paintImage.frame = self.movieView.bounds;
    [self.editor applyPaint:self.paintImage];
    [self dismissEffectView:self.paintShowView duration:0];
}

- (void)onClickPaintCancelButton {
    if (self.paintImage) {
        self.paintImage = nil;
    }
    [self dismissEffectView:self.paintShowView duration:0];
}

#pragma mark - AliyunEffectCaptionShowViewDelegate
//添加字幕动图
- (void)onClickCaptionWithPasterModel:(AliyunEffectPasterInfo *)pasterInfo {
    [self.player pause];
    [self forceFinishLastEditPasterView];
    
    AliyunPasterRange range = [self calculatePasterStartTimeWithDuration:[pasterInfo defaultDuration]];
    AliyunPasterController *pasterController = [self.pasterManager addPaster:pasterInfo.resourcePath startTime:range.startTime duration:range.duration];
    [self addPasterViewToDisplayAndRender:pasterController pasterFontId:[pasterInfo.fontId integerValue]];
    [self addPasterToTimeline:pasterController];
    [self makePasterControllerBecomeEditStatus:pasterController];
}

- (void)onClickFontWithFontInfo:(AliyunEffectFontInfo *)font {
    [self.player pause];
    [self forceFinishLastEditPasterView];
    
    [self presentBackgroundButton];
    AliyunPasterTextInputView *textInputView = [AliyunPasterTextInputView createPasterTextInputView];
    textInputView.fontName = font.fontName;
    [self.view addSubview:textInputView];
    textInputView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 50);
    textInputView.delegate = (id)self;
    _currentTextInputView = textInputView;
}

- (void)onClickRemoveCaption {
    // 移除纯文字动图和字幕动图
    [self dismissEffectView:self.captionShowView duration:0.2f];
    
    [self.pasterManager removeAllSubtitlePasterControllers];
    [self.pasterManager removeAllCaptionPasterControllers];
}

- (void)onClickMoreCaption {
    
    [self forceFinishLastEditPasterView];
    __weak typeof (self)weakSelf = self;
    [self presentAliyunEffectMoreControllerWithAliyunEffectType:AliyunEffectTypeCaption completion:^(AliyunEffectInfo *selectEffect) {
        
        [weakSelf.captionShowView fetchCaptionGroupDataWithCurrentShowGroup:(AliyunEffectCaptionGroup*)selectEffect];
    }];
}

- (void)onClickCaptionDone {
    
    [self dismissEffectView:self.captionShowView duration:0.2f];
}

#pragma mark - AliyunEffectFilter2ViewDelegate

#pragma mark - PresentEffectMoreVC

- (void)presentAliyunEffectMoreControllerWithAliyunEffectType:(AliyunEffectType)effectType
                                           completion:(void(^)(AliyunEffectInfo *selectEffect))completion {
    
    AliyunEffectMoreViewController *effectMoreVC = [[AliyunEffectMoreViewController alloc] initWithEffectType:effectType];
    UINavigationController *effecNC = [[UINavigationController alloc] initWithRootViewController:effectMoreVC];
    [self presentViewController:effecNC animated:YES completion:nil];
    effectMoreVC.effectMoreCallback = ^(AliyunEffectInfo *info){
        completion(info);
    };
}

#pragma mark - Setter -

- (AliyunPasterShowView *)pasterShowView {
    if (!_pasterShowView) {
        _pasterShowView = [[AliyunPasterShowView alloc] initWithFrame:(CGRectMake(0, ScreenHeight, ScreenWidth, SizeHeight(170)))];
        _pasterShowView.delegate = (id)self;
        [self.view addSubview:_pasterShowView];
    }
    return _pasterShowView;
}

- (AliyunEffectCaptionShowView *)captionShowView {
    if (!_captionShowView) {
        _captionShowView = [[AliyunEffectCaptionShowView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, SizeHeight(142))];
        _captionShowView.delegate = (id)self;
        [self.view addSubview:_captionShowView];
    }
    return _captionShowView;
}

- (AliyunEffectMVView *)mvView {
    if (!_mvView) {
        _mvView = [[AliyunEffectMVView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 142)];
        _mvView.delegate = (id<AliyunEffectFilterViewDelegate>)self;
        [self.view addSubview:_mvView];
    }
    return _mvView;
}

- (FilterAndBeautyView *)filterView {
    if (!_filterView) {
        _filterView = [[[NSBundle mainBundle] loadNibNamed:@"FilterAndBeautyView" owner:nil options:nil] lastObject];
        _filterView.delegate = self;
        _filterView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }
    return _filterView;
}

- (AliyunPaintEditView *)paintShowView {
    if (!_paintShowView) {
        _paintShowView = [[AliyunPaintEditView alloc] initWithFrame:(CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight)) drawRect:self.movieView.frame];
        _paintShowView.backgroundColor = [UIColor clearColor];
        _paintShowView.delegate = (id<AliyunPaintEditViewDelegate>)self;
        [self.view addSubview:_paintShowView];
    }
    return _paintShowView;
}

- (AliyunDBHelper *)dbHelper
{
    if (!_dbHelper) {
        _dbHelper = [[AliyunDBHelper alloc] init];
        [_dbHelper openResourceDBSuccess:nil failure:nil];
    }
    return _dbHelper;
}

- (NSMutableArray *)animationFilters {
    if (!_animationFilters) {
        _animationFilters = [[NSMutableArray alloc] init];
    }
    return _animationFilters;
}

@end
