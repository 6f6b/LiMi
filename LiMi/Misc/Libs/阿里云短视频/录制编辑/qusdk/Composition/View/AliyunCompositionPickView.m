//
//  AliyunCompositionPickView.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCompositionPickView.h"
#import "AliyunCompositionPickCell.h"
#import "QUReorderableCollectionViewFlowLayout.h"
#import "QUMBProgressHUD.h"

@interface AliyunCompositionPickView () <UICollectionViewDelegate, UICollectionViewDataSource, AliyunCompositionPickCellDelegate>
@property (nonatomic, strong) UIButton *buttonNext;
@property (nonatomic, strong) UILabel *labelDuration;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) CGFloat duration;
@end


@implementation AliyunCompositionPickView

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

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.labelDuration.frame = CGRectMake(10, 10, 100, 20);
    self.buttonNext.frame = CGRectMake(width-56-15, 8, 56, 24);
    self.collectionView.frame = CGRectMake(0, 40, width, height-40);
}

- (void)setup {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    self.labelDuration = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 42.5, 10)];
    self.labelDuration.text = @"总时长 00:00";
    self.labelDuration.textColor = RGBToColor(110,118,139);
    self.labelDuration.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.labelDuration];
    
    self.buttonNext = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonNext.frame = CGRectMake(width-28-5, 4, 28, 12);
    [self.buttonNext setTitle:@"下一步" forState:UIControlStateNormal];
    [self.buttonNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonNext setBackgroundColor:RGBToColor(239, 75, 129)];
    self.buttonNext.titleLabel.font = [UIFont systemFontOfSize:12];
    self.buttonNext.layer.cornerRadius = 2;
    [self.buttonNext addTarget:self action:@selector(finishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.buttonNext];
    
    QUReorderableCollectionViewFlowLayout *layout = [[QUReorderableCollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setMinimumLineSpacing:4];
    [layout setMinimumInteritemSpacing:0];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, width, height-20) collectionViewLayout:layout];
    [self.collectionView registerClass:[AliyunCompositionPickCell class] forCellWithReuseIdentifier:@"AliyunCompositionPickCell"];
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.clipsToBounds = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = RGBToColor(35, 42, 66);
    [self addSubview:self.collectionView];
    
    self.assets = [NSMutableArray array];
}

#pragma mark - public 

- (void)addCompositionInfo:(AliyunCompositionInfo *)info {
    [self.assets addObject:info];
    [self refresh];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.assets.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

- (NSArray *)getPickedAssets {
    return _assets;
}

- (void)refresh {
    [self.collectionView reloadData];
    CGFloat duration = [self durationWithCurrentAssets];
    self.labelDuration.text = [NSString stringWithFormat:@"总时长 %d",  (int)(duration + 0.5)];
}

#pragma mark - Tool

- (CGFloat)durationWithCurrentAssets {
    CGFloat duration = 0;
    for (AliyunCompositionInfo *info in self.assets) {
        duration += info.duration;
    }
    return duration;
}

- (int)videoCounnts {
    int i = 0;
    for (AliyunCompositionInfo *info in self.assets) {
        if (info.phAsset == nil) {
            i++;
        }
    }
    
    return i;
}

#pragma mark - AliyunCompositionPickCellDelegate

-(void)pickCellWillClose:(AliyunCompositionPickCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self.assets removeObjectAtIndex:indexPath.item];
    [self refresh];
}

#pragma mark - action

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunCompositionInfo *model = self.assets[indexPath.item];
    [_delegate pickViewDidSelectCompositionInfo:model];
}

- (void)finishButtonClicked {
    if (!_assets.count) return;
    if ([self durationWithCurrentAssets] > 300) {
        [self showHUD:@"视频总时长不超过5分钟，请裁剪后继续！"];
    }else if ([self videoCounnts] > 5) {
        [self showHUD:@"最多5个视频"];
    }else {
        [_delegate pickViewDidFinishWithAssets:_assets duration:_duration];
    }
}

- (void)showHUD:(NSString *)title {
    QUMBProgressHUD *hud = [QUMBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = QUMBProgressHUDModeText;
    hud.label.text = title;
    hud.offset = CGPointMake(0.f, -200.f);
    hud.backgroundView.style = QUMBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = rgba(0, 0, 0, 0.7);
    hud.label.textColor = [UIColor whiteColor];
    hud.bezelView.style = QUMBProgressHUDBackgroundStyleSolidColor;
    [hud hideAnimated:YES afterDelay:1.5f];
}

#pragma mark - UICollectionViewDataSource methods

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(SizeWidth(90), SizeWidth(90));
}

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunCompositionPickCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunCompositionPickCell" forIndexPath:indexPath];
    cell.delegate = self;
    AliyunCompositionInfo *asset = _assets[indexPath.row];
    cell.imageView.image = asset.thumbnailImage;
    return cell;
}

#pragma mark - QUReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    AliyunCompositionInfo *model = self.assets[fromIndexPath.item];
    [self.assets removeObjectAtIndex:fromIndexPath.item];
    [self.assets insertObject:model atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    return YES;
}

#pragma mark - QUReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
