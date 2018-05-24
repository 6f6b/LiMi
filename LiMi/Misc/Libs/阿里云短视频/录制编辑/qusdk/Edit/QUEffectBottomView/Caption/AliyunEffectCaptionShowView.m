//
//  AliyunEffectCaptionShowView.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectCaptionShowView.h"
#import "AliyunEffectCaptionGroup.h"
#import "AliyunEffectPasterInfo.h"
#import "AliyunEffectFontInfo.h"
#import "AliyunPasterGroupCollectionViewCell.h"
#import "AliyunCaptionCollectionViewCell.h"
#import "AliyunDBHelper.h"
#import "UIImageView+WebCache.h"
#import "AliyunEffectFontManager.h"

#define kCSViewBottomHeight SizeHeight(40)


@interface AliyunEffectCaptionShowView ()

@property (nonatomic, strong) UICollectionView *groupCollectionView;
@property (nonatomic, strong) UICollectionView *pasterCollectionView;

@property (nonatomic, strong) NSMutableArray *groupData;
@property (nonatomic, strong) NSMutableArray *fontData;
@property (nonatomic, strong) NSMutableArray<AliyunEffectPasterInfo *> *pasterData;
@property (nonatomic, strong) AliyunDBHelper *dbHelper;
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation AliyunEffectCaptionShowView

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

- (void)removeFromSuperview {
    
    [self.dbHelper closeDB];
    [super removeFromSuperview];
}

#pragma mark - UI
- (void)setupSubViews {
    
    self.selectIndex = 0;
    
    [self setupBottomView];
    [self setupCenterView];
}



- (void)setupBottomView {
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - kCSViewBottomHeight, ScreenWidth, kCSViewBottomHeight)];
    [self addSubview:bottomView];
    
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(kCSViewBottomHeight, kCSViewBottomHeight);
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    followLayout.minimumLineSpacing = 0;
    followLayout.minimumInteritemSpacing = 0;
    
    self.groupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bottomView.frame) - SizeWidth(42), kCSViewBottomHeight) collectionViewLayout:followLayout];
    self.groupCollectionView.backgroundColor = RGBToColor(27, 33, 51);
    self.groupCollectionView.showsHorizontalScrollIndicator = NO;
    self.groupCollectionView.delegate = (id)self;
    self.groupCollectionView.dataSource = (id)self;
    [self.groupCollectionView registerClass:[AliyunPasterGroupCollectionViewCell class] forCellWithReuseIdentifier:@"AliyunPasterGroupCollectionViewShowCell"];
    [self.groupCollectionView registerClass:[AliyunPasterGroupCollectionViewCell class] forCellWithReuseIdentifier:@"AliyunPasterGroupCollectionViewFuncCell"];
    self.groupCollectionView.pagingEnabled = YES;
    [bottomView addSubview: self.groupCollectionView];
    
    
    UIButton *doneButton  = [UIButton buttonWithType:(UIButtonTypeCustom)];
    doneButton.frame = CGRectMake(CGRectGetMaxX(self.groupCollectionView.frame), 0, SizeWidth(42), kCSViewBottomHeight);
    doneButton.backgroundColor = RGBToColor(35, 42, 66);
    [doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [doneButton setImage:[AliyunImage imageNamed:@"edit_eff_down"] forState:(UIControlStateNormal)];
    [bottomView addSubview:doneButton];
    
}


- (void)setupCenterView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(SizeWidth(80), SizeWidth(80));
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.pasterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - kCSViewBottomHeight) collectionViewLayout:layout];
    self.pasterCollectionView.backgroundColor = RGBToColor(35, 42, 66);
    self.pasterCollectionView.showsHorizontalScrollIndicator = NO;
    self.pasterCollectionView.delegate = (id)self;
    self.pasterCollectionView.dataSource = (id)self;
    [self.pasterCollectionView registerClass:[AliyunCaptionCollectionViewCell class] forCellWithReuseIdentifier:@"AliyunCaptionCollectionViewFontCell"];
    [self.pasterCollectionView registerClass:[AliyunCaptionCollectionViewCell class] forCellWithReuseIdentifier:@"AliyunCaptionCollectionViewCaptionCell"];
    self.pasterCollectionView.pagingEnabled = YES;
    [self addSubview: self.pasterCollectionView];
    
}

#pragma mark - Data

- (void)fetchCaptionGroupDataWithCurrentShowGroup:(AliyunEffectCaptionGroup *)group {
    
    [self.groupData removeAllObjects];
    
    // 头部添加remove Button image
    [self.groupData addObject:@"QPSDK.bundle/edit_paster_none"];
    // 尾部添加add Button image
    [self.groupData addObject:@"QPSDK.bundle/edit_paster_more"];
    
    __weak typeof (self)weakSelf = self;
    AliyunDBHelper *helper = [[AliyunDBHelper alloc] init];
    [helper queryResourceWithEffecInfoType:6 success:^(NSArray *infoModelArray) {
        for (int index = 0; index < infoModelArray.count; index++) {
            AliyunEffectCaptionGroup *paster = infoModelArray[index];
            
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
            [weakSelf.groupCollectionView reloadData];
            [weakSelf.groupCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0] animated:YES scrollPosition:(UICollectionViewScrollPositionNone)];
        });
    } failure:^(NSError *error) {
        [weakSelf.groupCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:nil];
    }];
    
}


