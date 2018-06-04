//
//  MagicCameraEffectCell.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMagicCameraEffectCell.h"
#import "UIView+Progress.h"

@interface AliyunMagicCameraEffectCell ()
@property (nonatomic,strong) UIImageView *backImageView;
@end

@implementation AliyunMagicCameraEffectCell
{
    UIView *_pieView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(frame), CGRectGetHeight(frame))];
        self.backImageView.image = [UIImage imageNamed:@"xzmf"];
        [self addSubview:self.backImageView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(frame), CGRectGetHeight(frame))];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        //self.imageView.clipsToBounds = NO;
        [self addSubview:self.imageView];
        
        self.imageView.layer.masksToBounds = NO;
        //self.imageView.layer.cornerRadius = frame.size.height/8;
        //self.imageView.layer.borderWidth = 5.0;
        //self.imageView.layer.borderColor =rgba(127, 110, 241, 1).CGColor;
        
        self.backgroundColor =[UIColor clearColor];
        
        self.downloadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetHeight(frame) - 8, CGRectGetHeight(frame) - 8, 16, 16)];
        self.downloadImageView.backgroundColor = [UIColor clearColor];
        self.downloadImageView.image = [UIImage imageNamed:@"xiazai"];
        [self addSubview:self.downloadImageView];
        self.downloadImageView.hidden = YES;
        
        _pieView = [[UIView alloc] initWithFrame:self.imageView.bounds];
        [self addSubview:_pieView];
        _pieView.backgroundColor = [UIColor clearColor];
        [_pieView pieProgressView].progressColor = [UIColor colorWithRed:27.0/255 green:33.0/255 blue:51.0/255 alpha:0.8] ;
        _pieView.hidden = YES;
    }
    return self;
}

- (void)borderHidden:(BOOL)isHidden
{
    if (isHidden) {
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    } else {
        self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
    self.imageView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _pieView.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
    _pieView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _pieView.layer.masksToBounds = YES;
    _pieView.layer.cornerRadius = self.bounds.size.height / 2.0;
}

- (void)shouldDownload:(BOOL)flag
{
    self.downloadImageView.hidden = !flag;
}

- (void)downloadProgress:(CGFloat)progress
{
    _pieView.hidden = NO;
    [_pieView setPieProgress:progress];
}

@end
