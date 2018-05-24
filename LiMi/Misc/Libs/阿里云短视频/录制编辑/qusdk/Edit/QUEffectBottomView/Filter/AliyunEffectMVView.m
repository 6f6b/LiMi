//
//  AliyunEffectFilterView.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMVView.h"
#import "AliyunEffectFilterCell.h"
#import "AliyunEffectInfo.h"
#import "AliyunDBHelper.h"
@implementation AliyunEffectMVView {
    UICollectionView *_collectionView;
    UIButton *_cancelButton;
    NSMutableArray *_dataArray;
    AliyunDBHelper *_dbHelper;
    NSInteger _effectType;
    NSInteger _selectIndex;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBToColor(27, 33, 51);
        _dbHelper = [[AliyunDBHelper alloc] init];
        _dataArray = [[NSMutableArray alloc] init];
        _selectIndex = -1;
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(50, 70);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 102) collectionViewLayout:layout];
    _collectionView.backgroundColor = RGBToColor(35, 42, 66);
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:nil] forCellWithReuseIdentifier:@"AliyunEffectFilterCell"];
     [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:nil] forCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell"];
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self;
    [self addSubview:_collectionView];
    
    CGFloat height = 34;
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.bounds = CGRectMake(0, 0 , height, height);
    _cancelButton.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - height/2);
    [_cancelButton setImage:[AliyunImage imageNamed:@"edit_eff_down"] forState:0];
    [_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelButton];
    
}

- (void)setFrontMV:(BOOL)frontMV {
    _frontMV = frontMV;
    if (_frontMV == YES) {
        _cancelButton.hidden = YES;
    }
}

- (void)reloadDataWithEffectType:(NSInteger)eType {
    _effectType = eType;
    [_dataArray removeAllObjects];
    _selectIndex = -1;
    [_dbHelper queryResourceWithEffecInfoType:eType success:^(NSArray *infoModelArray) {
        for (AliyunEffectMvGroup *mvGroup in infoModelArray) {
            [_dataArray addObject:mvGroup];
            if (_frontMV == NO) {
                if (_selectedEffect) {
                    if (mvGroup.eid == _selectedEffect.eid) {
                        _selectIndex = [infoModelArray indexOfObject:mvGroup] + 1;
                    }
                }
            }
        }
        if (eType == 3) {
            [self insertDataArray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionView reloadData];
            if (_selectIndex >= 0) {
                [_collectionView.delegate collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0]];
            }
        });
    } failure:^(NSError *error) {
        
    }];
}

- (void)insertDataArray {
    
    AliyunEffectInfo *effctMore = nil;
    if (!_frontMV) {
        effctMore = [[AliyunEffectInfo alloc] init];
        effctMore.name = @"更多";
        effctMore.eid = -1;
        effctMore.effectType = 3;
        effctMore.icon = @"QPSDK.bundle/mv_more";
        [_dataArray addObject:effctMore];
    }
    
    effctMore = [[AliyunEffectInfo alloc] init];
    effctMore.name = @"原片";
    effctMore.eid = -1;
    effctMore.effectType = 3;
    effctMore.icon = @"QPSDK.bundle/MV_none";
    effctMore.resourcePath = nil;
    [_dataArray insertObject:effctMore atIndex:0];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AliyunEffectFilterCell *cell = [[AliyunEffectFilterCell alloc] init];
    
    if (indexPath.row == 0 || indexPath.row == _dataArray.count - 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell" forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterCell" forIndexPath:indexPath];
    }
    
    AliyunEffectInfo *effectInfo = _dataArray[indexPath.row];
    [cell cellModel:effectInfo];
    if (indexPath.row == _selectIndex) {
        [cell setSelected:YES];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunEffectFilterCell *lastSelectCell = (AliyunEffectFilterCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0]];
    [lastSelectCell setSelected:NO];
    
    AliyunEffectInfo *currentEffect = _dataArray[indexPath.row];
    if (_effectType == 4) {
        [_delegate didSelectEffectFilter:(AliyunEffectFilterInfo *)currentEffect];
        
    } else if (_effectType == 3) {
        if ([currentEffect.name isEqualToString:@"更多"]) {
            [_delegate didSelectEffectMoreMv];
            return;
        }
        if (indexPath.row == 0) {
            _selectIndex = -1;
            _selectedEffect = nil;
            [_delegate didSelectEffectMV:nil];
            return;
        }
        _selectIndex = indexPath.row;
        if (_frontMV == NO) {
            _selectedEffect = currentEffect;
        }
        [_delegate didSelectEffectMV:(AliyunEffectMvGroup *)currentEffect];
    }
}

- (void)cancelButtonClick {
    [_delegate cancelButtonClick];
}



@end
