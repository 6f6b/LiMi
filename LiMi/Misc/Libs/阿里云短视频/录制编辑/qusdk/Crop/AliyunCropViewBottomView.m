//
//  AliyunCropViewBottomView.m
//  AliyunVideo
//
//  Created by TripleL on 17/5/4.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCropViewBottomView.h"


@interface AliyunCropViewBottomView ()

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation AliyunCropViewBottomView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat width = CGRectGetWidth(self.frame);
    self.backButton = [self buttonWithRect:(CGRectMake(0, 0, height, height)) image:[AliyunImage imageNamed:@"cancel"] action:@selector(backButtonAction)];
    [self addSubview:self.backButton];
    
    self.ratioButton = [self buttonWithRect:(CGRectMake(0, 0, height, height)) image:[AliyunImage imageNamed:@"cut_ratio"] action:@selector(ratioButtonAction)];
    self.ratioButton.center = CGPointMake(width / 2, height / 2);
    [self addSubview:self.ratioButton];
    
    self.cropButton = [self buttonWithRect:(CGRectMake(width - height, 0, height, height)) image:[AliyunImage imageNamed:@"check"] action:@selector(cropButtonAction)];
    [self addSubview:self.cropButton];
}


- (UIButton *)buttonWithRect:(CGRect)rect image:(UIImage *)image action:(SEL)sel
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)backButtonAction {
    
    if (self.delegate) {
        [self.delegate onClickBackButton];
    }
}

- (void)ratioButtonAction {
    if (self.delegate) {
        [self.delegate onClickRatioButton];
    }
}

- (void)cropButtonAction {
    self.cropButton.userInteractionEnabled = NO;
    self.ratioButton.userInteractionEnabled = NO;
    if (self.delegate) {
        [self.delegate onClickCropButton];
    }
}


@end
