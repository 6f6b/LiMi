//
//  AliyunEffectManagerView.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectManagerView.h"
#import "AliyunEffectMoreTableViewCell.h"

#define SegmentLabelTag 60600
#define SegmentAnimationDuration 0.2

@interface AliyunEffectManagerView ()

@property (nonatomic, strong) UIView *segmentMaskView;
@property (nonatomic, assign) NSInteger currentSegmentIndex;

@end

@implementation AliyunEffectManagerView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}


- (instancetype)initWithSelectSegmentType:(NSInteger)type
                                    frame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.currentSegmentIndex = type;
        [self setupSubViews];
    }
    return self;
}


- (void)setupSubViews {
    
    self.backgroundColor =  RGBToColor(35, 42, 66);
    [self setupTopViews];
    [self setupSegmentView];
    [self setupCenterView];
}

- (void)setupTopViews {
    
    UIView *topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, SafeTop, ScreenWidth, 44);
    topView.backgroundColor = RGBToColor(35, 42, 66);
    [self addSubview:topView];
    
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    backButton.frame = CGRectMake(0, 0, SizeWidth(42), CGRectGetHeight(topView.frame));
    [backButton setImage:[AliyunImage imageNamed:@"back"] forState:(UIControlStateNormal)];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [topView addSubview:backButton];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(SizeWidth(132), 12, SizeWidth(56),20);
    nameLabel.font = [UIFont systemFontOfSize:14.f];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = @"特效管理";
    [topView addSubview:nameLabel];
}


- (void)setupSegmentView {
    
    UIView *segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 44+SafeTop, ScreenWidth, 40)];
    segmentView.backgroundColor = RGBToColor(27, 33, 51);
    [self addSubview:segmentView];
    
    NSArray *titleArray = @[@"字体",@"动图",@"MV",@"字幕"];
    
    CGFloat labelWidth = ScreenWidth / titleArray.count;
    CGFloat labelHeight = segmentView.frame.size.height;
    
    [titleArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(idx * labelWidth, 0, labelWidth, labelHeight)];
        bottomLabel.textColor = [UIColor whiteColor];
        bottomLabel.font = [UIFont systemFontOfSize:14.f];
        bottomLabel.text = obj;
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        bottomLabel.userInteractionEnabled = YES;
        bottomLabel.tag = SegmentLabelTag + idx;
        [segmentView addSubview:bottomLabel];
        
        UITapGestureRecognizer *bottomLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedLabelAction:)];
        bottomLabelTap.numberOfTapsRequired = 1;
        [bottomLabel addGestureRecognizer:bottomLabelTap];
    }];
    
    self.segmentMaskView = [[UIView alloc] init];
    self.segmentMaskView.frame = CGRectMake(self.currentSegmentIndex * labelWidth, labelHeight - 2, labelWidth, 2);
    self.segmentMaskView.backgroundColor = RGBToColor(239, 75, 129);
    [segmentView addSubview:self.segmentMaskView];
    
}

- (void)setupCenterView {
    
    self.tableView = [[UITableView alloc] initWithFrame:(CGRectMake(0, 84+SafeTop, ScreenWidth, ScreenHeight - 84 - SafeTop - SafeBottom)) style:(UITableViewStylePlain)];
    [self.tableView registerClass:[AliyunEffectMoreTableViewCell class] forCellReuseIdentifier:EffectManagerTableViewIndentifier];
    [self.tableView setRowHeight:SizeHeight(74)];
    self.tableView.backgroundColor = RGBToColor(35, 42, 66);
    self.tableView.separatorStyle = NO;
    [self addSubview:self.tableView];
    
}

- (void)setTableViewDelegates:(id<UITableViewDelegate, UITableViewDataSource>)delegate {
    
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
}

- (void)backButtonAction {
    
    [self.delegate onClickBackButton];
}

- (void)clickedLabelAction:(UITapGestureRecognizer *)sender {
    
    UILabel *label = (UILabel *)sender.view;
    
    NSInteger tapIndex = label.tag - SegmentLabelTag;
    if (tapIndex != self.currentSegmentIndex) {
        [self.delegate segmentClickChangedWithIndex:tapIndex title:label.text];
    }
    
    self.currentSegmentIndex = tapIndex;
    
    CGRect maskViewFrame = CGRectMake(CGRectGetMinX(label.frame), CGRectGetHeight(label.frame) - 2, CGRectGetWidth(label.frame), 2);
    
    [UIView animateWithDuration:SegmentAnimationDuration animations:^{
        
        self.segmentMaskView.frame = maskViewFrame;
        
    } completion:^(BOOL finished) {
        
    }];
    
}

@end
