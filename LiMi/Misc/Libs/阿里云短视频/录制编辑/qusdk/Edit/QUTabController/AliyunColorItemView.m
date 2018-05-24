//
//  AliyunColorItemView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunColorItemView.h"
#import "AliyunColor.h"
#import "AliyunColorItemCell.h"

@interface AliyunColorItemView()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *fillButton;
@property (nonatomic, strong) UIButton *strokeButton;
@property (nonatomic, strong) UIView *cursorView;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, weak) UIButton *selectButton;

@end

@implementation AliyunColorItemView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSArray *)configColors
{
    NSArray *colors = @[@[@{@"tR":@231.0,@"tG":@46.0,@"tB":@69.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@255.0,@"tG":@109.0,@"tB":@0.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@1.0,@"tG":@158.0,@"tB":@37.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@0.0,@"tG":@72.0,@"tB":@210.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@122.0,@"tG":@31.0,@"tB":@186.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@65.0,@"tG":@45.0,@"tB":@20.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@0.0,@"tG":@0.0,@"tB":@0.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@250.0,@"tG":@101.0,@"tB":@147.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@255.0,@"tG":@239.0,@"tB":@2.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@83.0,@"tG":@21.0,@"tB":@62.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@1.0,@"tG":@173.0,@"tB":@217.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@188.0,@"tG":@52.0,@"tB":@186.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@154.0,@"tG":@129.0,@"tB":@107.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@255.0,@"tG":@255.0,@"tB":@255.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@249.0,@"tG":@197.0,@"tB":@199.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@255.0,@"tG":@255.0,@"tB":@144.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@193.0,@"tG":@255.0,@"tB":@68.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@56.0,@"tG":@229.0,@"tB":@191.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@229.0,@"tG":@205.0,@"tB":@255.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@239.0,@"tG":@75.0,@"tB":@129.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        @{@"tR":@197.0,@"tG":@210.0,@"tB":@249.0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                        ],
                        @[@{@"sR":@231.0,@"sG":@46.0,@"sB":@69.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@255.0,@"sG":@109.0,@"sB":@0.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@1.0,@"sG":@158.0,@"sB":@37.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@0.0,@"sG":@72.0,@"sB":@210.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@122.0,@"sG":@31.0,@"sB":@186.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@65.0,@"sG":@45.0,@"sB":@20.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@0.0,@"sG":@0.0,@"sB":@0.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@250.0,@"sG":@101.0,@"sB":@147.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@255.0,@"sG":@239.0,@"sB":@2.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@83.0,@"sG":@21.0,@"sB":@62.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@1.0,@"sG":@173.0,@"sB":@217.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@188.0,@"sG":@52.0,@"sB":@186.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@154.0,@"sG":@129.0,@"sB":@107.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@255.0,@"sG":@255.0,@"sB":@255.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@249.0,@"sG":@197.0,@"sB":@199.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@255.0,@"sG":@255.0,@"sB":@144.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@193.0,@"sG":@255.0,@"sB":@68.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@56.0,@"sG":@229.0,@"sB":@191.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@229.0,@"sG":@205.0,@"sB":@255.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@239.0,@"sG":@75.0,@"sB":@129.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                        @{@"sR":@197.0,@"sG":@210.0,@"sB":@249.0,@"tR":@0,@"tG":@0,@"tB":@0,@"isStroke":@1},
                          ]

                        ];
    
    return colors;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
        [self setupData];
    }
    return self;
}

- (void)addSubviews
{
    CGFloat inset = (CGRectGetHeight(self.bounds) - 92) / 2;
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(24, 24);
    followLayout.headerReferenceSize = CGSizeMake(46, 46);
    followLayout.minimumLineSpacing = (ScreenWidth - 46 * 2 - 7 * 24 ) / 6;
    followLayout.footerReferenceSize = CGSizeMake(46, 46);
    followLayout.sectionInset = UIEdgeInsetsMake(inset, 0, inset, 0);
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) collectionViewLayout:followLayout];
    [self addSubview:self.collectionView];
    self.backgroundColor = [UIColor colorWithRed:27.0/255 green:33.0/255 blue:51.0/255 alpha:1];
    self.collectionView.backgroundColor = [UIColor colorWithRed:27.0/255 green:33.0/255 blue:51.0/255 alpha:1];
    self.collectionView.delegate = (id)self;
    self.collectionView.dataSource = (id)self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"AliyunColorItemCell" bundle:nil] forCellWithReuseIdentifier:@"AliyunColorItemCell"];
    self.collectionView.pagingEnabled = YES;

    self.fillButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fillButton setTitle:@"填充" forState:UIControlStateNormal];
    self.fillButton.frame = CGRectMake(0, 0, 50, 20);
    [self.fillButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.fillButton setTitleColor:[UIColor colorWithRed:96.0/255 green:110.0/255 blue:124.0/255 alpha:1] forState:UIControlStateNormal];
    self.fillButton.center = CGPointMake(CGRectGetMidX(self.bounds) - 30, CGRectGetHeight(self.bounds) - 15);
    self.fillButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.fillButton addTarget:self action:@selector(fillButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.fillButton];
    self.lineView.center = CGPointMake(self.fillButton.center.x, self.fillButton.center.y + CGRectGetMidY(self.fillButton.bounds));
    [self addSubview:self.lineView];
    self.fillButton.selected = YES;
    self.selectButton = self.fillButton;
    
    self.strokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.strokeButton setTitle:@"描边" forState:UIControlStateNormal];
    self.strokeButton.frame = CGRectMake(0, 0, 50, 20);
    [self.strokeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.strokeButton setTitleColor:[UIColor colorWithRed:96.0/255 green:110.0/255 blue:124.0/255 alpha:1] forState:UIControlStateNormal];
    self.strokeButton.center = CGPointMake(CGRectGetMidX(self.bounds) + 30, CGRectGetHeight(self.bounds) - 15);
    self.strokeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.strokeButton addTarget:self action:@selector(strokeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.strokeButton];
}

