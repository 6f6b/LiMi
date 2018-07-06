//
//  FilterAndBeautyView.m
//  LiMi
//
//  Created by dev.liufeng on 2018/5/22.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "FilterAndBeautyView.h"
#import "AliyunDBHelper.h"
#import "AliyunEffectFilterCell.h"

@interface FilterAndBeautyView()
    @property (weak, nonatomic) IBOutlet UIView *topView;
    @property (weak, nonatomic) IBOutlet UIButton *beautyButton;
    @property (weak, nonatomic) IBOutlet UIButton *filterButton;
    @property (weak, nonatomic) IBOutlet UIView *beautyBottomLine;
    @property (weak, nonatomic) IBOutlet UIView *filterBottomLine;
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *beautyButtonWidthConstraint;

@end
@implementation FilterAndBeautyView{
    /*滤镜*/
    UICollectionView *_collectionView;
    UIButton *_cancelButton;
    UIButton *_revokeButton;

    NSMutableArray *_dataArray;
    AliyunDBHelper *_dbHelper;
    NSInteger _selectIndex;
    UIButton *_selectButton;
    NSTimer *_schedule;
    NSIndexPath *preIdxPath;
    
    /*美颜*/
    UISlider *_slider;
}
    
- (void)awakeFromNib{
    [super awakeFromNib];
    self.scrollView.frame = CGRectMake(0, 65, ScreenWidth, 95);
    self.scrollView.contentSize = CGSizeMake(ScreenWidth*2, 95);
    self.scrollView.scrollEnabled = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.topView addGestureRecognizer:tap];
    
    _dbHelper = [[AliyunDBHelper alloc] init];
    _dataArray = [[NSMutableArray alloc] init];
    _selectIndex = -1;
    [self addSubViews];
    
    
    //[self reloadDataWithEffectType:4];
}

- (void)addSubViews {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(50, 70);
    
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth-40, 102)];
    _slider.minimumValue = 0;
    _slider.maximumValue = 100;
    _slider.value = 0;
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:_slider];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, 102) collectionViewLayout:layout];
    _collectionView.backgroundColor = rgba(0, 0, 0, 0.9);
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:nil] forCellWithReuseIdentifier:@"AliyunEffectFilterCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:nil] forCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell"];
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self;
    [self.scrollView addSubview:_collectionView];
}
    
- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
    }
    return self;
}

- (void)showOnlyWithType:(FilterAndBeautyViewType)type{
    if(type == FilterAndBeautyViewTypeOnlyFilter){
        self.beautyButtonWidthConstraint.constant = 0;
        [self.beautyButton setHidden:YES];
        [self.beautyBottomLine setHidden:YES];
        [self.filterButton setTitleColor:rgba(127, 110, 241, 1) forState:UIControlStateNormal];
        [self.filterBottomLine setHidden:NO];
        self.scrollView.contentOffset = CGPointMake(ScreenWidth, 0);
    }
    [self show];
}

- (void)showOnlyWithType:(FilterAndBeautyViewType)type Index:(int)index  filterDataArray:(NSMutableArray *)filterDataArray{
    if(type == FilterAndBeautyViewTypeOnlyFilter){
        self.beautyButtonWidthConstraint.constant = 0;
        [self.beautyButton setHidden:YES];
        [self.beautyBottomLine setHidden:YES];
        [self.filterButton setTitleColor:rgba(127, 110, 241, 1) forState:UIControlStateNormal];
        [self.filterBottomLine setHidden:NO];
        self.scrollView.contentOffset = CGPointMake(ScreenWidth, 0);
    }
    [self showWithSelectedFilterIndex:index filterDataArray:filterDataArray];
}

- (void)showWithSelectedFilterIndex:(int)index filterDataArray:(NSMutableArray *)filterDataArray{
    _selectIndex = index;
    _dataArray = filterDataArray;
    [_collectionView reloadData];
    [self show];
}


- (void)show{
    [UIApplication.sharedApplication.keyWindow addSubview:self];
}
    
- (void)dismiss{
    [self removeFromSuperview];
}

- (void)sliderValueChanged:(UISlider *)slider{
    [self.delegate filterAndBeautyViewSeletedBeautifyValue:slider.value];
}

- (IBAction)clickBeautyButton:(id)sender {
    [self.beautyButton setTitleColor:rgba(127, 110, 241, 1)  forState:UIControlStateNormal];
    [self.beautyBottomLine setHidden:NO];
    [self.filterButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.filterBottomLine setHidden:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.contentOffset = CGPointMake(0, 0);
    }];
}
    
- (IBAction)clickFilterButton:(id)sender {
    [self.beautyButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.beautyBottomLine setHidden:YES];
    [self.filterButton setTitleColor:rgba(127, 110, 241, 1) forState:UIControlStateNormal];
    [self.filterBottomLine setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.contentOffset = CGPointMake(ScreenWidth, 0);
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
    
    [_delegate filterAndBeautyViewSelectedFilterIndex:indexPath.row];
}

@end
