//
//  AliyunEffectFilterView.m
//  qusdk
//
//  Created by Vienta on 2018/1/12.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectFilterView.h"
#import "AliyunEffectFilterCell.h"
#import "AliyunEffectInfo.h"
#import "AliyunDBHelper.h"


@implementation AliyunEffectFilterView
{
    UICollectionView *_collectionView;
    UIButton *_cancelButton;
    UIButton *_revokeButton;
    UIButton *_filterButton;
    UIButton *_animtionFilterButton;
    UIView *_indicator;
    NSMutableArray *_dataArray;
    AliyunDBHelper *_dbHelper;
    NSInteger _effectType;
    NSInteger _selectIndex;
    UIButton *_selectButton;
    NSTimer *_schedule;
    NSIndexPath *preIdxPath;
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
    UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_collectionView addGestureRecognizer:longPressGes];
    CGFloat height = 34;

    
    _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _filterButton.bounds = CGRectMake(0, 0, 60, height);
    _filterButton.center = CGPointMake(CGRectGetMidX(self.bounds) - 35, CGRectGetHeight(self.bounds) - height/2);
    [_filterButton setTitle:@"滤镜" forState:UIControlStateNormal];
    [_filterButton addTarget:self action:@selector(filterButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_filterButton setTitleColor:rgba(110, 118, 139, 1) forState:UIControlStateNormal];
    [self addSubview:_filterButton];
    _selectButton = _filterButton;
    _selectButton.selected = YES;
    
    _animtionFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _animtionFilterButton.bounds = CGRectMake(0, 0, 60, height);
    _animtionFilterButton.center = CGPointMake(CGRectGetMidX(self.bounds) + 35, CGRectGetHeight(self.bounds) - height/2);
    [_animtionFilterButton setTitle:@"特效" forState:UIControlStateNormal];
    [_animtionFilterButton addTarget:self action:@selector(animtionFilterButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_animtionFilterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_animtionFilterButton setTitleColor:rgba(110, 118, 139, 1) forState:UIControlStateNormal];
    [self addSubview:_animtionFilterButton];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.bounds = CGRectMake(0, 0 , height, height);
    _cancelButton.center = CGPointMake(height / 2 + 10, CGRectGetHeight(self.bounds) - height/2);
    [_cancelButton setImage:[AliyunImage imageNamed:@"cancel"] forState:0];
    [_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelButton];
    
    _revokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _revokeButton.bounds = CGRectMake(0, 0 , height, height);
    _revokeButton.center = CGPointMake(ScreenWidth - height / 2 - 10, CGRectGetHeight(self.bounds) - height/2);
    [_revokeButton setImage:[AliyunImage imageNamed:@"revoke"] forState:0];
    [_revokeButton addTarget:self action:@selector(revokeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _revokeButton.hidden = YES;
    [self addSubview:_revokeButton];
    
    _indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 3)];
    _indicator.center = CGPointMake(_filterButton.center.x, _filterButton.center.y + height / 2);
    _indicator.backgroundColor = rgba(239,75,129,1);
    [self addSubview:_indicator];
}

- (void)touchEnd {
    NSLog(@"~~~ges1:end");
    if (_schedule) {
        if (_delegate) {
            [_delegate didEndLongPress];
        }
        [_schedule invalidate];
        _schedule = nil;
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)ges {
    if (_effectType != 7) {
        return;
    }
    
    CGPoint location = [ges locationInView:_collectionView];
    NSIndexPath *idxPath = [_collectionView indexPathForItemAtPoint:location];

    if (idxPath == NULL) {
        [self touchEnd];
        return;
    }
    if (idxPath.row == 0) {
//        [self touchEnd];
        return;
    }
    
    if  (preIdxPath.row != idxPath.row) {
        [self touchEnd];
    }
    
    switch (ges.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"~~~ges:began");
            preIdxPath = idxPath;
            
            AliyunEffectFilterInfo *currentAnimationFilter = _dataArray[idxPath.row];

            if (_delegate) {
                [_delegate didBeganLongPressEffectFilter:currentAnimationFilter];
            }
            [_schedule invalidate];
            _schedule = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(touchProgress) userInfo:nil repeats:YES];
            [_schedule fire];
        }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"~~~ges:ended");
            [self touchEnd];
            break;
        case UIGestureRecognizerStateChanged:
//            NSLog(@"~~~ges:changed");
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"~~~ges:cancel");
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"~~~ges:failed");
            break;
        case UIGestureRecognizerStatePossible:
            NSLog(@"~~~ges:possible");
            break;
        default:
            NSLog(@"~~~ges:default");
            break;
    }
}

