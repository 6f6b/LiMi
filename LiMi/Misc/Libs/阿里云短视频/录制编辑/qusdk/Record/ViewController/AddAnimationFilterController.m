//
//  AddAnimationFilterController.m
//  LiMi
//
//  Created by dev.liufeng on 2018/5/23.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "AddAnimationFilterController.h"
#import "AnimationFilterView.h"
#import "AliyunTimelineView.h"
#import "QUMBProgressHUD.h"
#import "AliyunEditZoneView.h"
#import <AliyunVideoSDkPro/AliyunClip.h>

extern NSString * const AliyunEffectResourceDeleteNoti;

@interface AddAnimationFilterController ()
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIView *movieContainView;
@property (weak, nonatomic) IBOutlet UIView *animationFilterContainView;
@property (nonatomic, strong) AliyunTimelineView *timelineView;
@property (nonatomic,strong) AnimationFilterView *animationFilterView;
@property (nonatomic, strong) id<AliyunIPlayer> player;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) AliyunPasterManager *pasterManager;
@property (nonatomic, strong) id<AliyunIExporter> exporter;
@property (nonatomic, strong) AliyunEditZoneView *editZoneView;
@property (nonatomic, assign) CGSize outputSize;
@property (nonatomic, assign) BOOL isExporting;
@property (nonatomic, strong) AliyunEffectImage *paintImage;

//动效滤镜
@property (nonatomic, strong) NSMutableArray *animationFilters;

@end

@implementation AddAnimationFilterController{
    AliyunEffectFilter *_processAnimationFilter;
    AliyunTimelineFilterItem *_processAnimationFilterItem;
    BOOL _prePlaying;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AnimationFilterView *animationFilterView = [[AnimationFilterView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 105)];
    [self.animationFilterContainView addSubview:animationFilterView];
    animationFilterView.delegate =  (id<AliyunEffectFilter2ViewDelegate>)self;
    self.animationFilterView = animationFilterView;
    
    self.timelineView = [[AliyunTimelineView alloc] initWithFrame:CGRectMake(63, 0, ScreenWidth-63-15, 36)];
    self.timelineView.backgroundColor = [UIColor whiteColor];
    self.timelineView.delegate = (id)self;
    [self.bottomView addSubview:self.timelineView];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(18, 0, 28, 28)];
    CGPoint center = _playButton.center;
    center.y = self.timelineView.center.y;
    _playButton.center = center;
    [_playButton setImage:[UIImage imageNamed:@"btn_zanting"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"btn_bofang"] forState:UIControlStateSelected];
    [_playButton setAdjustsImageWhenHighlighted:NO];
    [_playButton addTarget:self action:@selector(playControlClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:_playButton];
    
    CGRect frame = CGRectMake(0, 0, ScreenWidth*(200.0/375.0), ScreenHeight*(200.0/375.0));
    self.movieView.frame = frame;
    [self.movieContainView addSubview:self.movieView];
    
    // editor
    self.editor.delegate = (id)self;
    // player
    self.player = [self.editor getPlayer];
    // exporter
    self.exporter = [self.editor getExporter];

    
    // setup pasterManager
    self.pasterManager = [self.editor getPasterManager];
    self.pasterManager.displaySize = self.editZoneView.bounds.size;
    self.pasterManager.outputSize = _outputSize;
    self.pasterManager.delegate = (id)self;
    
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
    [self addNotifications];
}

- (NSMutableArray *)animationFilters {
    if (!_animationFilters) {
        _animationFilters = [[NSMutableArray alloc] init];
    }
    return _animationFilters;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.editor startEdit];
    [self.player play];
    [self.playButton setSelected:NO];
    //    NSString *watermarkPath = [[NSBundle mainBundle] pathForResource:@"watermark" ofType:@"png"];
    //    [self.editor setWaterMark:watermarkPath frame:CGRectMake(10, 10, 35, 25)];
    self.timelineView.actualDuration = [self.player getDuration]; //为了让导航条播放时长匹配，必须在这里设置时长
    _prePlaying = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player stop];
    [self.editor stopEdit];
}

- (void)dealloc {
    [self.editor destroyAllEffect];//清理所有效果
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)cancelButtonClicked:(id)sender {
    while (self.animationFilters.count > 0) {
        AliyunEffectFilter *currentFilter = [self.animationFilters lastObject];
        [self.editor removeAnimationFilter:currentFilter];
        [self removeLastAnimtionFilterItemFromTimeLineView];
        [self.animationFilters removeLastObject];
    }
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)saveButtonClicked:(id)sender {
    [self forceFinishLastEditPasterView];
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)revoke:(id)sender {
    [self didRevokeButtonClick];
}

- (void)makePasterControllerBecomeEditStatus:(AliyunPasterController *)pasterController {
    self.editZoneView.currentPasterView = (AliyunPasterView *)[pasterController pasterView];
    [pasterController editWillStart];
    self.editZoneView.currentPasterView.editStatus = YES;
    [self editPasterItemBy:pasterController]; //TimelineView联动
}

