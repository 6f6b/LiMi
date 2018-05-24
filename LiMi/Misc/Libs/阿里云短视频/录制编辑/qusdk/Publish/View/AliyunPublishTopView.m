//
//  AliyunPublishTopView.m
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPublishTopView.h"

@implementation AliyunPublishTopView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTopViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupTopViews];
    }
    return self;
}



- (void)setupTopViews {
    
    UIView *topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, 0, ScreenWidth, self.frame.size.height);
    topView.backgroundColor = [AliyunIConfig config].backgroundColor;;
    [self addSubview:topView];
    
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    backButton.frame = CGRectMake(4, StatusBarHeight, 44, 44);
    [backButton setTitle:NSLocalizedString(@"cancel_camera_import", nil) forState:(UIControlStateNormal)];
    [backButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    backButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    self.cancelButton = backButton;
    [topView addSubview:backButton];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.frame = CGRectMake((ScreenWidth-68)/2, StatusBarHeight, 68, 44);
    self.nameLabel.font = [UIFont systemFontOfSize:14.f];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.text = @"我的视频";
    [topView addSubview:self.nameLabel];
    
    UIButton *nextButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    nextButton.frame = CGRectMake(ScreenWidth-44-4, StatusBarHeight, 44, 44);
    [nextButton setTitle:NSLocalizedString(@"finish_subtitle_edit", nil) forState:(UIControlStateNormal)];
    [nextButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [nextButton setTitleColor:rgba(110, 118, 139, 1) forState:(UIControlStateDisabled)];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    nextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    self.finishButton = nextButton;
    [topView addSubview:nextButton];
    
}

- (void)backButtonAction {
    [self.delegate cancelButtonClicked];
}

- (void)nextButtonAction {
    [self.delegate finishButtonClicked];
}
@end