- (void)strokeButtonClicked:(id)sender {
    [self animateCollectionViewWithCurrentPage:1];
}

- (void)fillButtonClicked:(id)sender {
    [self animateCollectionViewWithCurrentPage:0];
}

- (void)setupData
{
    NSArray *configColors = [self configColors];
    for (NSArray *array in configColors) {
        NSMutableArray *marray = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            AliyunColor *color = [[AliyunColor alloc] initWithDict:dict];
            [marray addObject:color];
        }
        
        [self.colors addObject:marray];
    }
    
    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (NSMutableArray *)colors
{
    if (!_colors) {
        _colors = [[NSMutableArray alloc] init];
    }
    return _colors;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 1.5)];
        _lineView.backgroundColor = [UIColor redColor];
    }
    return _lineView;
}

#pragma mark - UICollectionViewDataSource UICollectionViewDelegate -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.colors.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *array = [self.colors objectAtIndex:section];
    return array.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunColorItemCell *effectCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunColorItemCell" forIndexPath:indexPath];
    
    NSArray *colors = [self.colors objectAtIndex:indexPath.section];
    AliyunColor *color = [colors objectAtIndex:indexPath.row];
    effectCell.color = color;
    
    
    
    return effectCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunColorItemCell *effectCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunColorItemCell" forIndexPath:indexPath];
    effectCell.selected = YES;
    
    NSArray *colors = [self.colors objectAtIndex:indexPath.section];
    AliyunColor *color = [colors objectAtIndex:indexPath.row];
    [self.delegate textColorChanged:color];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _collectionView.frame.size.width;
    float currentPage = _collectionView.contentOffset.x / pageWidth;
    
    if (0.0f != fmodf(currentPage, 1.0f)) {
        [self animateButtonWithCurrentPage:currentPage];
    } else {
        [self animateButtonWithCurrentPage:currentPage];
    }
}

- (void)animateButtonWithCurrentPage:(int)page
{
    self.selectButton.selected = NO;
    if (page == 0) {
        self.selectButton = self.fillButton;
    } else {
        self.selectButton = self.strokeButton;
    }
    self.selectButton.selected = YES;
    [UIView animateWithDuration:.15 animations:^{
        self.lineView.center = CGPointMake(self.selectButton.center.x, self.selectButton.center.y + CGRectGetMidY(self.selectButton.bounds));
    }];
}

- (void)animateCollectionViewWithCurrentPage:(int)page {
    self.selectButton.selected = NO;
    if (page == 0) {
        self.selectButton = self.fillButton;
    } else {
        self.selectButton = self.strokeButton;
    }
    self.selectButton.selected = YES;
    [UIView animateWithDuration:.15 animations:^{
        self.lineView.center = CGPointMake(self.selectButton.center.x, self.selectButton.center.y + CGRectGetMidY(self.selectButton.bounds));
    }];
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:0 inSection:page];
    
    UICollectionViewScrollPosition scrollPosition = page ? UICollectionViewScrollPositionLeft : UICollectionViewScrollPositionCenteredHorizontally;
    [self.collectionView scrollToItemAtIndexPath:nextItem atScrollPosition:scrollPosition animated:YES];}

@end
