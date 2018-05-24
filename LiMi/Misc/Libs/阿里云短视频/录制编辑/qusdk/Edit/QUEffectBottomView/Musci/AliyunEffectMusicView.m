//
//  AliyunEffectMusicView.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMusicView.h"
#import "AliyunEffectMusicCell.h"
#import "AliyunEffectMusicTabView.h"
#import "AliyunResourceRequestManager.h"
#import "AliyunResourceDownloadManager.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunEffectModelTransManager.h"
#import "AliyunEffectMusicInfo.h"
#import "AliyunDBHelper.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AliyunLibraryMusicImport.h"
#import "AliyunResourceDownloadManager.h"
#import "AliyunPathManager.h"
#import "QUMBProgressHUD.h"

@interface AliyunEffectMusicView () <UITableViewDataSource, UITableViewDelegate,AliyunEffectMusicControlViewDelegate, AliyunEffectMusicTabViewDelegate, AliyunEffectMusicCellDelegate>


@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) AliyunEffectMusicTabView *tabView;
@property (nonatomic, strong) UILabel *noneDataLabel;
@property (nonatomic, strong) AliyunDBHelper *dbHelper;
@property (nonatomic, strong) NSMutableArray<AliyunEffectMusicInfo *> *dataArray;
@property (nonatomic, assign) NSInteger currentSelectTab;   // 记录当前选中tab
@property (nonatomic, assign) NSInteger localSelectId;      // 记录当前选中的localMusicId
@property (nonatomic, assign) NSInteger serverSelectId;     // 记录当前选中的serverMusicId

@end

@implementation AliyunEffectMusicView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.currentSelectTab = 0;
    self.localSelectId = 0;
    self.serverSelectId = 0;
    
    self.dataArray = [NSMutableArray array];
    self.dbHelper = [[AliyunDBHelper alloc] init];
    [self.dbHelper openResourceDBSuccess:nil failure:nil];
    
    self.backgroundColor = rgba(35,42,66,0.5);
    self.controlView = [[AliyunEffectMusicControlView alloc] initWithFrame:CGRectZero];
    self.controlView.delegate = self;
    [self addSubview:self.controlView];
    
    self.noneDataLabel = [[UILabel alloc] init];
    self.noneDataLabel.frame = self.bounds;
    self.noneDataLabel.text = NSLocalizedString(@"music_import_itunes_edit", nil);
    self.noneDataLabel.textColor = [UIColor whiteColor];
    self.noneDataLabel.font = [UIFont systemFontOfSize:14.f];
    self.noneDataLabel.textAlignment = NSTextAlignmentCenter;
    self.noneDataLabel.backgroundColor = rgba(35,42,66,1);
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.itemSize = CGSizeMake(ScreenWidth, 40);
    self.flowLayout.minimumLineSpacing = 2;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.tableview = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = rgba(27,33,51,1);
    [self.tableview registerClass:[AliyunEffectMusicCell class] forCellReuseIdentifier:@"AliyunEffectMusicCell"];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableview];
    
    self.tabView = [[AliyunEffectMusicTabView alloc] initWithFrame:CGRectZero];
    self.tabView.delegate = self;
    self.tabView.backgroundColor = rgba(35,42,66,1);
    [self addSubview:self.tabView];
    
    if (self.currentSelectTab == 0) {
        [self fetchListData];
    } else {
        [self fetchItunesMusic];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    self.controlView.frame = CGRectMake(0, 0, width, 40);
    self.tableview.frame = CGRectMake(0, 40, width, height - 40 -48);
    self.tabView.frame = CGRectMake(0, height-48, width, 48);
    self.noneDataLabel.frame = CGRectMake(0, 40, width, height-40-48);
}


#pragma mark - Public

- (void)refreshWithMute:(BOOL)mute mixWeight:(float)weight muiscPath:(NSString *)path {
    
    if (self.currentSelectTab == 0) {
        [self fetchListData];
    } else {
        [self fetchItunesMusic];
    }
    self.controlView.buttonMute.selected = mute;
    self.controlView.sliderVolume.value = weight;
}

#pragma mark - fetch