- (void)editPasterItemBy:(AliyunPasterController *)pasterController {
    AliyunTimelineItem *timeline = [self.timelineView getTimelineItemWithOjb:pasterController];
    [self.timelineView editTimelineItem:timeline];
}

- (void)editPasterItemComplete {
    [self.timelineView editTimelineComplete];
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
        self.playButton.selected = NO;
    }
    [self.player setActive:YES];
    [self.player play];
}


#pragma mark - Action

- (void)playControlClick:(UIButton *)sender {
    //if (self.isExported) {
    //        self.isExported = NO;
    //        [self.player replay];
    //        sender.selected = NO;
    //    } else {
    if (!sender.selected) {
        [self.player pause];
        sender.selected = YES;
        _prePlaying = NO;
    } else {
        [self forceFinishLastEditPasterView];
        [self.player resume];
        sender.selected = NO;
        _prePlaying = YES;
    }
    //    }
}

#pragma mark -
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter {
    AliyunEffectFilter *filter2 =[[AliyunEffectFilter alloc] initWithFile:[filter localFilterResourcePath]];
    [self.editor applyFilter:filter2];
}

//- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup {
//    NSString *str = [mvGroup localResoucePathWithVideoRatio:(AliyunEffectMVRatio)[_config mediaRatio]];
//    if (str) {
//        self.isAddMV = YES;
//        AliyunEffectMusic *music = [[AliyunEffectMusic alloc] initWithFile:nil];
//        [self.editor applyMusic:music];
//    } else {
//        self.isAddMV = NO;
//    }
//    [self.editor applyMV:[[AliyunEffectMV alloc] initWithFile:str]];
//    [self.player replay];
//    [self.playButton setSelected:NO];
//}

//- (void)didSelectEffectMoreMv {
//    __weak typeof (self)weakSelf = self;
//    [self presentAliyunEffectMoreControllerWithAliyunEffectType:AliyunEffectTypeMV completion:^(AliyunEffectInfo *selectEffect) {
//        if (selectEffect) {
//            weakSelf.mvView.selectedEffect = selectEffect;
//        }
//        [weakSelf.mvView reloadDataWithEffectType:AliyunEffectTypeMV];
//    }];
//}

- (void)animtionFilterButtonClick {
    [self.player pause];
    //[self.playButton setSelected:YES];
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
- (void)didTouchingProgress {
    if (_processAnimationFilter) {
        [self.playButton setSelected:NO];
        if (_processAnimationFilter.endTime < _processAnimationFilter.startTime) {
            return;
        }
        _processAnimationFilter.endTime = [self.player getCurrentTime];
        [self updateAnimationFilterToTimeline:_processAnimationFilter];
    }
}

//手势结束后，将当前正在编辑的特效滤镜删掉，重新加一个 这时动效滤镜的开始和结束时间都确定了
- (void)didEndLongPress {
    if (_processAnimationFilter == NULL) { //当前没有正在添加的动效滤镜 则不操作
        return;
    }
    float pendTime = _processAnimationFilter.endTime;
    [self.player pause];
    [self.playButton setSelected:YES];
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

- (void)didRevokeButtonClick {
    AliyunEffectFilter *currentFilter = [self.animationFilters lastObject];
    [self.editor removeAnimationFilter:currentFilter];
    [self.animationFilters removeLastObject];
    //TODO:这里删除
    [self removeLastAnimtionFilterItemFromTimeLineView];
}

#pragma mark - timeline相关
- (void)removeAnimationFilterFromTimeline:(AliyunTimelineFilterItem *)animationFilterItem {
    [self.timelineView removeTimelineFilterItem:animationFilterItem];
}

- (void)removeLastAnimtionFilterItemFromTimeLineView {
    [self.timelineView removeLastFilterItemFromTimeline];
}

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
    self.playButton.selected = YES;
    [self forceFinishLastEditPasterView];
}

- (void)timelineDraggingAtTime:(CGFloat)time {
    [self.player seek:time];
    
//    self.currentTimeLabel.text = [self stringFromTimeInterval:time];
//    [self.currentTimeLabel sizeToFit];
}

- (void)timelineEndDraggingAndDecelerate:(CGFloat)time  {
    if (_prePlaying) {
        [self.player resume];
        [self.playButton setSelected:NO];
    }
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
        [self.playButton setSelected:YES];
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

#pragma mark - AliyunIPlayerCallback -
- (void)playerDidStart {
    NSLog(@"play start");
    [self.playButton setSelected:NO];
}

- (void)playerDidEnd {
    [self.playButton setSelected:YES];
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
    [self.playButton setSelected:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"video_reminder_common", nil) message:NSLocalizedString(@"video_error_edit", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"video_affirm_common", nil) otherButtonTitles: nil];
        [alert show];
    });
}
@end
