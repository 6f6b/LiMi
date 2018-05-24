//
//  AliyunPublishProgressView.m
//  qusdk
//
//  Created by Worthy on 2017/11/9.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPublishProgressView.h"

@interface AliyunPublishProgressView()
@property (nonatomic,strong) UILabel *topLable;
@property (nonatomic,strong) UILabel *middleLable;
@property (nonatomic,strong) UILabel *bottomLable;

@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UIImageView *finishImageView;


@end

@implementation AliyunPublishProgressView

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
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.backgroundColor = rgba(27,33,51,0.50);
    _topLable = [[UILabel alloc] initWithFrame:CGRectMake(0, height/2-40, width, 24)];
    _topLable.font = [UIFont boldSystemFontOfSize:24.f];
    _topLable.textColor = [UIColor whiteColor];
    _topLable.textAlignment = NSTextAlignmentCenter;
    _topLable.text = @"我的视频";
    [self addSubview:_topLable];
    
    _middleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, height/2-5, width, 22)];
    _middleLable.font = [UIFont systemFontOfSize:16.f];
    _middleLable.textColor = [UIColor whiteColor];
    _middleLable.textAlignment = NSTextAlignmentCenter;
    _middleLable.text = @"视频合成中";
    [self addSubview:_middleLable];
    
    _bottomLable = [[UILabel alloc] initWithFrame:CGRectMake(0, height/2+18, width, 18)];
    _bottomLable.font = [UIFont systemFontOfSize:12.f];
    _bottomLable.textColor = rgba(188, 188, 188, 1);
    _bottomLable.textAlignment = NSTextAlignmentCenter;
    _bottomLable.text = @"请不要关闭应用";
    [self addSubview:_bottomLable];
    
    
    _finishImageView = [[UIImageView alloc] initWithFrame:CGRectMake((width-26)/2, height/2-40, 26, 26)];
    _finishImageView.image = [AliyunImage imageNamed:@"icon_composite_success"];
    _finishImageView.hidden = YES;
    [self addSubview:_finishImageView];
}

- (void)setProgress:(CGFloat)progress {
    _topLable.text = [NSString stringWithFormat:@"%d%%",(int)(progress*100)];
    _middleLable.text = @"视频合成中";
    _bottomLable.text = @"请不要关闭应用";
    _topLable.hidden = NO;
    _middleLable.hidden = NO;
    _bottomLable.hidden = NO;
    _finishImageView.hidden = YES;
}
- (void)markAsFinihed {
    _middleLable.text = @"合成成功";
    _topLable.hidden = YES;
    _middleLable.hidden = NO;
    _bottomLable.hidden = YES;
    _finishImageView.hidden = NO;
}
- (void)markAsFailed {
    _finishImageView.image = [AliyunImage imageNamed:@"icon_composite_fail"];
    _middleLable.text = @"合成失败";
    _bottomLable.text = @"请返回编辑稍后再试";
    _topLable.hidden = YES;
    _middleLable.hidden = NO;
    _bottomLable.hidden = NO;
    _finishImageView.hidden = NO;
}

@end