- (void)fetchListData {
    [QUMBProgressHUD showHUDAddedTo:self animated:YES];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __weak __typeof (self)weakSelf = self;
    [self.dataArray removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    
    [AliyunResourceRequestManager requestWithEffectTypeTag:AliyunEffectTypeMusic success:^(NSArray *resourceListArray) {
        
        for (NSDictionary *resourceDic in resourceListArray) {
            AliyunEffectMusicInfo *musicInfo = [[AliyunEffectMusicInfo alloc] initWithDictionary:resourceDic error:nil];
            [musicInfo setValue:@(AliyunEffectTypeMusic) forKey:@"effectType"];
            BOOL isContain = [weakSelf.dbHelper queryOneResourseWithEffectInfo:musicInfo];
            [musicInfo setValue:@(isContain) forKey:@"isDBContain"];
            if (isContain) {
                // 已经下载了的 放在最上面
                NSString *resourcePath = [[[[[AliyunPathManager resourceRelativeDir] stringByAppendingPathComponent:@"musicRes"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@", musicInfo.eid, musicInfo.name]] stringByAppendingPathComponent:@"music"] stringByAppendingPathExtension:@"mp3"];
                [musicInfo setValue:resourcePath forKey:@"resourcePath"];
                [weakSelf.dataArray insertObject:musicInfo atIndex:0];
            } else {
                [weakSelf.dataArray addObject:musicInfo];
            }
        }
        [self addNoneMusicModel];
        
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSError *error) {
        // 请求失败时加载本地数据
        [weakSelf.dbHelper queryResourceWithEffecInfoType:AliyunEffectTypeMusic success:^(NSArray *infoModelArray) {
            for (AliyunEffectMusicInfo *model in infoModelArray) {
                [model setValue:@(1) forKey:@"isDBContain"];
                [weakSelf.dataArray addObject:model];
            }
            [self addNoneMusicModel];
            
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSError *error) {
            [self addNoneMusicModel];
            
            dispatch_semaphore_signal(semaphore);
        }];
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[QUMBProgressHUD HUDForView:self] hideAnimated:YES];
        [self.tableview reloadData];
    });
        
    });
}

- (void)fetchItunesMusic {
    [QUMBProgressHUD showHUDAddedTo:self animated:YES];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.dataArray removeAllObjects];
    //获得query，用于请求本地歌曲集合
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    //循环获取得到query获得的集合
    for (MPMediaItemCollection *conllection in query.collections) {
        //MPMediaItem为歌曲项，包含歌曲信息
        for (MPMediaItem *item in conllection.items) {
            
            AliyunEffectMusicInfo *info = [[AliyunEffectMusicInfo alloc] init];
            
            [info setValue:@(5) forKey:@"effectType"];
            
            NSString *name = [item valueForProperty:MPMediaItemPropertyTitle];
            NSString *uid = [item valueForProperty:MPMediaItemPropertyPersistentID];
            NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
            
            NSString *baseString = [[[AliyunPathManager createResourceDir] stringByAppendingPathComponent:@"musicRes"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", uid, name]];
            
            if (!url) {
                break;
            }
            if (!url.pathExtension) {
                break;
            }
            NSString *toString = [[baseString stringByAppendingPathComponent:@"music"] stringByAppendingPathExtension:url.pathExtension];
            NSArray *filePathArray = [toString componentsSeparatedByString:@"Documents/"];
            NSString *relativePath = [@"Documents/" stringByAppendingPathComponent:filePathArray.lastObject];
            [info setValue:name forKey:@"name"];
            [info setValue:uid forKey:@"eid"];
            [info setValue:relativePath forKey:@"resourcePath"];
            [info setValue:@(1) forKey:@"isDBContain"];
            
            [self.dataArray addObject:info];
            
            // 若拷贝音乐已经存在 则执行下一条拷贝
            if ([[NSFileManager defaultManager] fileExistsAtPath:baseString]) {
                break;
            }
            
            [[NSFileManager defaultManager] createDirectoryAtPath:baseString withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSURL *toURL = [NSURL fileURLWithPath:toString];
            
            AliyunLibraryMusicImport* import = [[AliyunLibraryMusicImport alloc] init];
            
            [import importAsset:url toURL:toURL completionBlock:^(AliyunLibraryMusicImport* import) {
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
        }
    }
    
    if (self.dataArray.count == 0) {
        [self addSubview:self.noneDataLabel];
        [self.tableview removeFromSuperview];
        [[QUMBProgressHUD HUDForView:self] hideAnimated:YES];
        return;
    }
    [self addNoneMusicModel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[QUMBProgressHUD HUDForView:self] hideAnimated:YES];
        [self.tableview reloadData];
    });
    
}

- (void)addNoneMusicModel {
    
    NSDictionary *noneDictionary = @{@"eid":@(0),
                                     @"name":NSLocalizedString(@"music_none_lable_edit", nil),
                                     @"isDBContain":@(1)};
    
    AliyunEffectMusicInfo *noneInfo = [[AliyunEffectMusicInfo alloc] initWithDictionary:noneDictionary error:nil];
    [self.dataArray insertObject:noneInfo atIndex:0];
}

#pragma mark - load


#pragma mark - AliyunEffectMusicCellDelegate

- (void)musicCell:(AliyunEffectMusicCell *)cell willDown:(AliyunEffectMusicInfo *)musicInfo {
    
    NSIndexPath *indexPath = [self.tableview indexPathForCell:cell];
    AliyunEffectMusicInfo *info = self.dataArray[indexPath.row];
    [self.dbHelper openResourceDBSuccess:nil failure:nil];
    NSDictionary *infoDic = @{@"id":@(info.eid),
                              @"effectType":@(info.effectType),
                              @"name":info.name,
                              @"url":info.url,};
    
    AliyunEffectResourceModel *model = [[AliyunEffectResourceModel alloc] initWithDictionary:infoDic error:nil];
    AliyunResourceDownloadTask *task = [[AliyunResourceDownloadTask alloc] initWithModel:model];
    AliyunResourceDownloadManager *manager = [[AliyunResourceDownloadManager alloc] init];
    [manager addDownloadTask:task progress:^(CGFloat progress) {
        if (progress >= 1.0) {
            progress = 0.99;
        }
        [cell updateProgress:progress];
    } completionHandler:^(AliyunEffectResourceModel *newModel, NSError *error) {
        if (error) {
            [cell updateDownloadFaliure];
        } else {
            [cell updateProgress:1];
            [musicInfo setValue:newModel.resourcePath forKey:@"resourcePath"];
            [musicInfo setValue:@(newModel.isDBContain) forKey:@"isDBContain"];
            self.dataArray[indexPath.row] = musicInfo;
            [cell setMusicInfo: musicInfo];
            [self.dbHelper insertDataWithEffectResourceModel:newModel];
        }
    }];
}

#pragma mark - AliyunEffectMusicControlViewDelegate

- (void)controlViewDidUpdateMute:(BOOL)mute {
    [_delegate musicViewDidUpdateMute:mute];
}

- (void)controlViewDidUpadteVolume:(CGFloat)volume {
    [_delegate musicViewDidUpdateAudioMixWeight:1-volume];
}

#pragma mark - AliyunEffectMusicTabViewDelegate

- (void)tabViewDidSelectTab:(NSInteger)tab {
    
    if (self.currentSelectTab == tab) {
        return;
    }
    self.currentSelectTab = tab;
    [self.noneDataLabel removeFromSuperview];
    if (![self.subviews containsObject:self.tableview]) {
        [self addSubview:self.tableview];
    }
    if (tab == 0) {
        [self fetchListData];
    } else {
        [self fetchItunesMusic];
    }
}


#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AliyunEffectMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AliyunEffectMusicCell" forIndexPath:indexPath];
    cell.delegate = self;
    AliyunEffectMusicInfo *musicInfo = self.dataArray[indexPath.row];
    cell.musicInfo = musicInfo;
    NSInteger currentSelectMusicId = self.currentSelectTab?self.localSelectId:self.serverSelectId;

    if (currentSelectMusicId == musicInfo.eid) {
        [tableView selectRowAtIndexPath:indexPath animated:YES
                         scrollPosition:(UITableViewScrollPositionNone)];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AliyunEffectMusicInfo *music = self.dataArray[indexPath.row];
    NSString *resourcePath = music.resourcePath;
    
    // 缓存选中的音乐id
    if (self.currentSelectTab == 0) {
        self.serverSelectId = music.eid;
        self.localSelectId = -1;
    } else {
        self.localSelectId = music.eid;
        self.serverSelectId = -1;
    }
    
    if (!music.isDBContain) {
        return;
    }
    // 更新混音权重为0.5   无音乐cell为1
    CGFloat weight = 0.5;
    if (indexPath.row == 0) {
        weight = 1;
    }
    [self.controlView updateControlSliderWithWeight:weight];
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicViewDidUpdateAudioMixWeight:)]) {
        [self.delegate musicViewDidUpdateAudioMixWeight:0.5];
    }
    // 更新音乐
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicViewDidUpdateMusic:)]) {
        if (resourcePath) {
            [self.delegate musicViewDidUpdateMusic:[NSHomeDirectory() stringByAppendingPathComponent:resourcePath]];
        }else {
            [self.delegate musicViewDidUpdateMusic:nil];
        }        
    }
}


@end
