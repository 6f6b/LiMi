//
//  AliyunMusicPickViewController.m
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMusicPickViewController.h"
#import "AliyunMusicPickHeaderView.h"
#import "AliyunMusicPickCell.h"
#import <AVFoundation/AVFoundation.h>
#import "AVAsset+VideoInfo.h"
#import "AliyunMusicPickTopView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AliyunLibraryMusicImport.h"
#import "AliyunPathManager.h"
#import "AliyunMusicPickTabView.h"
//#import <AliyunVideoSDKPro/AliyunNativeParser.h>
//#import <AliyunVideoSDKPro/AliyunCrop.h>
#import "QUMBProgressHUD.h"
#import "AliyunDownloadManager.h"

@interface AliyunMusicPickViewController () <UITableViewDelegate, UITableViewDataSource, AliyunMusicPickHeaderViewDelegate, AliyunMusicPickCellDelegate, AliyunMusicPickTopViewDelegate, AliyunMusicPickTabViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AliyunMusicPickTopView *topView;
@property (nonatomic, strong) AliyunMusicPickTabView *tabView;
@property (nonatomic, strong) NSMutableArray *musics;
@property (nonatomic, assign) NSInteger selectedSection;
@property (nonatomic, strong) AVPlayer *player;
//@property (nonatomic, strong) AVURLAsset *asset;
//@property (nonatomic, strong) AliyunCrop *musicCrop;
@property (nonatomic, assign) CGFloat startTime;
@end

@implementation AliyunMusicPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [self addNotification];
    self.player = [[AVPlayer alloc] init];
    self.musics = [NSMutableArray array];
    
    self.selectedSection = 0;
    if (!_duration) {
        _duration = 8;
    }
    [self setupData];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)dealloc {
    [self removeNotification];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.topView.frame = CGRectMake(0, SafeTop, ScreenWidth, 44);
    self.tableView.frame = CGRectMake(0, 88+SafeTop, ScreenWidth, ScreenHeight - 88-SafeTop-SafeBottom);
}

- (void)setupSubviews {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"app_launch"]];
    imageView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [self.view addSubview:imageView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [self.view addSubview:blurEffectView];

    self.topView = [[AliyunMusicPickTopView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    self.topView.delegate = self;
    [self.view addSubview:self.topView];
    
    self.tabView = [[AliyunMusicPickTabView alloc] initWithFrame:CGRectMake(0, 44+SafeTop, ScreenWidth, 44)];
    self.tabView.delegate = self;
    [self.view addSubview:self.tabView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[AliyunMusicPickCell class] forCellReuseIdentifier:@"AliyunMusicPickCell"];
    [self.tableView registerClass:[AliyunMusicPickHeaderView class] forHeaderFooterViewReuseIdentifier:@"AliyunMusicPickHeaderView"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"UITableViewHeaderFooterView"];

//    self.tableView.backgroundView = blurEffectView;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.view addSubview:blurEffectView];
    [self.view addSubview:self.tableView];
}

- (void)setupData {
    [self fetchRemoteMusic];
}

- (void)fetchRemoteMusic {
    [self.musics removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
        model.name = @"无音乐";
        model.artist = @"V.A.";
        [self.musics addObject:model];
        
        NSString *musicDir = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"music"];
        NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:musicDir error:nil];
        for (NSString *content in dirContents) {
            NSString *path = [musicDir stringByAppendingPathComponent:content];
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
            AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
            model.name = content;
            model.path = path;
            model.duration = [asset avAssetVideoTrackDuration];
            model.artist = [asset artist];
            [self.musics addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)fetchItunesMusic {
    [self.musics removeAllObjects];
    [QUMBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
        model.name = @"无音乐";
        model.artist = @"V.A.";
        [self.musics addObject:model];
        //获得query，用于请求本地歌曲集合
        MPMediaQuery *query = [MPMediaQuery songsQuery];
        //循环获取得到query获得的集合
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        for (MPMediaItemCollection *conllection in query.collections) {
            //MPMediaItem为歌曲项，包含歌曲信息
            for (MPMediaItem *item in conllection.items) {
                AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
                NSString *name = [item valueForProperty:MPMediaItemPropertyTitle];
                NSString *uid = [item valueForProperty:MPMediaItemPropertyPersistentID];
                NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
                NSString *artist = [item valueForKey:MPMediaItemPropertyArtist];
                float duration = [[item valueForKey:MPMediaItemPropertyPlaybackDuration] floatValue];
                NSString *baseString = [[[AliyunPathManager createResourceDir] stringByAppendingPathComponent:@"musicRes"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", uid, name]];
                if (!url) {
                    break;
                }
                if (!url.pathExtension) {
                    break;
                }
                NSString *toString = [[baseString stringByAppendingPathComponent:@"music"] stringByAppendingPathExtension:url.pathExtension];
//                NSArray *filePathArray = [toString componentsSeparatedByString:@"Documents/"];
//                NSString *relativePath = [@"Documents/" stringByAppendingPathComponent:filePathArray.lastObject];
                model.name = name;
                model.path = toString;
                model.artist = artist;
                model.duration = duration;
                // 若拷贝音乐已经存在 则执行下一条拷贝
                if ([[NSFileManager defaultManager] fileExistsAtPath:baseString]) {
                    [self.musics addObject:model];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }else {
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    [[NSFileManager defaultManager] createDirectoryAtPath:baseString withIntermediateDirectories:YES attributes:nil error:nil];
                    NSURL *toURL = [NSURL fileURLWithPath:toString];
                    AliyunLibraryMusicImport* import = [[AliyunLibraryMusicImport alloc] init];
                    [import importAsset:url toURL:toURL completionBlock:^(AliyunLibraryMusicImport* import) {
                        [self.musics addObject:model];
                        dispatch_semaphore_signal(semaphore);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[QUMBProgressHUD HUDForView:self.view] hideAnimated:YES];
            [self.tableView reloadData];
        });
    });
}


#pragma mark - notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playerItemDidReachEnd {
    [self playCurrentItem];
}

#pragma mark - player

- (void)playCurrentItem {
    AliyunMusicPickModel *model = self.musics[_selectedSection];
    AVMutableComposition *composition = [self generateMusicWithPath:model.path start:_startTime duration:_duration];
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:composition]];
    [self.player play];
}

-(AVMutableComposition *)generateMusicWithPath:(NSString *)path start:(float)start duration:(float)duration {
    if (!path) {
        return nil;
    }
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    AVMutableComposition *mutableComposition = [AVMutableComposition    composition]; // Create the video composition track.
    AVMutableCompositionTrack *mutableCompositionAudioTrack =    [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio    preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    CMTime startTime = CMTimeMake(1000*start, 1000);
    CMTime stopTime = CMTimeMake(1000*(start+duration), 1000);
//    CMTimeRange range = CMTimeRangeMake(kCMTimeZero, CMTimeSubtract(stopTime, startTime));
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime,stopTime);
    [mutableCompositionAudioTrack insertTimeRange:exportTimeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    return mutableComposition;
}

#pragma mark - table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AliyunMusicPickModel *mode = self.musics[section];
    if(mode.expand){
        return 1;
    }else {
        return 0;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.musics.count;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"UITableViewHeaderFooterView"];
    view.contentView.backgroundColor = [UIColor whiteColor];
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AliyunMusicPickHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"AliyunMusicPickHeaderView"];
    AliyunMusicPickModel *model = self.musics[section];
    header.tag = section;
    header.titleLabel.text = model.name;
    header.artistLabel.text = model.artist;
    header.delegate = self;
    if (section == _selectedSection) {
        [header shouldExpand:YES];
    }else {
        [header shouldExpand:NO];
    }
    return header;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AliyunMusicPickCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AliyunMusicPickCell"];
    cell.delegate = self;
    AliyunMusicPickModel *model = self.musics[indexPath.section];
    [cell configureMusicDuration:model.duration pageDuration:_duration];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 64;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

#pragma mark - header view delegate

-(void)didSelectHeader:(AliyunMusicPickHeaderView *)view {
    if (_selectedSection >= 0 && view.tag != _selectedSection) {
        // OLD
        AliyunMusicPickModel *model = self.musics[_selectedSection];
        model.expand = NO;
        if (_selectedSection > 0) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:_selectedSection];
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }
        AliyunMusicPickHeaderView *headerView = (AliyunMusicPickHeaderView *)[self.tableView headerViewForSection:_selectedSection];
        [headerView shouldExpand:NO];
    }
    if (view.tag != _selectedSection) {
        // NEW
        _selectedSection = view.tag;
        AliyunMusicPickModel *model = self.musics[_selectedSection];
        model.expand = YES;
        if (_selectedSection > 0) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:_selectedSection];
//            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }else {
            [self.player pause];
        }
        AliyunMusicPickHeaderView *headerView = (AliyunMusicPickHeaderView *)[self.tableView headerViewForSection:_selectedSection];
        [headerView shouldExpand:YES];
    }
}

