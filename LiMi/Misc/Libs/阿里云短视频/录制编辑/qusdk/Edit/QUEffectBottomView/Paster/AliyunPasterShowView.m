//
//  QUPasterSelectView.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterShowView.h"
#import "AliyunPasterGroupCollectionViewCell.h"
#import "AliyunPasterCollectionFlowLayout.h"
#import "AliyunEffectPasterGroup.h"
#import "AliyunEffectPasterInfo.h"
#import "AliyunDBHelper.h"
#import "UIImageView+WebCache.h"
#import "AliyunEffectModelTransManager.h"
#import "AliyunPasterCollectionViewCell.h"

#define kPSViewBottomHeight SizeHeight(40)
#define kPSItemCountPerLine 10

@interface AliyunPasterShowView ()

@property (nonatomic, strong) UICollectionView *packegeCollectionView;
@property (nonatomic, strong) UICollectionView *pasterCollectionView;

@property (nonatomic, strong) NSMutableArray *groupData;
@property (nonatomic, strong) NSMutableArray<AliyunEffectPasterInfo *> *pasterData;
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation AliyunPasterShowView

- (instancetype)init {
    
    if (self = [super init]) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

#pragma mark - UI

- (void)setupSubViews {
    
    self.selectIndex = 0;
    
    [self setupBottomView];
    [self setupCenterView];
}

- (void)setupBottomView {
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - kPSViewBottomHeight, ScreenWidth, kPSViewBottomHeight)];
    [self addSubview:bottomView];
    
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(kPSViewBottomHeight, kPSViewBottomHeight);
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    followLayout.minimumLineSpacing = 0;
    followLayout.minimumInteritemSpacing = 0;
    
    self.packegeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bottomView.frame) - SizeWidth(42), kPSViewBottomHeight) collectionViewLayout:followLayout];
    self.packegeCollectionView.backgroundColor = RGBToColor(27, 33, 51);
    self.packegeCollectionView.showsHorizontalScrollIndicator = NO;
    self.packegeCollectionView.delegate = (id)self;
    self.packegeCollectionView.dataSource = (id)self;
    [self.packegeCollectionView registerClass:[AliyunPasterGroupCollectionViewCell class] forCellWithReuseIdentifier:@"QUPackageCollectionViewShowCell"];
    [self.packegeCollectionView registerClass:[AliyunPasterGroupCollectionViewCell class] forCellWithReuseIdentifier:@"QUPackageCollectionViewButtonCell"];
    self.packegeCollectionView.pagingEnabled = YES;
    [bottomView addSubview: self.packegeCollectionView];
    
    
    UIButton *doneButton  = [UIButton buttonWithType:(UIButtonTypeCustom)];
    doneButton.frame = CGRectMake(CGRectGetMaxX(self.packegeCollectionView.frame), 0, SizeWidth(42), kPSViewBottomHeight);
    doneButton.backgroundColor = RGBToColor(35, 42, 66);
    [doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [doneButton setImage:[AliyunImage imageNamed:@"edit_eff_down"] forState:(UIControlStateNormal)];
    [bottomView addSubview:doneButton];

}


- (void)setupCenterView {
    
    AliyunPasterCollectionFlowLayout *layout = [[AliyunPasterCollectionFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(SizeWidth(65), SizeWidth(65));
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.pasterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - kPSViewBottomHeight) collectionViewLayout:layout];
    self.pasterCollectionView.backgroundColor = RGBToColor(35, 42, 66);
    self.pasterCollectionView.showsHorizontalScrollIndicator = NO;
    self.pasterCollectionView.delegate = (id)self;
    self.pasterCollectionView.dataSource = (id)self;
    [self.pasterCollectionView registerClass:[AliyunPasterCollectionViewCell class] forCellWithReuseIdentifier:@"AliyunPasterCollectionViewCell"];
    self.pasterCollectionView.pagingEnabled = YES;
    [self addSubview: self.pasterCollectionView];

}

#pragma mark - Data 

