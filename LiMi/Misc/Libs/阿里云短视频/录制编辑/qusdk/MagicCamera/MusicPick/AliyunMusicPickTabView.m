//
//  AliyunMusicPickTabView.m
//  qusdk
//
//  Created by Worthy on 2017/6/26.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMusicPickTabView.h"


@interface AliyunMusicPickTabView ()
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *indicator;
@end

@implementation AliyunMusicPickTabView
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubViews];
    }
    return self;
}



- (void)setupSubViews {
    self.backgroundColor = [UIColor clearColor];
    self.indicator = [[UIView alloc] init];
    self.indicator.frame = CGRectMake(0, CGRectGetHeight(self.frame)-3, ScreenWidth/2, 3);
    self.indicator.backgroundColor = rgba(0,194,221,1);
    [self addSubview:self.indicator];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-0.5, ScreenWidth, 0.5)];
    line.backgroundColor = [UIColor whiteColor];
    [self addSubview:line];
    
    UIButton *leftButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = CGRectMake(0, 0, ScreenWidth/2, CGRectGetHeight(self.frame));
    [leftButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [leftButton setTitle:@"在线音乐" forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [leftButton addTarget:self action:@selector(leftButtonClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:leftButton];

    
    UIButton *rightButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    rightButton.backgroundColor = [UIColor clearColor];
    rightButton.frame = CGRectMake(ScreenWidth/2, 0, ScreenWidth/2, CGRectGetHeight(self.frame));
    [rightButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [rightButton setTitle:@"本地音乐" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rightButton addTarget:self action:@selector(rightButtonClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:rightButton];
    
}

- (void)leftButtonClicked {
    [UIView animateWithDuration:0.24 animations:^{
        self.indicator.frame = CGRectMake(0,  CGRectGetHeight(self.frame)-3, ScreenWidth/2, 3);
    }];
    [self.delegate didSelectTab:0];
}

- (void)rightButtonClicked {
    [UIView animateWithDuration:0.24 animations:^{
        self.indicator.frame = CGRectMake(ScreenWidth/2, CGRectGetHeight(self.frame)-3, ScreenWidth/2, 3);
    }];
    [self.delegate didSelectTab:1];
}

@end
