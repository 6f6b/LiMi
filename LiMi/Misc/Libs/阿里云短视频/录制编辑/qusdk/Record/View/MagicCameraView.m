//
//  MagicCameraView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "MagicCameraView.h"
#import "AliyunPasterInfo.h"
#import "AliyunResourceManager.h"
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "AliyunDownloadManager.h"
#import "AliyunMagicCameraEffectCell.h"

@interface MagicCameraView ()
    @property (nonatomic, strong) UIView *topView;
    @property (nonatomic, strong) UIView *bottomView;
    @property (nonatomic, strong) UICollectionView *pasterCollectionView;
    
    @property (nonatomic, strong) NSMutableArray *effectFilterItems;
    @property (nonatomic, strong) NSMutableArray<AliyunPasterInfo*> *effectGifItems;
    @property (nonatomic, strong) AliyunDownloadManager *downloadManager;
    @property (nonatomic, strong) AliyunResourceManager *resourceManager;
    @property (nonatomic, strong) NSMutableArray *allPasterInfoArray;
@end

@implementation MagicCameraView

- (instancetype)init{
    if(self = [self initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)]){
    }
    return self;
}
    
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubview];
        [self fetchData];
    }
    return self;
}

    
    
- (void)setupSubview{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-230)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.topView addGestureRecognizer:tap];
    self.topView.backgroundColor = rgba(0, 0, 0, 0.4);
    [self addSubview:self.topView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight-240, ScreenWidth, 250)];
    self.bottomView.layer.cornerRadius = 10;
    self.bottomView.clipsToBounds = YES;
    self.bottomView.backgroundColor = rgba(0, 0, 0, 0.7);
    [self addSubview:self.bottomView];
    
    
    self.srollView = [[AliyunMagicCameraScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 240) delegate:self];
    self.srollView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:self.srollView];
    self.srollView.delegate = (id)self;
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
        [self loadEffectData:self.effectGifItems];
    });
    
}
    
- (void)fetchData{
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
    
- (void)effectItemFocusToIndex:(NSInteger)index cell:(UICollectionViewCell *)cell
{
            AliyunPasterInfo *pasterInfo = [self.effectGifItems objectAtIndex:index];
            if (pasterInfo.eid <= 0) {
                [self.delegate deleteCurrentEffectPaster];
                return;
            }
    
            if (pasterInfo.bundlePath != nil) {
                [self.delegate addEffectWithPath:pasterInfo.bundlePath];
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
                    [weakSelf.delegate addEffectWithPath:path];
                };
            } else {
    
                [self.delegate addEffectWithPath:[pasterInfo filePath]];
            }
}
    
- (NSArray *)loadLocalData
{
    return [self.resourceManager loadLocalFacePasters];
}
    
- (void)loadEffectData:(NSArray *)effectData{
    self.srollView.effectItems = effectData;
}
    
- (void)destroy{
    [self.srollView resetCircleView];
    [self.srollView hiddenScroll:NO];
}
    
- (void)show{
    [UIApplication.sharedApplication.keyWindow addSubview:self];
}

- (void)dismiss{
    [self removeFromSuperview];
}
    
#pragma mark - MagicCameraScrollViewDelegate -
- (void)focusItemIndex:(NSInteger)index cell:(UICollectionViewCell *)cell{
    [self effectItemFocusToIndex:index cell:cell];
}
 
- (void)mvButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mvButtonClicked)]) {
        [self.delegate mvButtonClicked];
    }
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
@end
