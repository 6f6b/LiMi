//
//  AliyunEffectMoreView.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMoreView.h"
#import "AliyunEffectMoreTableViewCell.h"
#import "AliyunEffectMorePreviewCell.h"

@interface AliyunEffectMoreView ()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation AliyunEffectMoreView

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


- (void)setupSubViews {
    
    self.backgroundColor = [UIColor clearColor];
    [self setupTopViews];
    [self setupCenterView];
}

- (void)setupTopViews {
    self.backgroundColor = RGBToColor(35, 42, 66);
    UIView *topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, SafeTop, ScreenWidth, SizeHeight(44));
    topView.backgroundColor = RGBToColor(35, 42, 66);
    [self addSubview:topView];
    
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    backButton.frame = CGRectMake(0, 0, SizeWidth(28 + 12 + 12), CGRectGetHeight(topView.frame));
    [backButton setTitle:NSLocalizedString(@"cancel_camera_import", nil) forState:(UIControlStateNormal)];
    [backButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    backButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [topView addSubview:backButton];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.frame = CGRectMake(SizeWidth(132), SizeHeight(12), SizeWidth(56), SizeHeight(20));
    self.nameLabel.font = [UIFont systemFontOfSize:14.f];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.text = @"更多";
    [topView addSubview:self.nameLabel];
    
    UIButton *nextButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    nextButton.frame = CGRectMake(ScreenWidth - SizeWidth(44), 0, SizeWidth(44), CGRectGetHeight(topView.frame));
    [nextButton setImage:[AliyunImage imageNamed:@"resource_edit"] forState:(UIControlStateNormal)];
    [nextButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    nextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [topView addSubview:nextButton];

}


- (void)setupCenterView {
    
    self.tableView = [[UITableView alloc] initWithFrame:(CGRectMake(0, SizeHeight(44)+SafeTop, ScreenWidth, ScreenHeight - SizeHeight(44)-SafeBottom-SafeTop)) style:(UITableViewStylePlain)];
    [self.tableView registerClass:[AliyunEffectMorePreviewCell class] forCellReuseIdentifier:EffectMorePreviewTableViewIndentifier];
    self.tableView.backgroundColor = RGBToColor(35, 42, 66);
    self.tableView.separatorStyle = NO;
    [self addSubview:self.tableView];
    
}

- (void)setTableViewDelegates:(id<UITableViewDelegate, UITableViewDataSource>)delegate {
    
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
}

- (void)setTitleWithEffectType:(NSInteger)type {
    
    NSString *title = @"更多";
    switch (type) {
        case 1:
            title = @"更多字体";
            break;
        case 2:
            title = @"更多动图";
            break;
        case 3:
            title = @"更多iMV";
            break;
        case 4:
            title = @"更多滤镜";
            break;
        case 5:
            title = @"更多音乐";
            break;
        case 6:
            title = @"更多字幕";
            break;
        default:
            break;
    }
    self.nameLabel.text = title;
}

- (void)backButtonAction {
    
    [self.delegate onClickBackButton];
}

- (void)nextButtonAction {
    
    [self.delegate onClickNextButton];
}


@end