#pragma mark - cell delegate

-(void)didSelectStartTime:(CGFloat)startTime {
    AliyunMusicPickModel *model = self.musics[_selectedSection];
    _startTime = startTime;
    model.startTime = startTime;
    [self playCurrentItem];
}


#pragma mark - top view delegate

-(void)cancelButtonClicked {
    [self.delegate didCancelPick];
}

-(void)finishButtonClicked {
    [self.player pause];
    AliyunMusicPickModel *model = self.musics[_selectedSection];
    model.duration = _duration;
//     配音功能只支持aac格式，mp3格式的音乐需要转码
//     建议使用aac格式的音乐资源
//    AliyunNativeParser *parser = [[AliyunNativeParser alloc] initWithPath:model.path];
//    NSString *format = [parser getValueForKey:ALIYUN_AUDIO_CODEC];
//    if ([format isEqualToString:@"mp3"]) {
//        _musicCrop = [[AliyunCrop alloc] initWithDelegate:self];
//        NSString *outputPath = [[AliyunPathManager createMagicRecordDir] stringByAppendingPathComponent:[model.path lastPathComponent]];
//        _musicCrop.inputPath = model.path;
//        _musicCrop.outputPath = outputPath;
//        _musicCrop.startTime = model.startTime;
//        _musicCrop.endTime = model.duration + model.startTime;
//        model.path = outputPath;
//        [_musicCrop startCrop];
//        QUMBProgressHUD *hud = [QUMBProgressHUD showHUDAddedTo:self.view animated:YES];
//    }else {
        [self.delegate didSelectMusic:model];
//    }
    
}

#pragma mark - tab view delegate

-(void)didSelectTab:(NSInteger)tab {
    self.selectedSection = 0;
    [self.player pause];
    if (tab == 1) {
        [self fetchItunesMusic];
    }else {
        [self fetchRemoteMusic];
    }
}

#pragma mark - crop

//-(void)cropOnError:(int)error {
//    [[QUMBProgressHUD HUDForView:self.view] hideAnimated:YES];
//}
//
//-(void)cropTaskOnComplete {
//    [[QUMBProgressHUD HUDForView:self.view] hideAnimated:YES];
//    AliyunMusicPickModel *model = self.musics[_selectedSection];
//    [self.delegate didSelectMusic:model];
//}

@end