- (void)fetchPasterGroupDataWithCurrentShowGroup:(AliyunEffectPasterGroup *)group {

    [self.groupData removeAllObjects];
    
    // 头部添加remove Button image
    [self.groupData addObject:@"QPSDK.bundle/edit_paster_none"];
    // 尾部添加add Button image
    [self.groupData addObject:@"QPSDK.bundle/edit_paster_more"];
    
    __weak typeof (self)weakSelf = self;
    AliyunDBHelper *helper = [[AliyunDBHelper alloc] init];
    [helper queryResourceWithEffecInfoType:2 success:^(NSArray *infoModelArray) {
        
        for (int index = 0; index < infoModelArray.count; index++) {
            AliyunEffectPasterGroup *paster = infoModelArray[index];
            
            if (!group) {
                // 没有指定选中的话 就展示第一条
                if (index == infoModelArray.count - 1) {
                    [weakSelf fetchPasterInfoDataWithPasterGroup:paster];
                    _selectIndex = 1;
                }
            } else {
                // 判断是否是当前选中group
                if (paster.eid == group.eid && [paster.name isEqualToString:group.name]) {
                    [weakSelf fetchPasterInfoDataWithPasterGroup:paster];
                    _selectIndex = infoModelArray.count - index;
                }
            }
            
            [weakSelf.groupData insertObject:paster atIndex:1];
        }
        //  当前没有任何下载group时，刷新collectionView为空
        if (infoModelArray.count == 0) {
            [weakSelf fetchPasterInfoDataWithPasterGroup:nil];
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.packegeCollectionView reloadData];
            [weakSelf.packegeCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0] animated:YES scrollPosition:(UICollectionViewScrollPositionNone)];
        });
        
    } failure:^(NSError *error) {
        [weakSelf.packegeCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:nil];
    }];
    
}


- (void)fetchPasterInfoDataWithPasterGroup:(AliyunEffectPasterGroup *)group {
    
    [self.pasterData removeAllObjects];
    
    for (AliyunEffectPasterInfo *listModel in group.pasterList) {
        [self.pasterData addObject:listModel];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self.pasterCollectionView reloadData];
        if ([self.pasterCollectionView numberOfItemsInSection:0] <= 0) {
            return ;
        }
        [self.pasterCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:YES];
    });
}


#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isEqual:self.packegeCollectionView]) {
        return self.groupData.count;
    } else {
        return  self.pasterData.count;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.packegeCollectionView]) {
        
        if (indexPath.row == 0 || indexPath.row == self.groupData.count - 1) {
            // 第一个是removeButton  最后一个是addButton
            AliyunPasterGroupCollectionViewCell *packageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QUPackageCollectionViewButtonCell" forIndexPath:indexPath];
            packageCell.iconImageView.image = [UIImage imageNamed:self.groupData[indexPath.row]];
            return packageCell;
        } else {
            AliyunPasterGroupCollectionViewCell *packageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QUPackageCollectionViewShowCell" forIndexPath:indexPath];
            AliyunEffectPasterGroup *group = self.groupData[indexPath.row];
            [packageCell setGroup:group];
            return packageCell;
        }
    } else {
        
        AliyunPasterCollectionViewCell *pasterCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunPasterCollectionViewCell" forIndexPath:indexPath];
        AliyunEffectPasterInfo *info = self.pasterData[indexPath.row];
        NSString *iconPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"icon"] stringByAppendingPathExtension:@"png"];
        pasterCell.showImageView.image = [UIImage imageWithContentsOfFile:iconPath];
        
        return pasterCell;
    }
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.packegeCollectionView]) {
        
        if (indexPath.row == 0) {
            // remove
            if (self.delegate && [self.delegate respondsToSelector:@selector(onClickRemovePaster)]) {
                [self.delegate onClickRemovePaster];
            }
        } else if (indexPath.row == self.groupData.count - 1) {
            // add
            if (self.delegate && [self.delegate respondsToSelector:@selector(onClickMorePaster)]) {
                [self.delegate onClickMorePaster];
            }
        } else {
            // reload
            self.selectIndex = indexPath.row;
            [self fetchPasterInfoDataWithPasterGroup:self.groupData[indexPath.row]];
        }
        
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onClickPasterWithPasterModel:)]) {
            [self.delegate onClickPasterWithPasterModel:self.pasterData[indexPath.row]];
        }
    }
    
}


#pragma mark - Actions

- (void)doneButtonAction:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickPasterDone)]) {
        [self.delegate onClickPasterDone];
    }
}


#pragma mark - Set
- (NSMutableArray *)groupData {
    
    if (!_groupData) {
        _groupData = [[NSMutableArray alloc] init];
    }
    return _groupData;
}


- (NSMutableArray *)pasterData {
    
    if (!_pasterData) {
        _pasterData = [[NSMutableArray alloc] init];
    }
    return _pasterData;
}


@end