- (void)fetchPasterInfoDataWithPasterGroup:(AliyunEffectCaptionGroup *)group {
    
    [self.fontData removeAllObjects];
    [self.pasterData removeAllObjects];

    if (group) {
        [self fetchFontData];
    }
    
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

// 获取字体
- (void)fetchFontData {
    
    AliyunDBHelper *helper = [[AliyunDBHelper alloc] init];

    [helper queryResourceWithEffecInfoType:1 success:^(NSArray *infoModelArray) {
        
        for (AliyunEffectFontInfo *info in infoModelArray) {
            // 检测字体是否注册
            UIFont* aFont = [UIFont fontWithName:info.fontName size:14.0];
            BOOL isRegister = (aFont && ([aFont.fontName compare:info.fontName] == NSOrderedSame || [aFont.familyName compare:info.fontName] == NSOrderedSame));
            if (!isRegister) {
                NSString *fontPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"font"] stringByAppendingPathExtension:@"ttf"];
                NSString *registeredName = [[AliyunEffectFontManager manager] registerFontWithFontPath:fontPath];
                if (registeredName) {
                    [self.fontData addObject:info];
                }
            } else {
                [self.fontData addObject:info];
            }
        }

        [self.pasterCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:nil];
        
    } failure:^(NSError *error) {
        [self.pasterCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:nil];
    }];

}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isEqual:self.groupCollectionView]) {
        return self.groupData.count;
    } else {
        return self.pasterData.count + self.fontData.count;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.groupCollectionView]) {

        if (indexPath.row == 0 || indexPath.row == (self.groupData.count - 1)) {
            // 第一个是removeButton  最后一个是addButton
            AliyunPasterGroupCollectionViewCell *packageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunPasterGroupCollectionViewFuncCell" forIndexPath:indexPath];
            packageCell.iconImageView.image = [UIImage imageNamed:self.groupData[indexPath.row]];
            
            return packageCell;
        } else {
            AliyunPasterGroupCollectionViewCell *packageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunPasterGroupCollectionViewShowCell" forIndexPath:indexPath];
            AliyunEffectCaptionGroup *group = self.groupData[indexPath.row];
            [packageCell setGroup:group];
            return packageCell;
        }

    } else {
        
        if (indexPath.row < self.pasterData.count) {
            // 字幕展示区
            AliyunCaptionCollectionViewCell *pasterCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunCaptionCollectionViewCaptionCell" forIndexPath:indexPath];
            AliyunEffectPasterInfo *info = self.pasterData[indexPath.row];

            NSString *iconPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"icon"] stringByAppendingPathExtension:@"png"];
            pasterCell.showImageView.image = [UIImage imageWithContentsOfFile:iconPath];
            
            return pasterCell;
        } else {
            // 字体展示区
            AliyunCaptionCollectionViewCell *pasterCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunCaptionCollectionViewFontCell" forIndexPath:indexPath];
            
            AliyunEffectFontInfo *font = self.fontData[indexPath.row - self.pasterData.count];
            NSString *iconPath = [[NSHomeDirectory() stringByAppendingPathComponent:font.resourcePath] stringByAppendingPathComponent:@"icon.png"];
            pasterCell.showImageView.image = [UIImage imageWithContentsOfFile:iconPath];
            if (font.eid == -2) {
                // 系统字体
                pasterCell.showImageView.image = [AliyunImage imageNamed:@"system_font_icon"];
            }
            
            return pasterCell;
        }
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.groupCollectionView]) {
        
        if (indexPath.row == 0) {
            // remove
            if (self.delegate && [self.delegate respondsToSelector:@selector(onClickRemoveCaption)]) {
                [self.delegate onClickRemoveCaption];
            }
        } else if (indexPath.row == self.groupData.count - 1) {
            // add
            if (self.delegate && [self.delegate respondsToSelector:@selector(onClickMoreCaption)]) {
                [self.delegate onClickMoreCaption];
            }
        } else {
            // reload
            self.selectIndex = indexPath.row;
            [self fetchPasterInfoDataWithPasterGroup:self.groupData[indexPath.row]];
        }
    } else {
        if (indexPath.row < self.pasterData.count) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onClickCaptionWithPasterModel:)]) {
                [self.delegate onClickCaptionWithPasterModel:self.pasterData[indexPath.row]];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onClickFontWithFontInfo:)]) {
                [self.delegate onClickFontWithFontInfo:self.fontData[indexPath.row - self.pasterData.count]];
            }
        }
    }
}


#pragma mark - Actions

- (void)doneButtonAction:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickCaptionDone)]) {
        [self.delegate onClickCaptionDone];
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

- (NSMutableArray *)fontData {
    
    if (!_fontData) {
        _fontData = [[NSMutableArray alloc] init];
    }
    return _fontData;
}

- (AliyunDBHelper *)dbHelper {
    
    if (!_dbHelper) {
        _dbHelper = [[AliyunDBHelper alloc] init];
    }
    return _dbHelper;
}

@end