- (void)touchProgress {
    if (_delegate) {
        [_delegate didTouchingProgress];
    }
}

- (void)filterButtonClick {
    [self filterAction];
    [self reloadDataWithEffectType:4];
}

- (void)animtionFilterButtonClick {
    [self.delegate animtionFilterButtonClick];
    [self animationFilterAction];
    [self reloadLocalAnimationFilterData];
}

- (void)animationFilterAction {
    _selectButton.selected = NO;
    _selectButton = _animtionFilterButton;
    _selectButton.selected = YES;
    
    [UIView animateWithDuration:0.24 animations:^{
        _indicator.center = CGPointMake(_animtionFilterButton.center.x, _animtionFilterButton.center.y + 34 / 2);
    }];
}

- (void)filterAction {
    _selectButton.selected = NO;
    _selectButton = _filterButton;
    _selectButton.selected = YES;
    [UIView animateWithDuration:0.24 animations:^{
        _indicator.center = CGPointMake(_filterButton.center.x, _filterButton.center.y + 34 / 2);
    }];
}

- (void)revokeButtonClick {
    if (_delegate) {
        [_delegate didRevokeButtonClick];
    }
}

- (void)reloadDataWithEffectType:(NSInteger)eType {
    [self filterAction];

    _effectType = eType;
    if (_effectType == 7) {
        _revokeButton.hidden = NO;
    } else {
        _revokeButton.hidden = YES;
    }
    [_dataArray removeAllObjects];
    _selectIndex = -1;
    [_dbHelper queryResourceWithEffecInfoType:eType success:^(NSArray *infoModelArray) {
        for (AliyunEffectMvGroup *mvGroup in infoModelArray) {
            [_dataArray addObject:mvGroup];
            if (_selectedEffect) {
                if (mvGroup.eid == _selectedEffect.eid) {
                    _selectIndex = [infoModelArray indexOfObject:mvGroup] + 1;
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

- (void)reloadLocalAnimationFilterData {
    [self animationFilterAction];
    _effectType = 7;
    _revokeButton.hidden = NO;
    [_dataArray removeAllObjects];
//    _selectIndex = -1;
    [_dbHelper queryResourceWithEffecInfoType:_effectType success:^(NSArray *infoModelArray) {
        for (AliyunEffectMvGroup *mvGroup in infoModelArray) {
            [_dataArray addObject:mvGroup];
//            if (_selectedEffect) {
//                if (mvGroup.eid == _selectedEffect.eid) {
//                    _selectIndex = [infoModelArray indexOfObject:mvGroup] + 1;
//                }
//            }
        }
//        if (_effectType == 3) {
//            [self insertDataArray];
//        }
//
        [self insertOrigin];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionView reloadData];
//            if (_selectIndex >= 0) {
//                [_collectionView.delegate collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0]];
//            }
        });
    } failure:^(NSError *error) {
        
    }];
}
- (void)insertOrigin {
    AliyunEffectInfo *effctOrigin = [[AliyunEffectInfo alloc] init];
    effctOrigin.name = @"";
    effctOrigin.eid = -1;
    effctOrigin.effectType = 3;
    effctOrigin.icon = nil;
    effctOrigin.resourcePath = nil;
    [_dataArray insertObject:effctOrigin atIndex:0];
}

- (void)insertDataArray {
    AliyunEffectInfo *effctMore = [[AliyunEffectInfo alloc] init];
    effctMore.name = @"更多";
    effctMore.eid = -1;
    effctMore.effectType = 3;
    effctMore.icon = @"QPSDK.bundle/mv_more";
    [_dataArray addObject:effctMore];
    
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
    
    if (_effectType == 7) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterCell" forIndexPath:indexPath];
    } else {
        if (indexPath.row == 0 || indexPath.row == _dataArray.count - 1) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell" forIndexPath:indexPath];
        } else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterCell" forIndexPath:indexPath];
        }
    }
    
    AliyunEffectInfo *effectInfo = _dataArray[indexPath.row];
    [cell cellModel:effectInfo];
    if (_effectType != 7) {
        if (indexPath.row == _selectIndex) {
            [cell setSelected:YES];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_effectType != 7) {
        AliyunEffectFilterCell *lastSelectCell = (AliyunEffectFilterCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0]];
        [lastSelectCell setSelected:NO];
    }
    
    AliyunEffectInfo *currentEffect = _dataArray[indexPath.row];
    if (_effectType == 4
        ) {
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
        _selectedEffect = currentEffect;
        [_delegate didSelectEffectMV:(AliyunEffectMvGroup *)currentEffect];
    }
    
}

- (void)cancelButtonClick {
    [_delegate cancelButtonClick];
}


@end
