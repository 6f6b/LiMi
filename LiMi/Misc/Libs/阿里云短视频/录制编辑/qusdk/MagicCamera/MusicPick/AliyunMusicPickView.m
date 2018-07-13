//
//  AliyunMusicPickView.m
//  LiMi
//
//  Created by dev.liufeng on 2018/5/28.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "AliyunMusicPickView.h"
#import "AliyunMusicPickCoverView.h"

@interface AliyunMusicPickView ()<UIScrollViewDelegate>
@property (nonatomic, assign) float musicDuration;
@property (nonatomic, assign) float pageDuration;

@property (nonatomic, strong) UIView *fillLayer;
@property (nonatomic, strong) UIBezierPath *overlayPath;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) AliyunMusicPickCoverView *coverView;

@property (nonatomic,strong) UIButton *useButton;
@end
@implementation AliyunMusicPickView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubviews];
    }
    return self;
}


- (void)setupSubviews {
    self.backgroundColor = [UIColor clearColor];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.alwaysBounceVertical = false;
    self.scrollView.alwaysBounceHorizontal = false;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, ScreenWidth/4, 0, ScreenWidth/4);
    [self addSubview:self.scrollView];
    self.lineView = [[AliyunMusicLineView alloc] initWithFrame:self.bounds];
    [self.scrollView addSubview:self.lineView];
    
    self.coverView = [[AliyunMusicPickCoverView alloc] initWithFrame:self.bounds];
    [self addSubview:self.coverView];
    
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _infoLabel.text = @"左右拖动以剪取音乐";
    _infoLabel.textColor = [UIColor whiteColor];
    _infoLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_infoLabel];
    
    _startLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _startLabel.textColor = rgba(114, 114, 114, 1);
    _startLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _startLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_startLabel];
    
    _endLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _endLabel.textColor = rgba(114, 114, 114, 1);
    _endLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _endLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_endLabel];
    
    _useButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-15-64, 15, 64, 25)];
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    CGColorRef color1 =  rgba(255, 90, 0, 1).CGColor;
    CGColorRef color2 = rgba(144, 0, 218, 1).CGColor;
    [gradientLayer setColors:@[(__bridge id)color2,(__bridge id)color1]];
     gradientLayer.startPoint = CGPointMake(0, 0.5);
     gradientLayer.endPoint = CGPointMake(1, 0.5);
     gradientLayer.frame = CGRectMake(0, 0, 64, 25);
    [_useButton.layer addSublayer:gradientLayer];
    
    _useButton.layer.cornerRadius = 12.5;
    _useButton.clipsToBounds = true;
    [_useButton setTitle:@"使用" forState:UIControlStateNormal];
    _useButton.titleLabel.textColor = UIColor.whiteColor;
    _useButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_useButton addTarget:self.delegate action:@selector(useButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_useButton];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layout];
}

-(void)layout {
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat factor = _musicDuration/_pageDuration > 1 ? _musicDuration/_pageDuration : 1;
    CGFloat contentWidth = width/2 * factor;
    self.infoLabel.frame = CGRectMake(15, 20, 200, 15);
    self.startLabel.frame = CGRectMake(15, CGRectGetMaxY(self.infoLabel.frame)+20, 100, 12);
    self.endLabel.frame = CGRectMake(width-36-15, CGRectGetMaxY(self.infoLabel.frame)+20, 36, 12);
    self.scrollView.contentSize = CGSizeMake(contentWidth, 50);
    self.scrollView.frame = CGRectMake(15, CGRectGetMaxY(self.startLabel.frame)+14, width-30, 50);
    self.coverView.frame = CGRectMake(15, CGRectGetMaxY(self.startLabel.frame)+14, width-30, 50);
//    self.scrollView.frame = CGRectMake(0, 16, width, height-48);
//    self.coverView.frame = CGRectMake(0, 16, width, height-48);
    self.lineView.frame =  CGRectMake(0, 0, contentWidth, 50);
    self.scrollView.contentInset = UIEdgeInsetsMake(0, ScreenWidth/4, 0, ScreenWidth/4);
    [self.lineView refresh];
}

-(void)configureMusicDuration:(float)musicDuration pageDuration:(float)pageDuration{
    _pageDuration = pageDuration;
    _musicDuration = musicDuration;
    CGPoint offset = CGPointMake(-ScreenWidth/4.0, 0);
    _scrollView.contentOffset = offset;
    [self layout];
    [self updateCurrentTime];
}

#pragma mark - scroll view delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentTime];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updateCurrentTime];
    }
}

- (void)updateCurrentTime {
    CGFloat startTime = (_musicDuration * (self.scrollView.contentOffset.x + self.scrollView.contentInset.left)) / self.scrollView.contentSize.width;
    if (startTime < 0) {
        startTime = 0;
    }
    self.startLabel.text = [NSString stringWithFormat:@"当前从%@开始",[self timeFormatted:startTime]];
    self.endLabel.text = [self timeFormatted:startTime+_pageDuration];
    [self.delegate didSelectStartTime:startTime];
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

@end
